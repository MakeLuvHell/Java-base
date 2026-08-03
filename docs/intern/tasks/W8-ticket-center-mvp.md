# 任务书 W8：工单中心 MVP（独立全栈模块）

> **前置要求：** 已通过 W1～W7，能独立跟踪一次列表请求，完成前后端字段、权限字符和 SQL 的对齐。
> **本周定位：** 从“修改现有模块”升级为“从零交付一个可运行的小业务模块”。本周只做工单基础闭环，不提前实现流转、评论、附件和通知。
> **配套规范：** [研发协作流程](../../guides/development-workflow.md) · [数据库迁移](../../guides/database-migrations.md) · [测试策略](../../guides/testing-strategy.md)

| 项 | 内容 |
| --- | --- |
| 阶段 | 全栈毕业项目第 1 周 |
| 难度 | ★★★ |
| 建议工期 | 5 个工作日 |
| 基线分支 | `master`（或导师指定的已合入 W1～W7 分支） |
| 建议分支 | `feature/<name>-ticket-mvp` |
| 任务池映射 | T25 + T20 |
| 后续任务 | [W9-ticket-workflow-collaboration.md](./W9-ticket-workflow-collaboration.md) |

---

## 0. 本周交付结果

在系统中新增一级菜单“工单中心”。有权限的用户可以创建工单、查看数据范围内的工单、修改自己的草稿、查看详情和删除自己的草稿；无权限用户直调接口必须返回 403。

本周结束时必须能从浏览器讲清：

```text
工单页面
  → ruoyi-ui API
  → TicketController
  → TicketService
  → TicketMapper
  → biz_ticket
  → 权限字符 + DataScope
```

### 本周明确不做

| 不做 | 原因 |
| --- | --- |
| 审批流、领取、转交、评论 | 放到 W9，避免 MVP 失控 |
| 附件、站内通知、WebSocket | 放到 W10 |
| 微服务、消息队列、工作流引擎 | 当前规模不需要，先练好事务与边界 |
| 直接在共享数据库运行生成器 DDL | 对照 SEC-007，只允许本地库实验 |
| 复制生成代码后不逐行检查 | 本任务考察完整链路，不考察点击生成按钮 |

---

## 1. 默认业务规则

导师未另行说明时，按以下规则实现，不要自行扩大范围。

### 1.1 工单字段

| 字段 | 建议类型 | 规则 |
| --- | --- | --- |
| `ticket_id` | bigint | 主键 |
| `ticket_no` | varchar(32) | 唯一、后端生成，不接受前端指定 |
| `title` | varchar(100) | 必填，去除首尾空格 |
| `description` | text | 必填，按普通文本处理；本周不接富文本 |
| `ticket_type` | varchar(32) | 字典 `biz_ticket_type` |
| `priority` | varchar(16) | 字典 `biz_ticket_priority` |
| `status` | varchar(16) | 本周只允许 `DRAFT` |
| `creator_id` | bigint | 从当前登录用户取得，禁止信任请求体 |
| `dept_id` | bigint | 从当前登录用户取得，用于 DataScope |
| `handler_id` | bigint | 本周为空，W9 使用 |
| `version` | int | 默认 0，为 W9 乐观锁预留 |
| `del_flag` | char(1) | 逻辑删除：0 正常、2 删除 |
| 审计字段 | - | `create_by/create_time/update_by/update_time/remark` |

### 1.2 字典

| 字典类型 | 最小数据 |
| --- | --- |
| `biz_ticket_type` | 故障、咨询、需求 |
| `biz_ticket_priority` | 低、中、高、紧急 |
| `biz_ticket_status` | 草稿；W9 再补其他状态 |

前端必须通过现有字典机制读取选项，禁止在 Vue 文件里再维护一份同名数组。

### 1.3 数据权限

| 角色数据范围 | 应看到的数据 |
| --- | --- |
| 全部数据 | 所有未删除工单 |
| 本部门 | `dept_id` 等于当前部门 |
| 本部门及以下 | 当前部门及子部门 |
| 仅本人 | `creator_id` 等于当前用户 |

列表 Service 使用现有 `@DataScope`，并显式适配工单字段名，例如：

```java
@DataScope(
    deptAlias = "t",
    userAlias = "t",
    deptField = "dept_id",
    userField = "creator_id",
    permission = "ticket:ticket:list"
)
```

查询 SQL 中 `biz_ticket` 的别名必须与注解一致，查询对象需要继承 `BaseEntity`，Mapper 只消费切面生成的 `params.dataScope`。Controller 不允许接收客户端传入的 dataScope SQL。详情、修改、删除也必须走范围内查询或等价的后端可见性校验，不能因它们不是列表接口就退化成无范围的 `selectById`。

### 1.4 写操作边界

- 只有创建人可以修改或删除自己的 `DRAFT` 工单。
- 超级管理员是否可以代改由导师决定；默认只允许查看，不绕过业务所有权规则。
- 修改、删除前必须先按 ID 查询并做所有权、状态和数据范围校验。
- 删除使用逻辑删除，列表和详情都不能返回已删除数据。

---

## 2. 默认技术结构

### 2.1 后端模块

本任务默认新增独立 Maven 模块 `ruoyi-ticket`，用来训练模块边界。

```text
ruoyi-ticket/
├── pom.xml
└── src/main/
    ├── java/com/ruoyi/ticket/
    │   ├── domain/
    │   ├── mapper/
    │   └── service/
    └── resources/mapper/ticket/

ruoyi-admin/src/main/java/com/ruoyi/web/controller/ticket/
```

需要同步：

1. 根 `pom.xml` 的 `modules` 与 `dependencyManagement`。
2. `ruoyi-admin/pom.xml` 对 `ruoyi-ticket` 的依赖。
3. Controller 仍放在 `ruoyi-admin` HTTP 入口层。

若导师明确要求先放在 `ruoyi-system`，可以裁剪模块创建，但 PR 必须说明取舍，不能同时维护两套实现。

### 2.2 前端结构

```text
ruoyi-ui/src/api/ticket/ticket.js
ruoyi-ui/src/views/ticket/ticket/index.vue
ruoyi-ui/src/views/ticket/ticket/detail.vue
```

列表页必须有：搜索、重置、新增、修改、删除、详情、分页、加载态、空态和接口失败提示。表单必须有必填和长度校验，提交期间禁止重复点击。

### 2.3 SQL 交付

新增版本化脚本目录并提交正向、回滚脚本，例如：

```text
sql/migrations/V001__ticket_mvp.sql
sql/migrations/U001__ticket_mvp.sql
```

正向脚本包含业务表、字典和菜单权限；回滚脚本按“菜单 → 字典数据 → 字典类型 → 业务表”的依赖顺序清理。脚本必须注明仅限本地/测试库，并说明是否可重复执行。

---

## 3. 接口与权限契约

| 能力 | 方法与路径 | 权限字符 |
| --- | --- | --- |
| 列表 | `GET /ticket/ticket/list` | `ticket:ticket:list` |
| 详情 | `GET /ticket/ticket/{ticketId}` | `ticket:ticket:query` |
| 新增 | `POST /ticket/ticket` | `ticket:ticket:add` |
| 修改草稿 | `PUT /ticket/ticket` | `ticket:ticket:edit` |
| 删除草稿 | `DELETE /ticket/ticket/{ticketIds}` | `ticket:ticket:remove` |

要求：

- 写接口具有 `@PreAuthorize` 和恰当的 `@Log`。
- 列表接口不记录操作日志，避免普通查询制造噪声。
- Controller 不直接写 Mapper，不在 Controller 中拼业务 SQL。
- 新增请求不接收可信的 `creatorId/deptId/status/version`。
- 批量删除要逐项校验；任一工单不允许删除时，默认整批零写入。
- 前后端权限字符和菜单 SQL 必须完全一致。

---

## 4. 强制设计评审（第 1 天）

编码前提交一页设计，至少包含：

```markdown
# W8 工单中心设计

## ER 与字段
- biz_ticket 字段、索引、唯一约束

## 模块依赖
- ruoyi-admin -> ruoyi-ticket -> ruoyi-common

## 接口表
- 方法、路径、请求、响应、权限字符

## 数据权限
- deptAlias/userAlias/字段名
- 四种数据范围预期

## 页面草图
- 搜索区、按钮区、表格、详情、表单

## SQL 与回滚
- 正向顺序、回滚顺序

## 不做
- W9/W10 的能力明确列出
```

导师未确认前，只允许阅读和画设计，不开始批量生成代码。

---

## 5. 推荐执行顺序

### 第 1 天：建模与设计

- 阅读 `SysNotice`、`SysUser` 和 `ruoyi-quartz` 模块结构。
- 完成 ER、接口、权限和页面草图。
- 准备正向/回滚 SQL 草案。

### 第 2 天：数据库与后端骨架

- 创建 `ruoyi-ticket` 模块并接入 Maven。
- 实现 Domain、Mapper 和基础查询。
- 本地执行迁移并检查索引、唯一约束和默认值。

### 第 3 天：Service、权限与接口

- 实现 CRUD、所有权校验、逻辑删除和 DataScope。
- 用 Swagger/curl 验证成功、403、越权和不存在数据。

### 第 4 天：前端闭环

- 实现 API、列表、详情和表单。
- 接入字典、按钮权限、校验和各种页面状态。

### 第 5 天：回归与 PR

- 从干净库重放正向脚本，再执行一次回滚脚本。
- 使用三类账号跑完验收矩阵。
- 执行后端构建和前端生产构建；失败必须记录真实原因。
- 整理技术笔记和 PR。

---

## 6. 必测矩阵

| 场景 | 预期 |
| --- | --- |
| 有 add 权限创建工单 | 成功；创建人和部门来自登录态 |
| 请求体伪造 `creatorId/deptId/status` | 伪造值不生效 |
| 无 add 权限直调 | 403 |
| 本人修改自己的草稿 | 成功；`update_by/update_time` 更新 |
| A 修改 B 的草稿 | 拒绝且数据库无变化 |
| 修改不存在或已删除工单 | 明确错误，不出现空指针 |
| 删除包含一个无权数据的批次 | 全部不删除 |
| 本部门/仅本人角色查列表 | 只返回范围内数据 |
| 范围外用户猜 ticketId 查详情 | 拒绝，不能仅凭 query 权限读取 |
| 页面重复点击提交 | 只产生一条工单 |
| 回滚 SQL | 本任务新增对象被清理，不误删已有系统数据 |

测试数据至少包含 2 个部门、3 个普通用户、1 个管理员和 6 条跨部门工单。

---

## 7. 验收标准

- [ ] Maven 模块依赖方向清楚，没有循环依赖。
- [ ] 正向和回滚 SQL 均在干净测试库验证。
- [ ] 列表、详情、新增、修改、删除形成前后端闭环。
- [ ] 字典来自系统字典接口，不是前端硬编码。
- [ ] 方法权限、按钮权限和菜单 SQL 一致。
- [ ] 403 与数据范围都使用非管理员账号验证。
- [ ] 伪造创建人/部门无效。
- [ ] 越权批量删除保持零写入。
- [ ] 页面具有 loading、empty、error 和 submitting 状态。
- [ ] PR 无密码、Token、真实生产数据和无关格式化。

---

## 8. 技术笔记（必交）

写入 `docs/intern/notes/W8-ticket-mvp.md`：

1. 为什么新建 `ruoyi-ticket`，它与 `ruoyi-admin` 如何依赖。
2. 一次工单列表请求的完整路径。
3. `@PreAuthorize` 与 `@DataScope` 分别解决什么问题。
4. 为什么创建人和部门不能信任前端。
5. SQL 正向和回滚的执行顺序。
6. 本周遇到的一个真实失败及定位过程。

---

## 9. PR 描述模板

```markdown
## 范围
- W8 工单中心 MVP

## 模块与数据
- Maven 模块：
- 表/索引：
- 正向/回滚 SQL：

## 接口与权限
- 接口：
- 权限字符：
- DataScope：

## 自测
- 管理员：
- 普通用户：
- 无权限用户：
- 越权/异常：
- SQL 重放/回滚：
- 后端/前端构建：

## 截图或请求示例
- 列表：
- 表单：
- 详情：
- 403：

## 未做
- W9 流转协作
- W10 附件通知
```

---

## 10. 常见坑与求助

| 坑 | 检查方向 |
| --- | --- |
| 新模块启动后找不到 Mapper | 根模块、admin 依赖、包名、XML namespace、MapperScan |
| DataScope 不生效 | 查询参数是否继承 `BaseEntity`，别名与字段是否一致 |
| 只隐藏按钮但接口仍可调用 | Controller 是否有正确 `@PreAuthorize` |
| 查询能看到已删除数据 | 每个查询是否带 `del_flag = '0'` |
| 字典显示原始值 | `dicts` 声明、字典类型、值类型是否一致 |

求助时提供：当前分支、目标步骤、最小复现、请求/响应、后端异常首段、相关 SQL、已排查内容。禁止只发“不能运行”。
