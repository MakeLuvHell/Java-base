# 任务书 W5：用户导入增强与批量授权

> **前置要求：** 已通过 W1～W4，能启动前后端，并能解释用户列表、角色、部门和按钮权限的基本链路。
> **任务性质：** 本周不是从零实现用户导入。仓库已经有导入接口、模板、按钮和通用上传弹窗；本任务是在真实基线上补齐结构化结果、批量部门、批量角色、事务和数据权限。

| 项 | 内容 |
| --- | --- |
| 阶段 | 第 5 周延伸任务 |
| 难度 | ★★★★ |
| 建议工期 | **7～9 个工作日**；可拆成 W5A/W5B/W5C 三个 PR |
| 基线分支 | `master` |
| 任务池映射 | T14 + T20；批量写、事务与数据权限专项 |
| 必须评审 | 导入契约、角色替换语义、权限 SQL、事务边界 |

---

## 0. 先核对现状

开始设计前必须逐项打开代码，不得把已有能力当成新增能力：

| 已有能力 | 真实位置 |
| --- | --- |
| 导入接口、模板接口、`system:user:import` | `ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysUserController.java` |
| Excel 解析和逐行写入 | `ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserServiceImpl.java` |
| 导入字段 | `ruoyi-common/src/main/java/com/ruoyi/common/core/domain/entity/SysUser.java` |
| 导入按钮、表格多选、部门树和角色多选样例 | `ruoyi-ui/src/views/system/user/index.vue` |
| 通用上传弹窗 | `ruoyi-ui/src/components/ExcelImportDialog/index.vue` |
| 用户 API | `ruoyi-ui/src/api/system/user.js` |

现状存在三个明确缺口：

1. 导入结果是拼接的 HTML 字符串，前端使用 `dangerouslyUseHTMLString` 展示，无法稳定渲染逐行结果。
2. 导入过程中先成功的行可能已经写入，后续失败又让整个接口报错，调用方无法判断真实落库情况。
3. 页面只有单用户部门/角色操作，没有带数据范围校验的批量写接口。

提交设计时必须附一张“已有 / 增强 / 新建”对照表。

---

## 1. 本周交付

### W5A：增强现有用户导入

复用 `POST /system/user/importData`、模板下载和现有导入按钮，不再新建一套重复入口。

默认采用“**先全量校验，再整批写入**”策略：

1. 解析文件并为每行保留 Excel 行号。
2. 完成格式、唯一性、部门、角色和数据范围校验；同一文件内登录名重复也算失败。
3. 任意一行失败时返回全部校验结果，**数据库零写入**。
4. 全部校验通过后，在一个事务内写入用户和角色；任一写入异常时整批回滚。
5. 不允许在 Excel 中传入明文密码。新增用户使用配置项 `sys.user.initPassword`，响应和日志均不得返回密码。

#### 默认导入字段契约

| 列 | 规则 |
| --- | --- |
| 登录名称 | 必填，文件内唯一；与现有账号冲突时按 `updateSupport` 决定更新或报错 |
| 用户名称 | 必填，沿用 `SysUser` 校验规则 |
| 部门编号 | 必填，按 `deptId` 精确匹配；部门必须存在、启用且在操作者数据范围内 |
| 角色权限字符 | 可空；多个 `roleKey` 用英文逗号分隔，必须存在、启用且在操作者数据范围内 |
| 邮箱、手机、性别、状态、备注 | 沿用现有字段长度、格式和值域校验 |

更新已有用户时采用以下固定语义：

- `updateSupport=false`：已有账号是校验失败，整批不写。
- `updateSupport=true`：更新普通字段和部门；角色列非空时**替换**为指定角色，角色列为空时保留原角色。
- 不得修改 `userId=1`；不得绕过 `checkUserAllowed`、用户数据范围、部门数据范围和角色数据范围。

成功和校验失败都返回结构化数据，字段名可按仓库风格微调，但语义不得减少：

```json
{
  "code": 200,
  "msg": "校验失败，未写入任何用户",
  "data": {
    "total": 3,
    "successCount": 0,
    "failureCount": 1,
    "committed": false,
    "rows": [
      { "rowNumber": 2, "userName": "intern01", "status": "VALID", "reason": "" },
      { "rowNumber": 3, "userName": "intern02", "status": "INVALID", "reason": "部门不存在" }
    ]
  }
}
```

前端必须用表格渲染 `rows`，不能拼接或执行服务端返回的 HTML。若修改通用 `ExcelImportDialog`，要保留其他调用方只有 `msg` 时的兼容路径。

### W5B：批量分配部门

新增接口，推荐契约：

```http
PUT /system/user/batch/dept
Content-Type: application/json

{"userIds":[101,102],"deptId":200}
```

- 权限字符：`system:user:dept`。
- `userIds` 去重后必须为 1～100 个，`deptId` 必填。
- 先校验全部用户、目标部门和数据范围，再在一个事务内更新；任何一项失败时零写入。
- 禁止修改 `userId=1`，并复用现有 `checkUserAllowed` / `checkUserDataScope` / `checkDeptDataScope` 语义。
- 前端复用页面已有的表格多选和 `Treeselect`，不要引用仓库中不存在的 `DeptTree.vue`。

### W5C：批量分配角色

新增接口，推荐契约：

```http
PUT /system/user/batch/roles
Content-Type: application/json

{"userIds":[101,102],"roleIds":[3,4],"mode":"REPLACE"}
```

- 权限字符：`system:user:role`。
- 本任务只支持 `REPLACE`，不同时实现追加模式；`roleIds` 至少一个。
- 对全部用户和角色完成存在性、启用状态、超级管理员保护及数据范围校验后，再删除旧关联并插入新关联。
- 整批操作只有一个事务，任一用户失败时所有用户保持原角色。
- 前端复用用户编辑表单中的 `el-select multiple` 角色选项，不新造 `RoleSelect.vue`。

---

## 2. 修改范围

| 层 | 真实路径 / 建议位置 |
| --- | --- |
| Controller | `ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysUserController.java` |
| Service | `ruoyi-system/src/main/java/com/ruoyi/system/service/ISysUserService.java` 及 `ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserServiceImpl.java` |
| Mapper | `ruoyi-system/src/main/java/com/ruoyi/system/mapper/`、`ruoyi-system/src/main/resources/mapper/system/` |
| Domain / DTO | `ruoyi-common/src/main/java/com/ruoyi/common/core/domain/entity/SysUser.java`；专用导入/批量请求 DTO 放在现有模块约定位置 |
| 前端页面 | `ruoyi-ui/src/views/system/user/index.vue` |
| 前端组件 | `ruoyi-ui/src/components/ExcelImportDialog/index.vue`，仅在确需通用兼容时修改 |
| 前端 API | `ruoyi-ui/src/api/system/user.js` |
| 权限 SQL | 版本化升级 SQL + 对应回滚 SQL，不只写在 PR 描述里 |

不要修改 JWT、`SecurityConfig`、主题样式，也不要为本任务新建业务表。

---

## 3. 权限、事务与失败行为

| 场景 | 预期结果 |
| --- | --- |
| 缺少导入 / 批量部门 / 批量角色权限 | 对应接口分别返回 403；按钮隐藏只是辅助体验 |
| 请求包含操作者数据范围外的用户 | 整批拒绝，零写入 |
| 目标部门或任一角色越权 / 停用 / 不存在 | 整批拒绝，零写入 |
| 请求包含 `userId=1` | 整批拒绝，零写入 |
| 写到第 N 个用户发生异常 | 用户、用户角色关联均回滚到请求前状态 |
| 重复提交相同 `REPLACE` 请求 | 最终角色集合不重复，结果一致 |

Controller 负责参数入口、权限和统一响应；事务、校验顺序和批量业务规则放在 Service。不得在循环中调用 Controller，也不得通过前端过滤替代后端校验。

---

## 4. 数据库与权限准备

提交幂等的升级/回滚 SQL，为“用户管理”增加两个按钮权限：

- `system:user:dept`
- `system:user:role`

`system:user:import` 已存在，不得重复插入。升级 SQL 需要避免固定主键冲突或在执行前明确校验；回滚 SQL 只能删除本任务新增的菜单记录。准备三个本地账号：全权限、只有列表权限、数据范围受限。

---

## 5. 验收矩阵

### 导入

- [ ] 下载模板，导入 3 条全新合法用户，结果含真实 Excel 行号并一次提交成功
- [ ] 文件内用户名重复、数据库用户名冲突、非法邮箱、停用部门、未知角色分别给出稳定错误
- [ ] 混合合法/非法行时 `committed=false`，合法行也没有落库
- [ ] `updateSupport=true` 时角色空白保留、非空替换；`false` 时已有账号阻断整批
- [ ] 上传伪装扩展名、空文件、超出配置大小限制时返回可理解错误，不输出堆栈或密码

### 批量部门与角色

- [ ] 2～3 个普通用户批量修改成功，刷新列表后与数据库一致
- [ ] 三个权限分别用无权账号直调，均为 403
- [ ] 用户越权、部门越权、角色越权、包含 `userId=1` 时均零写入
- [ ] 人为制造中途异常，验证部门或角色关联完整回滚
- [ ] 空数组、重复 ID、超过 100 个、目标不存在均有明确响应

### 前端与回归

- [ ] 0 个选中时批量按钮禁用；请求中有 loading，成功后刷新，失败后保留选择便于重试
- [ ] 导入结果使用文本表格渲染，恶意错误文本不能作为 HTML 执行
- [ ] 单用户新增、编辑、分配角色、导入模板、用户列表仍可用

---

## 6. 推荐拆分

1. **W5A（3～4 天）：** 基线对照、导入 DTO/结果契约、两阶段校验、结果表格。
2. **W5B（2 天）：** 批量部门接口、事务、数据权限、前端弹窗。
3. **W5C（2～3 天）：** 角色替换接口、关联表事务、前端多选、完整回归。

每个 PR 都要小到可以独立回滚；W5B/W5C 不依赖 W5A 未合入的前端状态。

---

## 7. 必交证据

- 接口契约与“已有 / 增强 / 新建”说明
- 权限升级 SQL、回滚 SQL及执行记录
- 验收矩阵结果，至少包含一次 403、一次数据范围拒绝和一次事务回滚证据
- 导入成功、校验失败、批量部门、批量角色截图或接口响应
- `docs/intern/notes/W5-notes.md`：记录事务边界、角色 `REPLACE` 语义、为何不能只做前端权限

构建或测试若受本机环境阻塞，必须记录命令、完整错误和未验证范围，不能写“应该没问题”。
