# 本地环境勾选清单

实习生按序完成并打勾；卡点记在文末「问题记录」。  
配置**仅用于本机**，不要把真实密码提交到 Git。

> **配合文档：**  
> - 概念不懂 → [07-zero-basics.md](./07-zero-basics.md)  
> - 怎么装 → [08-local-setup-step-by-step.md](./08-local-setup-step-by-step.md)  
> - 装完做什么 → [tasks/W1-login-and-user-list.md](./tasks/W1-login-and-user-list.md)

### 本机默认速查（勾选时对照）

| 项 | 常见值 |
| --- | --- |
| 后端 | `http://localhost:8080` |
| 前端 | `http://localhost`（以 `npm run dev` 终端为准） |
| 库名 | `ry-vue` |
| 管理员 | 用户名 `admin`，密码 `admin123`（导入本仓 SQL 后的常见默认） |
| Redis | `localhost:6379`，本地无密码时可留空 |
| 上传目录 `ruoyi.profile` | Linux/WSL 请改成如 `/home/你的用户名/ruoyi/uploadPath`，不要用仓库里的 `D:/...` |

---

## A. 工具链

| # | 检查项 | 命令示例 | 期望 | 完成 |
| --- | --- | --- | --- | --- |
| A1 | JDK 17+ | `java -version` | 含 `17` 或更高 | [ ] |
| A2 | Maven | `mvn -version` | 可运行，且指向 JDK 17 | [ ] |
| A3 | Node / npm | `node -v` / `npm -v` | 建议 Node 16+（以能装依赖为准） | [ ] |
| A4 | Git | `git --version` | 可运行 | [ ] |
| A5 | MySQL | 客户端可连接本机实例 | 能建库、能导入 SQL | [ ] |
| A6 | Redis | `redis-cli ping` | 返回 `PONG` | [ ] |

> 没有 JDK/Maven **无法编后端**。前端单独能 `npm run dev` 也不算环境完成。

---

## B. 代码与分支

| # | 检查项 | 说明 | 完成 |
| --- | --- | --- | --- |
| B1 | 克隆本仓库 | 使用导师给的 `origin` 地址 | [ ] |
| B2 | 默认分支为 `master` | `git checkout master && git pull` | [ ] |
| B3 | 个人分支 | `git checkout -b feature/<name>-onboarding` | [ ] |
| B4 | 不提交密钥 | `git status` / `git diff` 无密码、无 secret | [ ] |

**自检命令：**

```bash
git branch --show-current
# 应类似 feature/zhangsan-onboarding

git status
# 若改了 application-druid.yml 的密码，不要 add/commit 该文件（或只 commit 与密码无关的改动）
```

---

## C. 数据库

| # | 检查项 | 说明 | 完成 |
| --- | --- | --- | --- |
| C1 | 创建业务库 | 建议库名 `ry-vue` | [ ] |
| C2 | 导入主 SQL | `sql/ry_*.sql`（本仓示例：`sql/ry_20260417.sql`） | [ ] |
| C3 | 如需定时任务 | 按需导入 `sql/quartz.sql`（第 1 周可后补） | [ ] |
| C4 | 本地账号密码 | 只写在**本机** `application-druid.yml`，勿提交 | [ ] |

**导入后快速确认：**

```bash
mysql -u root -p -e "USE \`ry-vue\`; SELECT user_id, user_name FROM sys_user LIMIT 5;"
```

应能看到 `admin` 等用户。

---

## D. 后端配置与启动

| # | 检查项 | 说明 | 完成 |
| --- | --- | --- | --- |
| D1 | 阅读 `ruoyi-admin/src/main/resources/application.yml` | 端口、Redis、token、profile 等键名 | [ ] |
| D2 | 配置数据源 | 通常在 `application-druid.yml`（本机 URL/用户名/密码） | [ ] |
| D3 | Redis 地址/端口/密码 | 与本机一致；未设密码则按文件原写法留空 | [ ] |
| D4 | 启动后端 | IDEA 运行 `RuoYiApplication`，或根目录 `mvn -pl ruoyi-admin -am spring-boot:run` | [ ] |
| D5 | 健康检查 | 浏览器打开 `http://localhost:8080` 有响应（提示页/JSON 均可） | [ ] |

**注意：**

- 仓库可能含默认演示口令——**仅限本地**。  
- Linux/WSL 下务必将 `ruoyi.profile` 从 `D:/...` 改成可写路径，并 `mkdir -p`。

---

## E. 前端

| # | 检查项 | 说明 | 完成 |
| --- | --- | --- | --- |
| E1 | 进入 `ruoyi-ui` | `cd ruoyi-ui` | [ ] |
| E2 | 安装依赖 | `npm install`（慢可用 `npm install --registry=https://registry.npmmirror.com`） | [ ] |
| E3 | 开发代理 | 理解 `.env.development` 里 `VUE_APP_BASE_API=/dev-api` 会代理到后端 | [ ] |
| E4 | 启动 | `npm run dev` | [ ] |
| E5 | 浏览器登录 | 打开前端地址；账号 `admin` / `admin123`（以你导入的 SQL 为准） | [ ] |

**登录成功标志：** 进入带左侧菜单的主界面，不是一直停在登录页报错。

---

## F. 冒烟（业务）

| # | 检查项 | 完成 |
| --- | --- | --- |
| F1 | 系统管理 → 用户 / 角色 / 菜单 能打开，表格有数据 | [ ] |
| F2 | 系统管理 → 字典 能打开 | [ ] |
| F3 | 系统管理 → 通知公告 能打开（第 2 周会用到） | [ ] |
| F4 | 系统工具 → 系统接口（Swagger）能打开（若菜单存在） | [ ] |
| F5 | 按 [api-docs-swagger.md](../guides/api-docs-swagger.md) 完成一次 Authorize（可放在 W1 第 5 天） | [ ] |

---

## G. 文档已读（第 1 周）

| # | 材料 | 完成 |
| --- | --- | --- |
| G1 | [07-zero-basics.md](./07-zero-basics.md) | [ ] |
| G2 | [08-local-setup-step-by-step.md](./08-local-setup-step-by-step.md)（装环境时对照） | [ ] |
| G3 | [09-module-map.md](./09-module-map.md)（登录后扫菜单，边点边看） | [ ] |
| G4 | `CONTEXT.md`（可先扫后精读） | [ ] |
| G5 | `docs/audit/01-architecture.md`（登录章节） | [ ] |
| G6 | `docs/guides/api-docs-swagger.md` | [ ] |
| G7 | `docs/intern/README.md` + [W1 任务书](./tasks/W1-login-and-user-list.md) | [ ] |

---

## 第 1 周「算环境通过」的最低标准

同时满足：

1. A1～A6 基本完成（工具能跑）  
2. C2 已导入 SQL，能查到 `admin`  
3. D4/D5 后端起来  
4. E4/E5 前端起来且 **admin 能登录**  
5. F1 用户管理能看见表格数据  
6. B4 没有把密码提交进 Git  

未达标不要急着做 W1 第 3 天跟代码——先把环境修绿。

---

## 问题记录

| 日期 | 现象 | 已尝试 | 结果 / 谁协助 |
| --- | --- | --- | --- |
|  |  |  |  |

## 完成签字（可选）

- 实习生：________ 日期：________  
- 带教人确认环境可演示：________ 日期：________
