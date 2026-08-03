# W1-W12 任务书导航

本目录存放可直接下达和验收的周任务书。培训总入口见[实习生带教手册](../README.md)，当前仓库事实见[知识库首页](../../README.md)。

> **文档类型：规划任务。** W1 主要跟读当前链路；W2-W12 描述逐周待实现或待演练的目标，不代表功能已经存在。每周开始前必须从当前分支重新核对基线。
> **解锁规则：** 默认不可跳周；上一周未完成权限、数据、测试和 Review 验收时，不下发下一周完整任务。

## 当前基线

截至 2026-08-03：

- 当前只有 RuoYi 六个 Maven 模块，没有 `ruoyi-ticket`。
- W2-W7 的训练增强不能仅凭任务书判断已实现，开始前须查代码和 SQL。
- 没有 `sql/migrations/`、自动化测试、业务 CI workflow、前端 lockfile、Dockerfile 或 Compose。
- W8-W12 中的工单、迁移、测试流水线、容器与观测设计均是后续交付目标。

## 主线总览

| 周次 | 阶段 | 交付主题 | 解锁条件 | 状态定位 |
| --- | --- | --- | --- | --- |
| [W1](./W1-login-and-user-list.md) | 入门 | 环境、登录链路、用户列表跟读 | 开营 | 跟读当前实现 |
| [W2](./W2-notice-enhancement.md) | 基础功能 | 公告置顶闭环 | W1 验收 | 规划任务 |
| [W3](./W3-notice-deepen.md) | 基础加深 | 筛选、导出、日志、模块文档 | W2 验收 | 规划任务 |
| [W4](./W4-demo-and-wrapup.md) | 基础收口 | Demo、技术笔记、合入复盘 | W3 验收，或导师批准加速 | 规划任务 |
| [W5](./W5-user-batch-import-role-dept.md) | 进阶 | 用户导入、批量部门 / 角色、事务 | W4 验收 | 规划任务 |
| [W6](./W6-dict-management.md) | 进阶 | 字典一致性与用户性别筛选 | W5 验收 | 规划任务 |
| [W7](./W7-online-user-and-job-monitor.md) | 进阶 | 在线会话与调度统计 | W6 验收 | 规划任务 |
| [W8](./W8-ticket-center-mvp.md) | 全栈项目 | 工单 MVP、模块、CRUD、DataScope、迁移 | W1-W7 / 等价能力验收；设计评审 | 规划任务 |
| [W9](./W9-ticket-workflow-collaboration.md) | 全栈项目 | 状态机、流转、评论、事务、幂等 | W8 验收 | 规划任务 |
| [W10](./W10-ticket-attachments-notifications-audit.md) | 全栈项目 | 鉴权附件、通知、审计与补偿 | W9 验收 | 规划任务 |
| [W11](./W11-testing-and-ci.md) | 工程化 | 分层测试、依赖复现、CI 门禁 | W8-W10 人工回归通过 | 规划任务 |
| [W12](./W12-deployment-production-readiness.md) | 交付 | 容器、配置、观测、升级、备份与回滚 | W11 门禁可重复 | 规划任务 |

## 能力成长路径

```text
W1 读懂请求与权限
  → W2-W4 完成一个小功能闭环
  → W5-W7 处理事务、一致性与运维模块
  → W8-W10 连续建设一个完整业务域
  → W11 用测试和 CI 固化质量
  → W12 让系统可部署、可观察、可恢复
```

W8-W10 必须在同一个工单领域连续演进。W11-W12 是导师结对项，不允许把“会写 CRUD”直接等同于可以独立做生产部署。

## 配套指南

| 周次 | 开始前必读 | 使用时机 |
| --- | --- | --- |
| W1-W4 | [研发协作流程](../../guides/development-workflow.md)、[Swagger](../../guides/api-docs-swagger.md) | 第一次分支、PR、接口调试 |
| W5-W7 | [测试策略](../../guides/testing-strategy.md)、[安全审计](../../audit/03-security.md) | 事务、权限、任务和回归设计 |
| W8 | [数据库迁移](../../guides/database-migrations.md) | V001 / U001、菜单、字典和空库验证 |
| W9-W10 | [数据库迁移](../../guides/database-migrations.md)、[测试策略](../../guides/testing-strategy.md) | 增量迁移、状态机、并发、附件和补偿 |
| W11 | [测试策略](../../guides/testing-strategy.md)、[CI/CD](../../guides/ci-cd-pipeline.md) | 选型、分层、报告、扫描和 PR 门禁 |
| W12 | [发布与回滚](../../guides/deployment-and-rollback.md)、[可观测性与运维](../../guides/observability-and-operations.md) | 拓扑、健康、发布、观察和恢复演练 |

所有周次都遵守[研发协作流程](../../guides/development-workflow.md)中的分支、证据、Review 和完成定义。

## 每周下发流程

1. 带教人先确认上一周验收和当前代码基线。
2. 只发送本周任务书与对应指南，不一次性下发后续完整任务。
3. 实习生第 1 天提交范围、数据 / 接口 / 权限、测试和回滚设计。
4. 带教人确认红线与不做项后再进入实现。
5. 每日同步进度、证据和阻塞；阻塞超过 1 小时升级提问。
6. 最后一天执行验收矩阵、Review、Demo 和技术笔记。
7. 合并后记录真实完成状态，再决定是否解锁下一周。

## 通用交付清单

每份任务书的具体要求优先；至少应有：

- [ ] 设计说明：范围 / 不做、数据、接口、权限和失败路径。
- [ ] 小范围提交与 PR：无无关重构、生成产物或真实密钥。
- [ ] 测试证据：成功、失败、权限、边界和回归场景。
- [ ] 数据变化：版本化正向 / 恢复方案和验证记录。
- [ ] 前端变化：加载、空、错误、无权限和冲突状态。
- [ ] 技术笔记：关键决策、命令结果、未覆盖风险和后续计划。
- [ ] Demo：能解释链路和取舍，而不只是点击页面。

## 状态更新规则

任务完成不直接修改任务书为“当前能力”。功能合并且验证后：

1. 更新 [docs/README.md](../../README.md) 的能力矩阵。
2. 当前稳定边界发生变化时更新 [CONTEXT.md](../../../CONTEXT.md)。
3. 新增测试、workflow、迁移或部署文件时更新对应工程指南的基线日期。
4. 涉及审计项时更新风险状态和验证记录，保留原审计快照语境。

## 相关入口

- [实习生带教手册](../README.md)
- [学习路径](../01-learning-path.md)
- [带教人指南](../06-mentor-guide.md)
- [任务模板](../03-task-template.md)
- [工程指南索引](../../guides/README.md)
