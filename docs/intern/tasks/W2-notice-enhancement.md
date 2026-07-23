# 任务书 W2：通知公告小增强（垂直切片）

> **前置：** 已通过 [W1](./W1-login-and-user-list.md)（环境能登录、能讲清登录与权限基本概念）。  
> **零基础说明：** 这是你第一次改「真功能」。原则是 **模仿现有公告代码，加一个小字段**；不要重写整个模块，不要「顺便重构」。  
> 概念复习：[07-zero-basics.md](../07-zero-basics.md) 第 2、6 节（请求链路与权限）

| 项 | 内容 |
| --- | --- |
| 阶段 | 第 2 周 |
| 难度 | ★★ |
| 建议工期 | **5 个工作日**（第 1 天只做设计，第 5 天联调与 PR） |
| 分支 | `feature/<你的名字>-notice-enhance`（从最新 `master` 拉出） |
| 基线 | `master` |
| 任务池 ID | T10 |
| 本周范围（默认） | **只做 P0：置顶**；筛选/过期为加分，需导师同意再做 |

---

## 0. 大白话：你要交付什么？

系统里已有 **通知公告**（菜单：**系统管理 → 通知公告**）。  
你要给公告增加 **「是否置顶」** 能力：

| 能力 | 用户能感知到什么 |
| --- | --- |
| 数据 | 公告可以标记为「置顶 / 不置顶」，能保存到数据库 |
| 列表排序 | 置顶的公告排在前面 |
| 管理端 UI | 列表能看到是否置顶；新建/编辑表单能改 |
| 权限 | 没有公告编辑权限的人，即使用接口硬调也改不了（**HTTP 403**，不是只藏按钮） |

**一句话验收：** 管理员能把公告 B 置顶并看到 B 排在 A 前面；无权限用户直调编辑接口得到 403。

### 本周明确不要做

| 不要做 | 为什么 |
| --- | --- |
| 改 JWT / `TokenService` 密钥逻辑 | 与本任务无关，风险高 |
| 大改 `SecurityConfig` | 第 2 周不做全局安全改造 |
| **去掉** `@PreAuthorize` 图省事 | **验收直接不合格** |
| 改「已读」相关（`isRead` / `SysNoticeRead`） | 那是另一套能力，本周只做**置顶** |
| 在共享/生产库用代码生成器乱建表 | 仅限你自己的本地库实验 |
| 无关模块「顺便重构」、大规模格式化 | PR 难 Review |

### 推荐默认设计（导师未另行说明时按此做）

| 项 | 推荐默认 |
| --- | --- |
| 表 | `sys_notice` |
| 字段名 | `is_top` |
| 类型 | `char(1)` |
| 含义 | `'0'` = 不置顶，`'1'` = 置顶 |
| 默认值 | `'0'` |
| 列表排序 | `ORDER BY is_top DESC, notice_id DESC`（先置顶，再按原 id 新在前） |
| 权限 | **复用**已有 `system:notice:edit`（新增/修改时带上字段即可），**不新建**权限字 |
| 前端展示 | 列表一列「是/否」或标签；表单用 `el-switch` 或下拉（与页面现有风格一致） |

> 注意：实体里可能已有 **`isRead`（是否已读）**，和置顶无关。置顶请用新字段 **`isTop` / `is_top`**，不要复用 `isRead`。

---

## 1. 范围（必须遵守）

### 1.1 允许改的地方（优先只在这些路径内搜索）

| 层 | 可能路径（以仓库实际为准） |
| --- | --- |
| 后端 Controller | `ruoyi-admin/.../controller/system/SysNoticeController.java` |
| 后端 Domain | `ruoyi-system/.../domain/SysNotice.java` |
| 后端 Service | `ISysNoticeService` / `SysNoticeServiceImpl` |
| 后端 Mapper | `SysNoticeMapper.java` + `SysNoticeMapper.xml` |
| 前端 API | `ruoyi-ui/src/api/system/notice.js` |
| 前端页面 | `ruoyi-ui/src/views/system/notice/` 下 vue 文件（如 `index.vue`） |
| SQL 说明 | 写在 PR 描述里；本地执行 `ALTER TABLE` |

### 1.2 分支怎么建

```bash
git checkout master
git pull
git checkout -b feature/你的名字-notice-enhance
```

---

## 2. 必做功能（P0）与可选（P1）

### P0 必做（默认本周全部要做完）

| # | 需求 | 验收直观标准 |
| --- | --- | --- |
| 1 | 数据上能表示「是否置顶」 | 表有字段；新建/编辑可保存 0/1 |
| 2 | 列表默认置顶在前 | 两条公告，置顶的那条更靠前 |
| 3 | 管理端 UI | 列表能看到置顶状态；表单能改 |
| 4 | 权限 | 无 `system:notice:edit`（或导师指定）时，改公告接口 **403** |

### P1 可选（导师书面同意后再做）

| # | 需求 |
| --- | --- |
| 5 | 列表可按「是否置顶」筛选 |
| 6 | 过期时间（过期后对某端不可见——范围必须先和导师确认） |
| 7 | 保持与现有 `@Log` 操作日志风格一致（通常已有，核对即可） |

**导师可在下达时写明：** 只做 P0 / P0+筛选。实习生不要自行扩大范围。

---

## 3. 强制流程：先设计，后写码（第 1 天）

在写业务代码前，先发 **设计说明** 给导师（聊天即可），等回复 **OK** 再改库改代码。  
（可以先自己把现有公告增删改查点通、把代码读一遍。）

**请复制填写：**

```markdown
## W2 设计（你的名字）

1. 置顶字段：表 sys_notice ，字段名 is_top ，类型 char(1) ，默认值 '0' （若你改了方案请说明原因）
2. 是否需要执行 SQL：是；SQL 草稿：
   ALTER TABLE sys_notice ADD COLUMN is_top char(1) DEFAULT '0' COMMENT '是否置顶（0否 1是）';
3. 列表排序：准备在 SysNoticeMapper.xml 的 list 查询中 ORDER BY is_top DESC, notice_id DESC
4. 权限字符：复用 system:notice:edit （不新建）
5. 前端：列表用 ____ 展示；表单用 switch / select（选一个）
6. 自测账号计划：
   - 管理员：admin
   - 无权限用户：____ （导师提供 / 我自建角色）
7. 明确不做：已读 SysNoticeRead、过期、筛选（若导师要求 P1 再改）
8. 风险：本地库可丢；不会提交密码；不会去掉 @PreAuthorize
```

**导师回复 OK 之前，不要大批量改代码。**

---

## 4. 推荐实现顺序（按天）

### 第 1 天：读懂现有公告 + 交设计

1. 运行系统，在 **通知公告** 里把 **新增 / 修改 / 删除 / 列表 / 查询** 各点一遍。  
2. 打开 `SysNoticeController`，用笔记记录每个接口：

| 方法（你填） | URL | 权限字符 | Service 方法 |
| --- | --- | --- | --- |
| 列表 |  |  |  |
| 详情 |  |  |  |
| 新增 |  |  |  |
| 修改 |  |  |  |
| 删除 |  |  |  |

3. 打开前端 `ruoyi-ui/src/views/system/notice/` 与 `api/system/notice.js`，找到 list / add / update 调用。  
4. 打开 `SysNotice.java`、`SysNoticeMapper.xml`，看现有字段（如 `status`）在 XML 里怎么写的——**后面照猫画虎加 is_top**。  
5. 提交设计，等导师确认。

**零基础提示：** 先复制 `status` 在实体、XML insert/update/select 里出现的位置，再并列加 `isTop`/`is_top`，比凭空想字段映射更不容易错。

#### 第 1 天结束自检

- [ ] 公告 CRUD 手动点通过  
- [ ] 接口权限表已记  
- [ ] 设计已发出且等待/已获 OK  

---

### 第 2 天：数据库 + 后端 Domain / Mapper

1. 在**本地**库执行导师确认过的 `ALTER TABLE`（先确认这是可丢的学习库）。  
2. 确认字段：

```sql
-- 示例：执行后检查
DESC sys_notice;
-- 或
SHOW COLUMNS FROM sys_notice LIKE 'is_top';
```

3. Java 实体 `SysNotice` 增加字段 + getter/setter（风格与类里其他字段一致；注意与 `isRead` 区分）。  
4. Mapper XML：  
   - `resultMap` / 查询列带上 `is_top`  
   - `insert` / `update` 带上新字段  
   - 列表查询 `order by` 改为置顶优先（与设计一致）  
5. 若 Service 只是透传，可能几乎不用改；有特殊逻辑再动。  
6. 用 Swagger 或前端临时测：保存后查库字段是否变化。

```sql
SELECT notice_id, notice_title, is_top FROM sys_notice ORDER BY is_top DESC, notice_id DESC;
```

#### 第 2 天结束自检

- [ ] 库表有 `is_top`  
- [ ] 实体与 XML 查询/写入已带字段  
- [ ] 排序 SQL 已改（不是只在前端 sort）  

---

### 第 3 天：Controller / 权限 / 后端自测

1. 打开 `SysNoticeController`，确认 **新增、修改** 仍有：  
   `@PreAuthorize("@ss.hasPermi('system:notice:add')")`  
   `@PreAuthorize("@ss.hasPermi('system:notice:edit')")`  
   等注解——**不要删除、不要注释掉**。  
2. 参数：置顶值按设计只接受 `0`/`1`（或与项目一致的布尔映射）；非法值可按项目习惯忽略或校验。  
3. 自测后端：  
   - 管理员可新增/修改带 `isTop` 的公告；  
   - 列表顺序置顶在前；  
   - 准备无权限账号（见第 6 节）直调修改接口 → **403**。

#### 第 3 天结束自检

- [ ] `@PreAuthorize` 仍在  
- [ ] 管理员改置顶成功  
- [ ] 无权限 403 至少测过一次（可用 Swagger/Apifox/curl）  

---

### 第 4 天：前端

1. `api/system/notice.js`：保证提交/查询对象能带上置顶字段（若本来透传 `data`，有时只需改页面表单字段）。  
2. 列表页：加一列显示置顶（文案「是/否」或 Element 标签）。  
3. 表单：加开关或下拉，绑定 `isTop`（字段名与后端 JSON 一致，注意驼峰）。  
4. 若做 P1 筛选：查询区加下拉，查询参数与后端 query 对象对齐。  
5. 按钮上的 `v-hasPermi` 与后端权限字符核对（有则保持一致）。  
6. 保存后刷新列表，核对顺序与显示。

#### 第 4 天结束自检

- [ ] 列表能看见置顶列  
- [ ] 表单能改并保存  
- [ ] 刷新后顺序仍正确  

---

### 第 5 天：联调、自测、提 PR

1. 按第 6 节自测步骤 **全部走完**（建议边做边打勾）。  
2. 检查 `git diff`：无密码、无无关大格式化。  
3. 填写 PR 描述（第 7 节模板）。  
4. 请导师 Review；准备 5～10 分钟现场 Demo。

```bash
git status
git diff
git add <相关文件>
git commit -m "feat: 通知公告支持置顶排序"
# push 与提 PR 按团队规范
```

---

## 5. 实现检查清单（自己合并前勾选）

### 后端

- [ ] 表字段 / 实体字段一致（`is_top` ↔ `isTop`）  
- [ ] Mapper XML 查询、写入、排序已改  
- [ ] 未误改 `isRead` / `SysNoticeRead`  
- [ ] Controller 权限注解仍在  
- [ ] PR 中附可重复执行的 SQL  

### 前端

- [ ] 列表显示置顶  
- [ ] 表单可编辑置顶  
- [ ] 保存后刷新列表数据与顺序正确  
- [ ] （可选）筛选可用  

### 安全与工程

- [ ] 无权限 403 已测  
- [ ] diff 中无密码、无 token  
- [ ] 无大规模无关格式化  
- [ ] 分支名正确，从 master 拉出  

---

## 6. 自测步骤（请原样写进 PR，并自己先走通）

1. 确认本地已执行本任务 SQL（`is_top` 存在）。  
2. 启动 Redis、MySQL、后端、前端。  
3. 管理员登录 → **系统管理 → 通知公告**。  
4. 新建公告 A（不置顶）、B（置顶）→ 保存。  
5. 列表中 B 应在 A 前（或按你 PR 声明的规则）。  
6. 修改 A 为置顶 → 顺序变化符合预期。  
7. 使用**无公告编辑权限**的用户：  
   - 界面上编辑入口应不可用或不可见；  
   - 用浏览器 / Swagger **直调**修改接口 → 期望 **403**。  
8. 回归：删除、按标题查询、原有类型/状态字段仍可用。  

### 无权限账号怎么来？（零基础）

任选其一（优先问导师要现成的）：

| 方式 | 做法 |
| --- | --- |
| 导师预置 | 使用导师给的「无 notice 编辑权」账号 |
| 自己建（需有角色菜单权限） | 系统管理 → 角色：新建角色，**不要**勾选通知公告的「修改」按钮权限；再新建用户绑定该角色 |
| 临时验证思路 | 有权限账号测功能；无权限用另一浏览器/无痕 + 该用户 Token 调接口 |

**不要**为了测 403 而注释掉 `@PreAuthorize`。

---

## 7. PR 描述模板（复制填写）

```markdown
## 做了什么
- 通知公告支持置顶：列表置顶优先；表单可编辑 isTop

## 表结构变更
```sql
ALTER TABLE sys_notice ADD COLUMN is_top char(1) DEFAULT '0' COMMENT '是否置顶（0否 1是）';
```

## 权限字符
- 复用：system:notice:edit / system:notice:add（未新建权限字）

## 自测结果
- [ ] 管理员置顶与排序
- [ ] 无权限 403
- [ ] 回归增删改查
- [ ] 未改动 JWT/SecurityConfig/已读模块

## 截图（可选）
```

---

## 8. 验收标准（导师）

- [ ] P0 全部满足（或导师书面裁剪后的范围）  
- [ ] PR 含 SQL、自测、权限说明  
- [ ] Code Review 通过（分层、权限、无密钥、未误伤 isRead）  
- [ ] 可现场 Demo 5～10 分钟（含一次 403 说明）  

---

## 9. 常见坑（零基础高频）

| 坑 | 处理 |
| --- | --- |
| 只改了前端，数据库没字段 | 先改库和后端，再改前端 |
| 只改了实体，XML 没改 | 列表永远查不出新字段 |
| 排序只在前端 sort | 换页后顺序错；**本任务要求 SQL 层 order by** |
| 去掉 `@PreAuthorize` 图省事 | **验收不合格** |
| 把置顶做成改 `isRead` | 错误；已读 ≠ 置顶 |
| 提交了 `application-druid.yml` 密码 | 立刻从提交中去掉并轮换密码 |
| 字段驼峰/下划线不一致 | 对照项目现有 `notice_title` ↔ `noticeTitle` 映射方式 |
| 一次 PR 改了 20 个无关文件 | 撤回无关改动，保持小 PR |

---

## 10. 求助模板

```text
任务：W2 第 X 天
现象：
已尝试：（含是否已执行 ALTER、XML 是否改了 order by）
期望：
实际：
报错全文 / 截图说明：
```

---

## 11. 完成后的可选延伸（第 3 周，勿与本周 P0 混做）

- 读审计文档 SEC-010：公告富文本与 XSS 注意点（只写笔记，可不改代码）  
- 尝试为 notice 查询加一个很简单的测试骨架（问导师测试放哪）  
- 若导师同意：P1 按置顶筛选  

下一阶段任务由导师从 [04-task-pool.md](../04-task-pool.md) 指定；没有新任务书时用 [03-task-template.md](../03-task-template.md) 下达。
