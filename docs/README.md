# Java-base 知识库

这里是本仓库二次开发文档的统一入口。上游 RuoYi 产品介绍见根目录 [README.md](../README.md)；本页回答“当前仓库是什么、应该读什么、计划建设什么”。

> **基线日期：** 2026-08-03
> **适用分支：** `master` 及从其创建的开发分支
> **重要约定：** 文档中的“目标”不表示代码已经实现。判断现状时，仓库代码、配置和可重复验证证据优先。

## 先选阅读路线

| 读者 / 场景 | 建议顺序 | 目标 |
| --- | --- | --- |
| 新加入的开发者 | 本页 → [项目上下文](../CONTEXT.md) → [架构审计](./audit/01-architecture.md) → [本地启动](./intern/08-local-setup-step-by-step.md) | 理解边界并跑起系统 |
| 零基础实习生 | [实习生带教手册](./intern/README.md) → 零基础说明 → 环境清单 → W1 | 按门槛逐周学习，不一次性接收全部任务 |
| 日常功能开发 | [研发协作流程](./guides/development-workflow.md) → 对应专项指南 → 相关模块代码 | 从设计、实现、验证到 PR 完成闭环 |
| 安全整改 | [安全审计](./audit/03-security.md) → [整改路线](./audit/04-remediation-roadmap.md) → 测试与发布指南 | 按风险 ID 处理并保留回归证据 |
| W8-W12 毕业项目 | [培训导航](./intern/README.md) → 对应周任务书 → 数据迁移 / 测试 / 发布 / 运维指南 | 区分现有系统与工单目标架构 |
| 发布与值守 | [发布与回滚](./guides/deployment-and-rollback.md) → [可观测性与运维](./guides/observability-and-operations.md) | 在隔离环境完成发布、观察和恢复演练 |

## 当前能力与目标能力

下表是进入详细文档前必须先确认的边界。

| 能力 | 当前仓库基线（2026-08-03） | 目标 / 入口 |
| --- | --- | --- |
| 后端结构 | 6 个 Maven 模块：`admin/framework/system/quartz/generator/common` | W8 计划新增独立 `ruoyi-ticket`；当前尚不存在 |
| 业务域 | 系统管理、监控、定时任务、代码生成等 RuoYi 内置能力 | W8-W10 计划建设工单、流转、附件、通知与审计 |
| 数据初始化 | `sql/ry_20260417.sql`、`sql/quartz.sql` 两个整库 / 基础脚本 | 迁移目录和 runner 尚未落地；约定见[数据库迁移](./guides/database-migrations.md) |
| 后端测试 | 仓库内 `src/test` 文件数为 0 | W11 按[测试策略](./guides/testing-strategy.md)补充分层测试 |
| 前端验证 | `package.json` 有开发、预览和生产 / 预发构建脚本，无 test / lint 脚本 | W11 选型后引入测试与静态检查，禁止空套件假绿 |
| 依赖复现 | `ruoyi-ui` 无 npm/yarn/pnpm lockfile | W11 固定 Node/npm 并提交团队选定的 lockfile |
| CI | `.github` 下只有资助配置，无业务 workflow | W11 落地 PR 门禁；见 [CI/CD 指南](./guides/ci-cd-pipeline.md) |
| 部署 | 有基础打包 / jar 启停脚本；无 Dockerfile、Compose、部署 workflow 或完整回滚 runbook | W12 在隔离环境完成容器化、升级和回滚演练 |
| 运维观测 | 已有操作 / 登录日志及服务、缓存、Druid 等管理能力 | W12 增加健康就绪、request ID、指标、告警和 runbook |

## 文档地图

### 稳定上下文

| 文档 | 用途 |
| --- | --- |
| [CONTEXT.md](../CONTEXT.md) | 系统边界、模块、身份权限、运行时和工程术语 |
| [根 README](../README.md) | 上游 RuoYi 产品简介、版本与内置功能 |

### 代码库审计

审计是带日期的证据快照，不会自动随代码演进。结论、风险和限制从[审计首页](./audit/README.md)进入。

| 专题 | 内容 |
| --- | --- |
| [架构](./audit/01-architecture.md) | 模块依赖、登录、路由、权限、文件和任务链路 |
| [前端 UI](./audit/02-frontend-ui.md) | Vue 2 结构、Element UI、主题、响应式与可访问性观察 |
| [安全](./audit/03-security.md) | 风险台账、控制项、证据和适用条件 |
| [整改路线](./audit/04-remediation-roadmap.md) | P1-P3 优先级、批次和回归矩阵 |

### 工程指南

工程指南是持续维护的工作约定。完整说明、负责人规则和状态见[指南索引](./guides/README.md)。

| 指南 | 解决的问题 |
| --- | --- |
| [研发协作流程](./guides/development-workflow.md) | 分支、设计评审、实现、验证、PR、完成定义 |
| [数据库迁移](./guides/database-migrations.md) | 版本脚本、升级 / 回滚、校验、环境安全 |
| [测试策略](./guides/testing-strategy.md) | 后端 / 前端测试分层、数据隔离、覆盖率和空套件保护 |
| [CI/CD](./guides/ci-cd-pipeline.md) | 自动构建、测试、扫描、制品和门禁 |
| [发布与回滚](./guides/deployment-and-rollback.md) | 制品、配置、迁移门禁、发布、备份与恢复 |
| [可观测性与运维](./guides/observability-and-operations.md) | 日志、健康、指标、告警、事件与 runbook |
| [API 文档与 Swagger](./guides/api-docs-swagger.md) | 开发环境接口浏览、鉴权调试和生产暴露控制 |

### 培训体系

[实习生带教手册](./intern/README.md)包含零基础材料、环境清单、模块地图、导师指南和 W1-W12 任务书。任务书描述学习目标与目标设计，不是当前功能清单。

### 过程材料

[审计设计说明](./superpowers/specs/2026-07-20-codebase-audit-design.md)与[执行计划](./superpowers/plans/2026-07-20-codebase-audit.md)供过程追溯。日常开发优先阅读本页、`CONTEXT.md`、工程指南和当前任务书。

## 信息冲突时如何判断

按以下优先级处理；不能确认时在 PR 中显式提出，而不是自行补全事实。

1. 当前分支的代码、配置、数据库脚本与可重复命令输出。
2. `CONTEXT.md` 中的稳定系统边界和术语。
3. `docs/guides/` 中明确标注为“当前约定”的流程。
4. `docs/audit/` 中带日期的审计结论。
5. `docs/intern/tasks/` 中标注为目标的训练设计。
6. 上游网站和通用示例；版本不一致时只能作为参考。

## 常用工作流

```text
接任务
  → 确认当前基线与范围
  → 阅读对应指南 / 风险项
  → 建分支并提交设计
  → 小步实现，同时补测试、迁移和文档
  → 本地验证并记录命令结果
  → 发起 PR，处理 Review 与 CI
  → 合并后更新状态文档
```

数据库结构变化、权限变化、外部接口变化、运行配置变化和发布方式变化都必须同步更新对应指南或模块说明。完整检查清单见[研发协作流程](./guides/development-workflow.md)。

## 维护规则

- 文档必须标清“当前”“目标”“历史快照”，避免把设计当成事实。
- 命令示例不得包含真实密钥、Token、生产地址或生产数据。
- 新增、重命名文档时同步更新本页和所属目录 README，并检查所有相对链接。
- 现状表发生变化时记录验证日期和证据；不要保留“可能”“通常”等无法验收的措辞。
- 审计项整改后更新风险状态、验证记录和相关运行指南；不要直接覆盖原始证据。
- 所有合并进入 `master` 的改动走分支和 Review，禁止直接推送主分支。
