# 必读顺序与验收题

按表顺序阅读；不要一次打开全部 audit 文档。

## 阅读顺序

| 顺序 | 材料 | 目的 | 建议时长 |
| --- | --- | --- | --- |
| 0 | [07-zero-basics.md](./07-zero-basics.md) | **零基础必读**：前后端、Token、三层权限大白话 | 1–2 h |
| 0b | [08-local-setup-step-by-step.md](./08-local-setup-step-by-step.md) + [05-environment-checklist.md](./05-environment-checklist.md) | 装环境并打勾（与阅读穿插） | 第 1～2 天 |
| 0c | [09-module-map.md](./09-module-map.md) | 登录后扫菜单：现有模块、计划工单模块及 W1～W12 对应 | 0.5～1 h（可边点边看） |
| 1 | [知识库首页](../README.md) + 根 [README.md](../../README.md) | 区分当前能力 / 目标任务，了解产品功能与技术栈 | 0.5 h |
| 2 | 上游文档 [http://doc.ruoyi.vip](http://doc.ruoyi.vip)（可选） | 官方功能说明 | 1–2 h |
| 3 | [CONTEXT.md](../../CONTEXT.md) | 术语：LoginUser、JWT+Redis、模块边界 | 2–3 h（可先扫） |
| 4 | [docs/audit/01-architecture.md](../audit/01-architecture.md) | 模块依赖、登录/路由/请求链路 | 0.5–1 天 |
| 5 | [研发协作流程](../guides/development-workflow.md) + [Swagger](../guides/api-docs-swagger.md) | 分支 / PR 和带 Token 调试 | 2–3 h（W1 第 5 天） |
| 6 | [docs/audit/02-frontend-ui.md](../audit/02-frontend-ui.md)（扫读） | 前端结构、主题、权限指令观察 | 0.5 天 |
| 7 | [docs/audit/03-security.md](../audit/03-security.md) + [04-remediation-roadmap.md](../audit/04-remediation-roadmap.md) | 风险台账与整改优先级（**后半程**） | 第 2–3 周 |
| 8 | [工程指南索引](../guides/README.md) | 按当前任务选择迁移、测试、CI、发布或运维指南 | 0.5 h（进阶前） |

**第 1 周任务书（边读边做）：** [tasks/W1-login-and-user-list.md](./tasks/W1-login-and-user-list.md)

过程文档（一般**不必**精读）：`docs/superpowers/`（审计设计与执行计划）。

### W8～W12 专项阅读

| 开始阶段 | 必读 | 带着什么问题读 |
| --- | --- | --- |
| W8 | [数据库迁移](../guides/database-migrations.md) | V / U 如何编号，空库与旧快照如何验证，菜单 / 字典怎么回滚 |
| W9～W10 | [测试策略](../guides/testing-strategy.md) | 状态机、事务、幂等、并发、权限和附件副作用怎么自动验证 |
| W11 | [测试策略](../guides/testing-strategy.md) + [CI/CD](../guides/ci-cd-pipeline.md) | 测试层次、固定工具链、报告和 PR 门禁如何分工 |
| W12 | [发布与回滚](../guides/deployment-and-rollback.md) + [可观测性与运维](../guides/observability-and-operations.md) | 如何确认健康、何时回滚、怎样恢复数据库 / 附件并保留证据 |

完整解锁顺序和状态说明见 [W1～W12 任务书导航](./tasks/README.md)。

---

## 口头验收题（约 15 分钟）

带教人可任选；实习生应能不看稿讲出要点。

### A. 架构与模块

1. 六个 Maven 模块各自职责是什么？依赖方向是怎样的？
2. `ruoyi-admin` 和 `ruoyi-framework` 谁负责 Security / JWT？
3. 前端 `ruoyi-ui` 与后端的边界是什么？（谁渲染页面、谁提供 API）

### B. 登录与会话

4. 登录成功后，客户端拿到什么？Redis 里存什么？JWT 里大致有什么？
5. 后续请求如何带身份？令牌快过期时系统会怎样？
6. 退出登录时，主要清掉什么？

### C. 权限三层

7. **菜单/路由权限**、**按钮/方法权限**（`@PreAuthorize`）、**数据权限**（`dataScope`）分别解决什么问题？
8. 前端 `v-hasPermi` 隐藏按钮后，后端还有没有校验？为什么？
9. 动态路由数据从哪个接口来？前端如何变成可访问路由？

### D. 工具与安全意识

10. Swagger 在开发时怎么打开？生产环境为什么要收敛暴露面？
11. 为什么不能把 `application-druid.yml` 里的默认口令原样用于公网？
12. 本仓库审计里 P1 大致有哪些类问题？（能说出「默认密钥 / 运维端点 / 生成器」即可）

---

## 阅读笔记建议结构

```markdown
## 日期
## 读了什么
## 三个要点
## 仍不懂的问题（带文件路径）
## 明天计划
```
