# RuoYi-Vue 代码库审计

> **文档类型：审计快照。** `01`-`03` 的证据基于 2026-07-21 与下方指定 commit，不会自动反映后续代码变化；`04` 是整改计划，不表示已实施。实时入口见 [知识库首页](../README.md)，当前系统术语见 [CONTEXT.md](../../CONTEXT.md)。

## 执行摘要

本轮审计为接手 RuoYi-Vue 的开发与安全维护人员建立可追溯中文文档集，覆盖系统架构、前端 UI/配色、安全边界与整改优先级。**仅文档落盘，未修改业务代码。**

**核心结论：**

- 架构为清晰的六模块 Maven + Vue2 前后端分离；会话模型是 **JWT 指针 + Redis `LoginUser`**，权限含 URL 认证、方法级权限与数据权限切面。
- UI 以 Element 主色 `#1890ff` 与独立侧栏中性色为双轨 token；主题能力主要是侧栏深浅 + 主色，而非完整暗色内容主题；焦点 outline 被全局弱化。
- 安全骨架完整（BCrypt、验证码、锁定、白名单任务、上传扩展名等），优先风险是 **默认密钥/口令与 Druid/Swagger 暴露（SEC-001–003）**、**生成器 DDL（SEC-007）**，其次 CORS、`/profile` 匿名读、XSS 出口与 `${}` SQL 面。
- 本环境 **无 JDK/Maven**，后端构建与 OWASP 未能执行；前端 **`build:prod` 已通过**；`npm audit` 因无 lockfile 不可用；仓库 **无 `src/test`**。

| 严重度 | 数量 | 代表 ID |
| --- | --- | --- |
| P0 | 0（生产若暴露默认凭据应按 P0 应急） | — |
| P1 | 4 | SEC-001、002、003、007 |
| P2 | 6 | SEC-004、006、008、009、010、012 |
| P3 | 3 | SEC-005、011、013 |

| 状态 | 数量 |
| --- | --- |
| 已确认问题 | 1（SEC-004） |
| 条件性风险 | 8 |
| 设计观察 | 3 |
| 未能动态验证 | 1（SEC-012） |

## 审计基线

| 项 | 值 |
| --- | --- |
| 审计日期 | 2026-07-21 |
| 文档分支 HEAD（审计提交前基线） | `8e175e9c611c0861cc052864f2cd52a20cb0ea73` |
| 隔离分支 | `audit/codebase-docs-20260720` |
| 隔离工作树 | `.worktrees/codebase-audit` |
| 项目版本 | RuoYi 3.9.2 |
| 后端目标 | Java 17、Spring Boot 4.0.6 |
| 前端目标 | Vue 2、Vue Router 3、Vuex、Element UI 2.15.14 |
| Maven 模块 | admin / framework / system / quartz / generator / common |
| 后端 main 文件数 | 315 |
| 前端 `ruoyi-ui/src` 文件数 | 289 |
| `src/test` 文件数 | 0 |
| Node / npm | v24.16.0 / 11.13.0 |
| Java / Maven | 未安装 |
| 设计说明 | [docs/superpowers/specs/2026-07-20-codebase-audit-design.md](../superpowers/specs/2026-07-20-codebase-audit-design.md) |
| 执行计划 | [docs/superpowers/plans/2026-07-20-codebase-audit.md](../superpowers/plans/2026-07-20-codebase-audit.md) |
| 术语表 | [CONTEXT.md](../../CONTEXT.md) |

## 范围

**纳入：** 架构链路、前端 UI/配色、认证授权与敏感操作安全、整改路线、环境允许的工具链记录。

**不纳入：** 修代码、升依赖、重做 UI、生产渗透、无决策背景的 ADR。

## 方法与证据等级

静态代码与配置追踪为主，路径+行号为证据；构建/扫描为验证证据；条件性结论标注触发条件。发现分类与 P0–P3 定义见 [CONTEXT.md](../../CONTEXT.md) 审计术语与 [03-security.md](./03-security.md)。

## 结论概览

| 专题 | 要点 | 文档 |
| --- | --- | --- |
| 架构 | admin→framework→system→common；quartz/generator 挂 admin；登录/动态路由/数据权限/文件/任务链路已图示 | [01-architecture.md](./01-architecture.md) |
| 前端 UI | Element 主色与侧栏 token、布局 200px 侧栏、主题设置、响应式断点、a11y 焦点与 v-html 观察 | [02-frontend-ui.md](./02-frontend-ui.md) |
| 安全 | 13 项台账；默认凭据与运维暴露优先；控制清单与限制已记录 | [03-security.md](./03-security.md) |
| 整改 | B0–B4 批次；P1 先轮换密钥/收敛暴露/限制生成器 | [04-remediation-roadmap.md](./04-remediation-roadmap.md) |

**已有较强控制：** BCrypt、验证码与登录锁定、JWT+Redis 可吊销、方法权限、数据权限切面、上传扩展名与路径 `..` 检查、Quartz 白名单、OrderBy 规范化。

## 文档导航

| 文档 | 内容 |
| --- | --- |
| [CONTEXT.md](../../CONTEXT.md) | 稳定术语与系统边界 |
| [01-architecture.md](./01-architecture.md) | 模块职责、依赖与运行链路 |
| [02-frontend-ui.md](./02-frontend-ui.md) | 前端结构、UI 与配色 |
| [03-security.md](./03-security.md) | 安全审计与风险台账 |
| [04-remediation-roadmap.md](./04-remediation-roadmap.md) | 整改优先级与回归验证 |
| [../guides/api-docs-swagger.md](../guides/api-docs-swagger.md) | API 文档与 Swagger 在线调试使用说明 |
| [../guides/ci-cd-pipeline.md](../guides/ci-cd-pipeline.md) | CI/CD 概念、作用与本仓库工程流水线操作指南 |
| [../guides/database-migrations.md](../guides/database-migrations.md) | 版本化数据库变化、验证与恢复目标规范 |
| [../guides/testing-strategy.md](../guides/testing-strategy.md) | 分层测试、数据隔离与质量门禁目标规范 |
| [../guides/deployment-and-rollback.md](../guides/deployment-and-rollback.md) | 发布、迁移门禁、备份、升级与回滚目标规范 |
| [../guides/observability-and-operations.md](../guides/observability-and-operations.md) | 日志、健康、指标、告警与事件运维目标规范 |
| [../intern/README.md](../intern/README.md) | 实习生带教手册、学习路径与任务书 |

## 验证记录

| 时间 | 命令/检查 | 结果 |
| --- | --- | --- |
| 2026-07-21 | `git rev-parse HEAD`（基线） | `8e175e9c611c0861cc052864f2cd52a20cb0ea73` |
| 2026-07-21 | `java -version` / `mvn -version` | 失败：未安装 |
| 2026-07-21 | `node --version` / `npm --version` | v24.16.0 / 11.13.0 |
| 2026-07-21 | 模块与源码盘点 | 6 模块；main 315；ui src 289；test 0 |
| 2026-07-21 | 静态安全检索 | permitAll、`${}`、上传、任务白名单、XSS、v-html 等已取证 |
| 2026-07-21 | 文档密钥模式 | 报告不复制 password/secret 值 |
| 2026-07-21 | `mvn test` / `package` / OWASP | **未执行**（环境无 Java/Maven） |
| 2026-07-21 | `npm --prefix ruoyi-ui install --no-package-lock --ignore-scripts` | 成功：added 1476 packages in ~28s；大量 deprecated 警告（含 Vue2 EOL、highlight.js 9.x、request 等）；**未生成** package-lock.json |
| 2026-07-21 | `npm --prefix ruoyi-ui run build:prod` | 成功：`DONE Build complete`；产物 `ruoyi-ui/dist` 约 7.3M（gitignore，未入库） |
| 2026-07-21 | `npm --prefix ruoyi-ui audit --omit=dev` | 失败：`ENOLOCK`（仓库无 lockfile，按计划不提交 lockfile） |

## 范围限制

1. 无 JDK/Maven：后端编译、测试、dependency 树、OWASP 未做。
2. 无仓库测试代码。
3. 前端无 lockfile，未为审计生成 lockfile。
4. 未做在线渗透与浏览器动态 XSS/CORS 复现。
5. 条件性风险需结合真实部署配置确认。
6. 前端 `build:prod` 已通过；`npm audit` 因无 lockfile 无法执行；后端 Maven/OWASP 仍未执行，SEC-012 保持未能动态验证（供应链）。
