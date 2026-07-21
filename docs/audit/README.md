# RuoYi-Vue 代码库审计

## 执行摘要

本轮审计目标是为接手 RuoYi-Vue 的开发与安全维护人员建立可追溯的中文文档集，覆盖系统架构、前端 UI 与配色、安全边界和整改优先级。审计范围仅限查阅与文档落盘，不修改业务代码。

当前进度：已完成仓库基线采集与稳定术语沉淀；架构、前端 UI、安全专题文档将在后续任务中基于代码证据补全。详细结论以各专题文档为准。

## 审计基线

| 项 | 值 |
| --- | --- |
| 审计日期 | 2026-07-21 |
| 仓库 HEAD | `8e175e9c611c0861cc052864f2cd52a20cb0ea73` |
| 隔离分支 | `audit/codebase-docs-20260720` |
| 隔离工作树 | `.worktrees/codebase-audit` |
| 项目版本（POM / README） | RuoYi 3.9.2 |
| 后端目标 | Java 17、Spring Boot 4.0.6 |
| 前端目标 | Vue 2、Vue Router 3、Vuex、Element UI 2.15.14、Vue CLI |
| Maven 模块 | `ruoyi-admin`、`ruoyi-framework`、`ruoyi-system`、`ruoyi-quartz`、`ruoyi-generator`、`ruoyi-common` |
| 后端主源文件数（`*/src/main/*`） | 315 |
| 前端 `ruoyi-ui/src` 文件数 | 289 |
| 仓库内 `src/test` 测试文件数 | 0 |
| Node | v24.16.0 |
| npm | 11.13.0 |
| Java | 当前审计环境未安装（`java: command not found`） |
| Maven | 当前审计环境未安装（`mvn: command not found`） |
| 活跃配置 Profile | `spring.profiles.active=druid` |
| 设计说明 | [docs/superpowers/specs/2026-07-20-codebase-audit-design.md](../superpowers/specs/2026-07-20-codebase-audit-design.md) |
| 执行计划 | [docs/superpowers/plans/2026-07-20-codebase-audit.md](../superpowers/plans/2026-07-20-codebase-audit.md) |
| 术语表 | [CONTEXT.md](../../CONTEXT.md) |

## 范围

**纳入：**

- 后端多模块结构、启动与请求链路、登录令牌、菜单动态路由、数据权限、文件、定时任务、代码生成。
- 前端启动、路由守卫、布局壳、典型 CRUD 页面、样式变量与配色、主题、响应式与可访问性观察。
- 认证授权、输入输出、文件路径、运维端点、配置与日志、依赖供应链的安全审计。
- 在不改业务代码前提下可执行的构建与依赖检查；无法执行项记入限制。

**不纳入：**

- 修复问题、重构模块、升级依赖。
- 重新设计 UI。
- 对未启动生产环境做渗透测试。
- 无真实决策背景的 ADR。

## 方法与证据等级

1. **静态代码追踪**：从入口、配置、Security、Service、Mapper、前端路由与样式变量沿链路取证。
2. **配置审查**：记录配置键、默认行为与部署条件；不把密钥或密码写入文档。
3. **可执行验证**：优先运行 Maven 测试/打包、前端安装与生产构建、依赖审计；工具缺失时明确记录。
4. **证据等级**：
   - 代码路径 + 行号：主证据。
   - 构建/扫描输出：验证证据。
   - 条件性结论：必须写明触发条件。
5. **发现分类**：已确认问题、条件性风险、设计观察、未能动态验证；严重度 P0–P3。

## 结论概览

基线阶段已确认：

- 仓库为前后端分离的 RuoYi 3.9.2，六模块 Maven 结构清晰，前端为 Vue 2 经典栈。
- 身份模型以 `LoginUser` + JWT + Redis `login_tokens:` 为核心；权限分菜单/按钮权限与数据权限两层。
- 当前环境可进行前端 Node 工具链验证，但缺少 JDK/Maven，后端动态构建验证暂不可用。
- 仓库未发现 `src/test` 测试源，后续“测试通过”不能作为行为覆盖证据。

完整架构、UI、安全结论与风险计数将在专题文档完成后回填本节。

## 文档导航

| 文档 | 内容 |
| --- | --- |
| [CONTEXT.md](../../CONTEXT.md) | 稳定术语与系统边界 |
| [01-architecture.md](./01-architecture.md) | 模块职责、依赖与运行链路（待完成） |
| [02-frontend-ui.md](./02-frontend-ui.md) | 前端结构、UI 与配色（待完成） |
| [03-security.md](./03-security.md) | 安全审计与风险台账（待完成） |
| [04-remediation-roadmap.md](./04-remediation-roadmap.md) | 整改优先级与回归验证（待完成） |

## 验证记录

| 时间 | 命令/检查 | 结果 |
| --- | --- | --- |
| 2026-07-21 | `git rev-parse HEAD` | `8e175e9c611c0861cc052864f2cd52a20cb0ea73` |
| 2026-07-21 | `git status --short --branch` | `audit/codebase-docs-20260720`，基线写入前干净 |
| 2026-07-21 | `java -version` | 失败：环境未安装 Java |
| 2026-07-21 | `mvn -version` | 失败：环境未安装 Maven |
| 2026-07-21 | `node --version` / `npm --version` | v24.16.0 / 11.13.0 |
| 2026-07-21 | 模块与源码盘点 | 6 个 Maven 模块；backend main 315 文件；frontend src 289 文件；test 0 |
| 2026-07-21 | 密钥模式扫描（文档） | 基线文档不得复制配置中的密码/密钥值 |

后续 Task 5 将补充 Maven package、前端 `build:prod` 与依赖审计结果。

## 范围限制

1. **无 JDK/Maven**：无法在本环境执行后端编译、测试、`dependency:tree` 与 OWASP Dependency-Check；相关项标记为未能动态验证，不推测通过。
2. **无仓库测试**：`src/test` 文件数为 0，即使后续安装 JDK，也缺少现成自动化行为测试。
3. **前端无 lockfile**：`ruoyi-ui` 不提交 package-lock；npm audit 可能受限，且审计不得为通过审计而提交新 lockfile。
4. **运行时依赖未在本轮强绑**：数据库、Redis、实际上传目录与生产反向代理行为以配置与代码为准；未做在线渗透。
5. **秘密值不入库**：配置中存在默认口令/令牌密钥类键时，文档只描述键名、存在性与风险条件，不复制具体值。
