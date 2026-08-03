# 工程指南索引

本目录收录跨模块、可重复执行的工程约定。知识库总入口见 [docs/README.md](../README.md)，系统术语见 [CONTEXT.md](../../CONTEXT.md)。

> **状态说明：** “指南可用”表示流程和边界已经写清，不表示仓库已经实现文中所有目标能力。每篇指南开头会单独说明当前基线与目标状态。

## 按问题查找

| 我现在要做什么 | 先读 | 再读 |
| --- | --- | --- |
| 安装环境并启动前后端 | [本地启动说明](../intern/08-local-setup-step-by-step.md) | [环境检查清单](../intern/05-environment-checklist.md) |
| 接需求、建分支、发 PR | [研发协作流程](./development-workflow.md) | 对应业务任务书 / 审计项 |
| 改表、初始化菜单或字典 | [数据库迁移](./database-migrations.md) | [测试策略](./testing-strategy.md)、[发布与回滚](./deployment-and-rollback.md) |
| 补后端或前端测试 | [测试策略](./testing-strategy.md) | [CI/CD](./ci-cd-pipeline.md) |
| 建流水线或排查 CI | [CI/CD](./ci-cd-pipeline.md) | [测试策略](./testing-strategy.md) |
| 调试接口文档 | [API 文档与 Swagger](./api-docs-swagger.md) | [安全审计](../audit/03-security.md) |
| 准备测试环境发布 | [发布与回滚](./deployment-and-rollback.md) | [数据库迁移](./database-migrations.md)、[可观测性与运维](./observability-and-operations.md) |
| 看日志、设告警、处理故障 | [可观测性与运维](./observability-and-operations.md) | [发布与回滚](./deployment-and-rollback.md) |

## 指南目录

| 文档 | 状态 | 当前基线 | 主要维护触发点 |
| --- | --- | --- | --- |
| [development-workflow.md](./development-workflow.md) | 当前团队约定 | 分支开发；`master` 禁止直推 | 分支策略、Review 或完成定义变化 |
| [database-migrations.md](./database-migrations.md) | 目标约定 | 尚无迁移目录和自动 runner | 首次引入迁移工具、路径或命名变化 |
| [testing-strategy.md](./testing-strategy.md) | 目标约定 | 后端测试文件为 0；前端无 test 脚本 | 测试框架、测试层次或门禁变化 |
| [ci-cd-pipeline.md](./ci-cd-pipeline.md) | 落地指南 | 尚无业务 workflow | workflow、工具版本、门禁或制品变化 |
| [deployment-and-rollback.md](./deployment-and-rollback.md) | 目标约定 | 有基础打包 / 启停脚本；无 Docker / Compose / 发布编排 / 回滚 runbook | 拓扑、配置、迁移或恢复流程变化 |
| [observability-and-operations.md](./observability-and-operations.md) | 当前 + 目标 | 有管理监控与审计日志；缺统一观测基线 | 日志字段、端点、指标、告警变化 |
| [api-docs-swagger.md](./api-docs-swagger.md) | 当前使用指南 | SpringDoc / Swagger 已配置 | 扫描包、路径、鉴权或生产开关变化 |

## 状态标签怎么写

新增或修改指南时，开头至少包含：

| 标签 | 含义 | 写法示例 |
| --- | --- | --- |
| 当前基线 | 已从仓库或环境验证的事实 | “截至 2026-08-03，无 `.github/workflows`” |
| 当前约定 | 团队现在执行的流程规则 | “`master` 禁止直推，使用分支 + PR” |
| 目标状态 | 尚未实现、等待任务落地的设计 | “W11 目标：PR 自动运行测试” |
| 历史记录 | 带日期、不可当作实时状态的证据 | “2026-07-21 前端构建记录” |

不要用“应该已经”“通常存在”“可能没有”描述可直接从仓库核实的事实。

## 维护责任

没有单独 `CODEOWNERS` 时，按改动归属维护：

| 变化 | 文档责任人 |
| --- | --- |
| 业务 / 数据模型 | 功能 PR 作者与 Reviewer |
| 测试 / CI | 引入或修改门禁的 PR 作者 |
| 部署 / 配置 / 密钥来源 | 发布方案负责人和运维 Reviewer |
| 安全项 | 整改负责人，并同步审计风险状态 |
| 培训任务 | 带教人，需核对当前基线与解锁条件 |

PR Reviewer 负责确认文档与实现一致，但不能代替作者补写关键运行步骤。

## 更新检查清单

- [ ] 页面开头的当前 / 目标状态仍准确，并带最近核实日期。
- [ ] 命令、路径、模块名和配置键可在当前分支定位。
- [ ] 新流程包含失败处理、回滚或恢复路径，而不只有成功路径。
- [ ] 示例使用占位值，不含真实密钥、Token、生产地址和用户数据。
- [ ] 本页、[知识库首页](../README.md)及相关任务书的链接已同步。
- [ ] 相对链接和标题锚点已检查，文档末尾保留相关入口。
- [ ] PR 描述记录验证命令、结果、未验证项和适用环境。

## 文档边界

- `docs/guides/`：活的工程操作约定。
- `docs/audit/`：带日期的审计证据与整改台账。
- `docs/intern/`：学习路径、任务门槛和验收标准。
- `CONTEXT.md`：跨文档复用的稳定术语与系统边界。
- 根 `README.md`：上游产品介绍及本地知识库入口。

指南不复制完整业务任务书；任务书也不复制整篇工程规范。两者通过链接建立上下文。
