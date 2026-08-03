# 任务书 W9：工单流转、协作与并发控制

> **前置要求：** [W8-ticket-center-mvp.md](./W8-ticket-center-mvp.md) 已通过并合入基线；工单 CRUD、权限和 DataScope 可重复验证。
> **本周定位：** 把静态 CRUD 升级为有业务规则的协作系统。重点是状态机、事务、幂等和并发，不是多画几个按钮。
> **配套规范：** [数据库迁移](../../guides/database-migrations.md) · [测试策略](../../guides/testing-strategy.md) · [研发协作流程](../../guides/development-workflow.md)

| 项 | 内容 |
| --- | --- |
| 阶段 | 全栈毕业项目第 2 周 |
| 难度 | ★★★★ |
| 建议工期 | 5 个工作日 |
| 基线分支 | 已合入 W8 的分支 |
| 建议分支 | `feature/<name>-ticket-workflow` |
| 任务池映射 | T26 + T27 |
| 后续任务 | [W10-ticket-attachments-notifications-audit.md](./W10-ticket-attachments-notifications-audit.md) |

---

## 0. 本周交付结果

工单创建人可以提交工单，处理人可以领取、处理和解决，创建人可以确认关闭或重新打开；参与者可以评论，详情页能按时间展示流转和评论记录。

本周必须解决四类真实后端问题：

1. 非法状态跳转不能只靠前端隐藏按钮。
2. 一次操作写多张表时必须保持事务一致。
3. 重复点击或请求重试不能重复产生流转记录。
4. 两个人同时修改时不能静默覆盖彼此的数据。

### 本周明确不做

| 不做 | 原因 |
| --- | --- |
| 通用 BPM/审批引擎 | 工单状态有限，先手写可测试的领域规则 |
| WebSocket 实时推送 | W10 先做可靠站内通知 |
| 附件与外部邮件/短信 | W10 再做 |
| 把所有状态判断写进 Vue | 后端必须是规则唯一来源 |
| 用全局锁包住全部请求 | 用状态条件、唯一约束和乐观锁解决 |

---

## 1. 默认角色与状态机

### 1.1 业务参与者

| 参与者 | 默认能力 |
| --- | --- |
| 创建人 | 编辑/删除草稿、提交、评论、确认关闭、重新打开 |
| 处理人 | 领取或被分派后开始处理、评论、标记已解决 |
| 工单管理员 | 查看范围内工单、分派、转交、驳回 |
| 非参与者 | 仅在数据范围和查询权限允许时查看；不能执行流转 |

“有菜单权限”不等于“是该工单参与者”。每个动作必须同时校验方法权限、数据范围、当前状态和参与者身份。

### 1.2 默认状态

```text
DRAFT --submit--> PENDING
PENDING --claim/assign--> PROCESSING
PENDING --reject--> REJECTED
PROCESSING --resolve--> RESOLVED
RESOLVED --close--> CLOSED
RESOLVED --reopen--> PROCESSING
```

默认终态：`CLOSED`、`REJECTED`。终态禁止编辑正文和继续流转。

### 1.3 动作规则

| 动作 | 起始状态 | 目标状态 | 谁可以做 |
| --- | --- | --- | --- |
| `SUBMIT` | DRAFT | PENDING | 创建人 |
| `CLAIM` | PENDING | PROCESSING | 有处理权限且尚无处理人 |
| `ASSIGN` | PENDING/PROCESSING | PROCESSING | 工单管理员 |
| `TRANSFER` | PROCESSING | PROCESSING | 当前处理人或工单管理员 |
| `REJECT` | PENDING | REJECTED | 工单管理员 |
| `RESOLVE` | PROCESSING | RESOLVED | 当前处理人 |
| `CLOSE` | RESOLVED | CLOSED | 创建人或工单管理员 |
| `REOPEN` | RESOLVED | PROCESSING | 创建人或工单管理员 |

接口不能接收任意 `targetStatus`。请求只表达动作，由后端根据动作和当前状态决定目标状态。

---

## 2. 数据模型增量

### 2.1 `biz_ticket` 增量

- 使用 W8 已预留的 `handler_id`、`status`、`version`。
- 可增加 `submitted_time/resolved_time/closed_time`，但必须说明为何不能只从流转表推导。
- 更新语句使用 `ticket_id + version + 当前 status` 作为条件。

### 2.2 流转记录 `biz_ticket_flow`

| 字段 | 说明 |
| --- | --- |
| `flow_id` | 主键 |
| `ticket_id` | 工单 ID，建立普通索引 |
| `request_id` | 客户端操作 ID，同一工单内唯一 |
| `action` | SUBMIT/CLAIM/ASSIGN 等 |
| `from_status/to_status` | 流转前后状态 |
| `operator_id/operator_name` | 操作人快照 |
| `from_handler_id/to_handler_id` | 涉及分派时记录 |
| `comment` | 驳回、解决、重开等动作说明 |
| `create_time` | 操作时间 |

唯一约束建议：`uk_ticket_request(ticket_id, request_id)`，用于拦截同一动作的重复提交。

### 2.3 评论 `biz_ticket_comment`

| 字段 | 规则 |
| --- | --- |
| `comment_id` | 主键 |
| `ticket_id` | 工单 ID，索引 |
| `content` | 必填，1～1000 字；普通文本 |
| `creator_id/create_by/create_time` | 从登录态取得 |
| `del_flag` | 逻辑删除 |

评论人只能删除自己的评论；工单终态是否允许评论，默认不允许。

### 2.4 SQL 交付

```text
sql/migrations/V002__ticket_workflow.sql
sql/migrations/U002__ticket_workflow.sql
```

正向脚本包含字典状态增量、表、索引、唯一约束和菜单权限；回滚脚本不能删除 W8 基础表和基础字典。

---

## 3. 接口与权限契约

### 3.1 流转接口

| 动作 | 方法与路径 | 权限字符 |
| --- | --- | --- |
| 提交 | `PUT /ticket/ticket/{id}/submit` | `ticket:ticket:submit` |
| 领取 | `PUT /ticket/ticket/{id}/claim` | `ticket:ticket:handle` |
| 分派 | `PUT /ticket/ticket/{id}/assign` | `ticket:ticket:assign` |
| 转交 | `PUT /ticket/ticket/{id}/transfer` | `ticket:ticket:assign` |
| 驳回 | `PUT /ticket/ticket/{id}/reject` | `ticket:ticket:assign` |
| 解决 | `PUT /ticket/ticket/{id}/resolve` | `ticket:ticket:handle` |
| 关闭 | `PUT /ticket/ticket/{id}/close` | `ticket:ticket:close` |
| 重开 | `PUT /ticket/ticket/{id}/reopen` | `ticket:ticket:close` |

每个写请求至少包含 `requestId` 和当前 `version`；需要说明的动作再带 `comment` 或 `handlerId`。

### 3.2 评论与时间线

| 能力 | 方法与路径 | 权限字符 |
| --- | --- | --- |
| 时间线 | `GET /ticket/ticket/{id}/timeline` | `ticket:ticket:query` |
| 新增评论 | `POST /ticket/ticket/{id}/comments` | `ticket:comment:add` |
| 删除本人评论 | `DELETE /ticket/comment/{commentId}` | `ticket:comment:remove` |

时间线响应由后端输出稳定 DTO，至少包含 `type/action/operator/content/time`。前端不直接依赖数据库字段名拼装业务语义。

### 3.3 可执行动作

工单详情响应增加 `availableActions`，由后端依据当前用户和状态计算，例如：

```json
{
  "status": "PROCESSING",
  "version": 3,
  "availableActions": ["TRANSFER", "RESOLVE", "COMMENT"]
}
```

前端用它控制按钮展示，但后端仍必须再次校验，不能把它当授权凭证。

---

## 4. 后端实现约束

### 4.1 状态规则集中管理

使用一个明确的领域服务或状态规则类维护：

- 动作是否支持当前状态。
- 动作要求的参与者身份。
- 目标状态和时间字段。
- 错误消息和稳定错误码。

禁止在 Controller、Service 多处复制 `if (status == ...)` 形成规则漂移。

### 4.2 事务边界

一次流转至少包含：

```text
校验权限/参与者/当前状态
  → 条件更新 biz_ticket
  → 插入 biz_ticket_flow
  → 提交事务
```

任一步失败必须整体回滚。不能出现状态已改变但流转记录缺失，或流转记录存在但工单未改变。

### 4.3 乐观锁

更新影响行数为 0 时，区分“不存在/无权访问”和“版本或状态冲突”。并发冲突返回明确业务错误，引导前端重新加载详情，禁止自动覆盖。

### 4.4 幂等

- 前端每次动作生成新的 `requestId`，重试时沿用同一个 ID。
- 后端依赖唯一约束兜底，不能只先查再插。
- 重复请求返回第一次操作的最终结果或明确“已处理”，不得再写记录。

---

## 5. 前端交互要求

详情页至少包含：

1. 基础信息和当前状态。
2. 创建人、处理人、部门和关键时间。
3. 后端返回的可执行动作按钮。
4. 分派/转交人员选择对话框。
5. 驳回、解决、重开原因输入框。
6. 流转与评论合并时间线。
7. 评论输入和删除本人评论。
8. 并发冲突提示与“重新加载”操作。

要求：

- 动作提交期间对应按钮禁用且尺寸不跳动。
- 关闭对话框前清理校验和旧数据。
- 失败后保留用户已输入的说明，方便重试。
- 状态、动作、优先级用字典标签或明确图标，不能只靠颜色区分。
- 浏览器刷新后以服务端状态为准，不能只更新本地对象假装成功。

---

## 6. 强制设计评审（第 1 天）

编码前提交：

- 状态图和动作矩阵。
- 每个动作的权限、参与者、起止状态和失败情况。
- 两张新增表及索引/唯一约束。
- 事务时序图。
- 两个并发请求的预期结果。
- 时间线响应示例。
- 页面动作区和时间线草图。
- 正向、回滚 SQL 顺序。

导师重点确认：状态规则是否只有一个来源、幂等是否有数据库约束、是否存在绕过参与者校验的接口。

---

## 7. 推荐执行顺序

### 第 1 天：规则与设计

- 回归 W8 CRUD、权限和 DataScope。
- 完成状态图、动作矩阵、ER、接口与并发方案。

### 第 2 天：表与状态服务

- 执行 V002，完成流转/评论 Mapper。
- 实现集中状态规则和 `availableActions`。

### 第 3 天：事务、幂等与接口

- 完成流转事务、乐观锁、requestId 唯一约束处理。
- 用两个并发请求验证只有一个成功。

### 第 4 天：详情、动作与时间线

- 完成前端详情、动作对话框、评论和时间线。
- 处理加载、提交、冲突和空时间线状态。

### 第 5 天：端到端回归

- 走完一张工单从草稿到关闭、重开的完整路径。
- 验证重复请求、并发冲突、越权和事务回滚。
- 验证 U002 不破坏 W8 基础能力。

---

## 8. 必测矩阵

| 场景 | 预期 |
| --- | --- |
| 创建人提交草稿 | PENDING，新增一条 SUBMIT 记录 |
| 再次提交同一 requestId | 不新增记录，不重复变更版本 |
| 对 PENDING 调用 resolve | 拒绝，状态和流转表均不变 |
| 两人同时领取同一工单 | 只有一人成功，另一人收到冲突 |
| 非管理员分派给他人 | 403 或稳定业务拒绝 |
| 当前处理人解决 | RESOLVED，记录原因和完成时间 |
| 非创建人关闭 | 拒绝，除非具备管理员规则 |
| 版本过期执行动作 | 冲突提示，要求重新加载 |
| 流转记录插入异常 | 工单状态更新回滚 |
| 非参与者评论 | 按默认规则拒绝 |
| 评论含脚本标签 | 作为普通文本显示，不执行脚本 |
| U002 回滚 | W9 表和权限清理，W8 CRUD 仍可使用 |

---

## 9. 验收标准

- [ ] 状态图、动作矩阵与代码行为一致。
- [ ] 所有状态变化只通过动作接口发生。
- [ ] 非法跳转和参与者越权均有后端校验。
- [ ] 状态更新与流转记录处于同一事务。
- [ ] 重复 requestId 不产生重复副作用。
- [ ] 并发领取/处理不会发生静默覆盖。
- [ ] `availableActions` 由后端计算，前端不复制整套规则。
- [ ] 时间线按稳定 DTO 展示流转和评论。
- [ ] 关键写操作有 `@PreAuthorize` 和 `@Log`。
- [ ] 正向/回滚 SQL、构建命令和三账号回归有真实结果。

---

## 10. 技术笔记与 PR

技术笔记写入 `docs/intern/notes/W9-ticket-workflow.md`：

1. 为什么接口接收动作而不是目标状态。
2. 乐观锁的 SQL 条件和失败处理。
3. requestId + 唯一约束如何保证幂等。
4. 一次流转事务涉及哪些写入。
5. `availableActions` 为什么不能替代后端权限校验。
6. 一次真实并发测试的请求、响应和数据库结果。

PR 至少包含：状态图、迁移/回滚脚本、权限表、自测矩阵、并发证据、页面截图和明确未做项。

---

## 11. 常见坑与求助

| 坑 | 修正方向 |
| --- | --- |
| 前端改了状态但刷新恢复 | 必须调用动作 API，以服务端结果为准 |
| 先查 requestId 再插仍重复 | 增加数据库唯一约束并处理冲突 |
| `@Transactional` 不生效 | 检查是否同类自调用、异常是否被吞掉 |
| 并发时两人都领取成功 | 更新 SQL 必须带 version、status、handler 条件 |
| 管理员权限替代业务身份 | 方法权限与参与者校验是两层规则 |
| 时间线顺序不稳定 | 使用时间 + 主键作为稳定排序 |

求助时附：动作、当前状态、当前用户身份、requestId/version、请求响应、更新影响行数、事务日志和相关两张表数据。
