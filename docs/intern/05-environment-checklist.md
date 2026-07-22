# 本地环境勾选清单

实习生按序完成并打勾；卡点记在文末「问题记录」。  
配置**仅用于本机**，不要把真实密码提交到 Git。

## A. 工具链

| # | 检查项 | 命令示例 | 期望 | 完成 |
| --- | --- | --- | --- | --- |
| A1 | JDK 17+ | `java -version` | 17 或以上 | [ ] |
| A2 | Maven | `mvn -version` | 可运行 | [ ] |
| A3 | Node / npm | `node -v` / `npm -v` | 建议 Node 16+（以能装依赖为准） | [ ] |
| A4 | Git | `git --version` | 可运行 | [ ] |
| A5 | MySQL | 客户端可连接本机实例 | 库可建 | [ ] |
| A6 | Redis | `redis-cli ping` | `PONG` | [ ] |

> 审计文档记录过部分环境无 JDK/Maven 的情况；**开发岗必须具备 A1/A2**，否则无法编后端。

## B. 代码与分支

| # | 检查项 | 说明 | 完成 |
| --- | --- | --- | --- |
| B1 | 克隆本仓库 | 使用公司/导师给出的 `origin` 地址 | [ ] |
| B2 | 默认分支为 `master` | `git checkout master && git pull` | [ ] |
| B3 | 个人分支 | `git checkout -b feature/<name>-onboarding` | [ ] |
| B4 | 不提交密钥 | 检查 `git status` / diff 无密码 | [ ] |

## C. 数据库

| # | 检查项 | 说明 | 完成 |
| --- | --- | --- | --- |
| C1 | 创建业务库 | 库名自定，如 `ry-vue` | [ ] |
| C2 | 导入主 SQL | `sql/ry_*.sql`（以仓库实际文件名为准） | [ ] |
| C3 | 如需定时任务 | 按需导入 `sql/quartz.sql` | [ ] |
| C4 | 本地账号密码 | 写入**本地**配置，勿提交 | [ ] |

## D. 后端配置与启动

| # | 检查项 | 说明 | 完成 |
| --- | --- | --- | --- |
| D1 | 阅读 `ruoyi-admin/src/main/resources/application.yml` | 端口、Redis、token、profile 等键名 | [ ] |
| D2 | 配置数据源 | 通常在 `application-druid.yml`（本地值） | [ ] |
| D3 | Redis 地址/端口/密码 | 与本机一致 | [ ] |
| D4 | 启动后端 | 运行 `RuoYiApplication` 或 `mvn` 方式按团队习惯 | [ ] |
| D5 | 健康检查 | 默认端口见配置（常见 `8080`）；登录页或接口可访问 | [ ] |

**注意：** 仓库可能含默认演示口令类配置——**仅限本地**，部署与公网必须轮换（见审计 SEC-001/002）。

## E. 前端

| # | 检查项 | 说明 | 完成 |
| --- | --- | --- | --- |
| E1 | 进入 `ruoyi-ui` | — | [ ] |
| E2 | 安装依赖 | `npm install`（可用国内 registry，见 `ruoyi-ui/README.md`） | [ ] |
| E3 | 开发代理 | 理解 `vue.config.js` 与 `.env.development` 中 `VUE_APP_BASE_API` | [ ] |
| E4 | 启动 | `npm run dev` | [ ] |
| E5 | 浏览器登录 | 使用初始化管理员账号（以 SQL/官方文档为准；**登录后立刻在本地改密更佳**） | [ ] |

## F. 冒烟（业务）

| # | 检查项 | 完成 |
| --- | --- | --- |
| F1 | 系统管理 → 用户 / 角色 / 菜单 能打开 | [ ] |
| F2 | 系统管理 → 字典 能打开 | [ ] |
| F3 | 系统工具 → 系统接口（Swagger）能打开（若菜单存在） | [ ] |
| F4 | 按 [api-docs-swagger.md](../guides/api-docs-swagger.md) 完成一次 Authorize | [ ] |

## G. 文档已读（第 1 周）

| # | 材料 | 完成 |
| --- | --- | --- |
| G1 | `CONTEXT.md` | [ ] |
| G2 | `docs/audit/01-architecture.md` | [ ] |
| G3 | `docs/guides/api-docs-swagger.md` | [ ] |
| G4 | `docs/intern/README.md` + W1 任务书 | [ ] |

---

## 问题记录

| 日期 | 现象 | 已尝试 | 结果 / 谁协助 |
| --- | --- | --- | --- |
|  |  |  |  |

## 完成签字（可选）

- 实习生：________ 日期：________  
- 带教人确认环境可演示：________ 日期：________
