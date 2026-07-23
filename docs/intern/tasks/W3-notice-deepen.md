# 任务书 W3：公告加深（筛选 + 导出 + 操作日志 + 模块说明）

> **前置：** 已通过 [W1](./W1-login-and-user-list.md)、[W2](./W2-notice-enhancement.md)。  
> **循序渐进：** 本周**继续做通知公告**，不再换新业务域。在 W2「置顶」之上补齐查询、导出、日志与文档能力。  
> **零基础：** 导出请**照抄岗位管理（post）**的写法；筛选照抄已有「公告类型」查询条件。

| 项 | 内容 |
| --- | --- |
| 阶段 | 第 3 周 |
| 难度 | ★★（比 W2 多权限菜单与导出，但可对照现成模块） |
| 建议工期 | **5 个工作日** |
| 分支 | `feature/<你的名字>-notice-w3`（从最新 `master` 或已合入的 W2 分支拉出，听导师安排） |
| 基线 | `master`（或导师指定的已含置顶功能的分支） |
| 任务池映射 | T12 + T13 + T14 + W2 的 P1 筛选 |

---

## 0. 大白话：本周交付什么？

W2 做完后，公告已经能**置顶**。本周要让它更像完整的管理功能：

| # | 能力 | 用户能感知到什么 |
| --- | --- | --- |
| 1 | **按置顶筛选** | 查询区可选「全部 / 置顶 / 不置顶」，列表跟着变 |
| 2 | **导出 Excel** | 有「导出」按钮；点下去下载表格；无权限 403 |
| 3 | **操作日志说得清** | 改公告后，能在「操作日志」里找到对应记录，并说明是谁记的 |
| 4 | **模块小文档** | 一页 Markdown：表字段 + 接口表 + 权限字符 |

**一句话验收：**  
能按置顶筛出数据；管理员能导出含置顶列的 Excel；无导出权限 403；能指着操作日志讲 `@Log`；交出模块说明文档。

### 本周明确不要做

| 不要做 | 为什么 |
| --- | --- |
| 换全新业务表 / 大 gen 一堆 CRUD | 第 3 周先在熟悉模块上加深 |
| `@DataScope` 数据权限改造 | 进阶项，放到加分或第 4 周结对 |
| 改 JWT / SecurityConfig 大手术 | 仍属红线区；安全只做**只读观摩笔记**（可选） |
| 重做 W2 置顶（若已合入） | 在已有置顶上增量；若 master 还没有置顶，先与导师确认基线 |
| 去掉任何 `@PreAuthorize` | 不合格 |

### 推荐默认（导师未另行说明时）

| 项 | 默认 |
| --- | --- |
| 筛选字段 | 复用 W2 的 `is_top` / `isTop` |
| 筛选 UI | 查询区 `el-select`：全部 / 是 / 否 |
| 导出权限字符 | **`system:notice:export`**（新建按钮权限 + 菜单 SQL） |
| 导出实现对照 | `SysPostController.export` + 岗位前端 `handleExport` |
| 导出列 | 至少：标题、类型、状态、**是否置顶**、创建者、创建时间（可再加） |
| 操作日志 | 使用已有 `@Log`；本周重点是**会查、会讲**，一般不必新写 AOP |

---

## 1. 范围

### 1.1 允许改动

| 层 | 路径提示 |
| --- | --- |
| 公告后端 | `SysNoticeController`、`SysNotice`、`SysNoticeMapper.xml`、Service 若需透传 |
| 公告前端 | `ruoyi-ui/src/views/system/notice/`、`api/system/notice.js` |
| 菜单权限 SQL | 本地执行的 `sys_menu` 插入（按钮级 `system:notice:export`），**写进 PR** |
| 文档 | 个人笔记或 `notes/notice-module.md`（按导师是否允许进库） |

### 1.2 建议对照的「样板代码」（先读再抄结构）

| 目的 | 样板 |
| --- | --- |
| 列表导出后端 | `SysPostController` 的 `export` 方法 |
| 实体 Excel 列 | `SysPost` 上的 `@Excel` 注解 |
| 前端导出按钮 | `ruoyi-ui/src/views/system/post/index.vue` 的导出按钮 + `handleExport` |
| 操作日志注解 | 公告 Controller 上已有的 `@Log(title = "通知公告", ...)` |
| 日志列表页面 | 系统监控 → 操作日志（菜单以实际为准） |
| 日志切面（只读） | `ruoyi-framework/.../aspectj/LogAspect.java` |

### 1.3 分支

```bash
git checkout master   # 或导师指定的含 W2 的分支
git pull
git checkout -b feature/你的名字-notice-w3
```

若 W2 尚未合入 master：问导师是「基于 W2 分支继续」还是「先合 W2」。

---

## 2. 必做（P0）与可选（P1）

### P0 必做

| # | 需求 | 验收 |
| --- | --- | --- |
| 1 | 列表支持按「是否置顶」筛选 | 选「置顶」只出 is_top=1；选「否」只出 0；清空=全部 |
| 2 | 后端查询条件生效 | Network 请求带 `isTop`（或约定参数）；SQL 有对应条件，**不是只前端 filter** |
| 3 | 公告导出 Excel | 管理员可下载；文件中含置顶列 |
| 4 | 导出权限 | 权限字符 `system:notice:export`；无权限按钮不可见或不可用，**直调接口 403** |
| 5 | 操作日志说明 | 书面回答：自己一次「修改公告」在日志里的标题/操作类型/操作人；`@Log` 写在哪个方法上 |
| 6 | 模块说明 Markdown | 表字段 + 接口表 + 权限字符表（见第 7 节模板） |

### P1 可选（导师裁剪）

| # | 需求 |
| --- | --- |
| 7 | 查询区增加「状态」筛选（若后端 XML 已支持 `status` 而前端没有） |
| 8 | 只读安全观摩：未登录访问 swagger-ui / druid 的现象 + 生产建议（**不改代码**，见任务池 P01） |
| 9 | 本地 `mvn -pl ruoyi-admin -am test` 或文档化「我跑了哪些命令」（工程向） |
| 10 | 为导出或查询补一个很简单的测试骨架（先问导师放哪） |

---

## 3. 强制流程：第 1 天先交设计

复制发给导师：

```markdown
## W3 设计（你的名字）

### 基线
- 当前 master/分支是否已有 is_top：是/否
- 基于分支：

### 筛选
- 参数名：isTop（char 0/1）
- Mapper：在 selectNoticeList 增加 <if test="isTop != null and isTop != ''"> AND is_top = #{isTop}

### 导出
- URL：POST /system/notice/export（对照 post）
- 权限：system:notice:export
- 菜单：在通知公告菜单下增加 F 类型按钮（SQL 草稿附后）
- Excel 列：...

### 日志
- 计划操作：修改一条公告置顶
- 将在「操作日志」中截图/记录

### 不做
- DataScope、JWT、已读模块大改

### 风险
- 菜单 SQL 仅本地执行；角色需分配新按钮权限后 admin 以外账号才有导出
```

**导师 OK 前不要大批量写导出与菜单 SQL。** 可先读 post 导出代码。

---

## 4. 按天执行计划

### 第 1 天：回归 W2 + 读样板 + 交设计 + 日志初探

1. 确认置顶功能仍可用（若没有，先找导师）。  
2. 手动改一条公告，打开 **系统监控 → 操作日志**（路径以菜单为准），找到自己的操作。  
3. 打开 `SysNoticeController`，标出哪些方法有 `@Log`。  
4. 打开 `SysPostController.export` 与岗位前端导出，画「导出调用链」三行笔记。  
5. 提交 W3 设计。

#### 第 1 天交付

- 设计说明  
- 操作日志初探笔记（可并入第 5 天正式说明）

---

### 第 2 天：置顶筛选（前后端）

1. 确认 `SysNotice` 已有 `isTop`；查询对象能带到 Mapper。  
2. `SysNoticeMapper.xml` 的 `selectNoticeList` 增加 `is_top` 条件（**用 `#{}`，不要 `${}`**）。  
3. 前端查询区加「是否置顶」下拉；`queryParams` 增加字段；重置时清空。  
4. Network 确认请求参数；切换筛选结果正确。  
5. 回归：标题、类型等原有筛选仍可用。

#### 第 2 天自检

- [ ] 筛选置顶 / 不置顶 / 全部三种正确  
- [ ] 条件在 SQL 层，不是只在前端 filter 当前页  

---

### 第 3 天：导出后端 + Excel 列

1. 对照 `SysPost`，在 `SysNotice` 需要导出的字段上加 `@Excel`（注意字典/0-1 可用 `readConverterExp`）。  
2. Controller 增加 `export`：  
   - `@PreAuthorize("@ss.hasPermi('system:notice:export')")`  
   - `@Log(title = "通知公告", businessType = BusinessType.EXPORT)`  
   - `ExcelUtil` 导出（对照 post）  
3. Service 复用 `selectNoticeList`（导出前是否 `startPage`：对照 post——导出通常查列表、注意是否清分页，按样板来）。  
4. 用管理员 Swagger/前端（前端可第 4 天再接）先测后端。

#### 第 3 天自检

- [ ] 导出接口存在且有权限注解 + `@Log`  
- [ ] 文件中能看到置顶列  

---

### 第 4 天：菜单权限 SQL + 前端导出按钮

1. **本地** `sys_menu` 增加按钮（示例结构，**menu_id 勿与现网冲突**，以你库 max(menu_id)+1 为准）：

```sql
-- 示例：parent_id = 通知公告菜单 id（常见 107，以你库为准）
-- perms = system:notice:export，menu_type = 'F'
INSERT INTO sys_menu (
  menu_name, parent_id, order_num, path, component, is_frame, is_cache,
  menu_type, visible, status, perms, icon, create_by, create_time, remark
) VALUES (
  '公告导出', 107, 5, '', '', 1, 0,
  'F', '0', '0', 'system:notice:export', '#', 'admin', sysdate(), '通知公告导出'
);
```

2. 超级管理员一般拥有全部权限；**普通测试角色**需在角色管理中勾选新按钮。  
3. 前端：对照 post 增加导出按钮 `v-hasPermi="['system:notice:export']"` + `handleExport`（`this.download('system/notice/export', {...})` 形式以项目为准）。  
4. 自测：有权限能下；无权限账号直调 **403**。

#### 第 4 天自检

- [ ] 菜单 SQL 写入 PR  
- [ ] 按钮权限字符前后端一致  
- [ ] 403 测过  

---

### 第 5 天：操作日志成文 + 模块 README + PR

1. 完整走一遍：筛选 → 修改 → 导出 → 打开操作日志核对 INSERT/UPDATE/EXPORT。  
2. 写操作日志说明（第 6 节）。  
3. 写模块说明（第 7 节）。  
4. 按第 8 节自测清单打勾，提 PR。

---

## 5. 实现检查清单

### 筛选

- [ ] 前端查询 + 重置  
- [ ] Mapper `#{}` 条件  
- [ ] 与置顶排序共存（先筛后排）  

### 导出

- [ ] `@Excel` 列含置顶  
- [ ] `@PreAuthorize` + `@Log` EXPORT  
- [ ] 菜单按钮 SQL + 角色可分配  
- [ ] 前端按钮与 download  

### 文档与日志

- [ ] 操作日志说明 4 问已答  
- [ ] 模块 README 三张表齐全  
- [ ] 无密钥进 Git  

---

## 6. 作业：操作日志说明（复制填写）

```markdown
# W3 操作日志说明

姓名：
日期：

## 1. 我做了什么操作（业务）
（例如：把某公告改为置顶 / 导出一次）

## 2. 在系统哪里看到日志
- 菜单路径：
- 日志里的「系统模块 / 操作类型 / 操作人员 / 操作时间」：

## 3. 对应代码
- Controller 方法名：
- 上面的 @Log 注解内容：
- （可选）LogAspect 的作用一句话：

## 4. 若去掉 @Log 会怎样？
（预期：业务仍可能成功，但操作日志没有这条——你是否验证了？）

## 5. 截图或打码记录
```

---

## 7. 作业：模块说明模板（复制填写）

```markdown
# 通知公告模块说明（W3）

## 1. 表 sys_notice 主要字段
| 字段 | 含义 | 备注 |
| --- | --- | --- |
| notice_id | 主键 |  |
| notice_title | 标题 |  |
| notice_type | 类型 | 1通知 2公告 |
| status | 状态 |  |
| is_top | 是否置顶 | W2 新增 |
| ... |  |  |

## 2. 接口表
| 方法 | URL | 权限字符 | 说明 |
| --- | --- | --- | --- |
| GET | /system/notice/list | system:notice:list | 列表（含筛选） |
| POST | /system/notice | system:notice:add | 新增 |
| PUT | /system/notice | system:notice:edit | 修改 |
| DELETE | /system/notice/{ids} | system:notice:remove | 删除 |
| POST | /system/notice/export | system:notice:export | 导出（W3） |

## 3. 权限与菜单
| 权限字符 | 菜单/按钮 |
| --- | --- |
| system:notice:list | 通知公告菜单 |
| system:notice:export | 公告导出按钮（W3） |

## 4. 与 W2/W3 的关系
- W2：置顶字段与排序
- W3：筛选、导出、日志说明、本文档
```

---

## 8. 自测步骤（写进 PR）

1. 启动四件套；确认 `is_top` 存在。  
2. 列表：筛选置顶 / 不置顶 / 全部。  
3. 修改一条公告 → 操作日志中有记录。  
4. 管理员导出 → 打开 Excel 见置顶列。  
5. 无 `system:notice:export` 用户：按钮不可用/不可见；直调导出 **403**。  
6. 回归：新增/删除/原有类型筛选。  

---

## 9. PR 描述模板

```markdown
## 做了什么
- 公告支持按置顶筛选
- 公告导出 Excel + system:notice:export
- 操作日志说明与模块 README（链接或附文件）

## 菜单 SQL
```sql
-- 你的 SQL
```

## 权限字符
- system:notice:export（新增）

## 自测
- [ ] 筛选
- [ ] 导出
- [ ] 导出 403
- [ ] 操作日志可对应 @Log
```

---

## 10. 验收标准（导师）

- [ ] P0 全部满足（或书面裁剪）  
- [ ] 筛选在 SQL 层  
- [ ] 导出权限与 403  
- [ ] 操作日志说明合格  
- [ ] 模块说明合格  
- [ ] Code Review：无 `${}` 拼接用户输入、无密钥、未去 PreAuthorize  

---

## 11. 常见坑

| 坑 | 处理 |
| --- | --- |
| 筛选只在前端 filter | 换页错误；必须 Mapper 条件 |
| 导出 404 | 路径/方法与前端 download 不一致 |
| 导出 403 连 admin 也 403 | 菜单 SQL 未执行或缓存/需重新登录加载权限 |
| Excel 中文乱码/列空 | `@Excel` 未加在 getter 可识别位置；对照 SysPost |
| menu_id 冲突 | 用 `SELECT MAX(menu_id) FROM sys_menu` |
| 普通角色仍能导出 | 角色里勾了导出或拥有 `*:*:*` |

---

## 12. 求助模板

```text
任务：W3 第 X 天
现象：
已尝试：
是否已执行菜单 SQL：是/否
角色是否勾选 system:notice:export：
报错全文：
```

---

## 13. 完成后

→ 第 4 周：[W4-demo-and-wrapup.md](./W4-demo-and-wrapup.md)（Demo + 笔记收口）  
加分方向仍见 [04-task-pool.md](../04-task-pool.md)（DataScope、安全结对等）。
