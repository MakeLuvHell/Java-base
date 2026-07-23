# W1 口头验收题参考答（12 题）

来源：[docs/intern/02-reading-list.md](../intern/02-reading-list.md)  
建议：任选 **≥6 题**，15 分钟；鼓励大白话 + 能指文件。

评分记号：

- **合格**：说到要点  
- **优秀**：能指到模块/类/配置，或联系安全

---

## A. 架构与模块

### 1. 六个 Maven 模块各自职责？依赖方向？

**合格：**

| 模块 | 职责 |
| --- | --- |
| `ruoyi-admin` | 启动入口、Controller（HTTP 接口） |
| `ruoyi-framework` | Security、JWT、过滤器、框架配置 |
| `ruoyi-system` | 用户/角色/菜单等业务 Service、Mapper |
| `ruoyi-common` | 通用工具、常量、基础模型 |
| `ruoyi-quartz` | 定时任务 |
| `ruoyi-generator` | 代码生成 |

依赖方向直觉：**admin → framework → system → common**；quartz/generator 也依赖 common。不要 common 去依赖 admin。

**优秀：** 知道前端 `ruoyi-ui` 是独立 Node 工程，不在这六个 Java 模块里。

---

### 2. `ruoyi-admin` 和 `ruoyi-framework` 谁负责 Security / JWT？

**合格：** 主要在 **`ruoyi-framework`**（`SecurityConfig`、`TokenService`、JWT 过滤器、登录服务等）。  
`ruoyi-admin` 提供 `SysLoginController` 等入口，并启动应用。

---

### 3. 前端与后端边界？

**合格：**

- **前端 `ruoyi-ui`**：浏览器页面、路由、表格；开发时 `npm run dev`。  
- **后端**：提供 REST API，返回 JSON；**不**负责渲染整站 Vue 页面。  
- 开发期前端通过代理（如 `/dev-api`）转发到 `localhost:8080`。

---

## B. 登录与会话

### 4. 登录成功后客户端拿到什么？Redis？JWT？

**合格：**

- 客户端：响应里的 **token** 字符串。  
- Redis：`login_tokens:{uuid}` → `LoginUser` 会话。  
- JWT：声明里带会话 uuid（及用户名等），用于找回 Redis 中的会话。

**优秀：** 能区分「JWT 本身」和「Redis 里的 LoginUser」。

---

### 5. 后续请求如何带身份？快过期怎么办？

**合格：**

- Header：`Authorization: Bearer <token>`。  
- 过滤器解析 token，加载 `LoginUser`。  
- 快过期时会 **refreshToken** 续期 Redis 过期时间（代码里常见「剩余不足 20 分钟则刷新」）。

---

### 6. 退出登录清什么？

**合格：** 服务端删 Redis 登录缓存；前端删 Cookie 中 token 与本地用户状态。只清前端不够。

---

## C. 权限三层

### 7. 菜单权限 / 方法权限 / 数据权限分别解决什么？

| 层 | 解决什么 |
| --- | --- |
| 菜单/路由 | 侧边栏/路由能不能进这个页面 |
| 按钮/方法 `@PreAuthorize` | 能不能调用某个 API |
| 数据权限 `dataScope` | 能看全公司数据还是本部门/仅本人 |

**合格：** 能用自己的话区分「看不看得到页面」「能不能调接口」「能看哪些行」。

---

### 8. `v-hasPermi` 藏按钮后，后端还有没有校验？

**合格：** **必须还有**。前端隐藏可被绕过（改请求/Swagger/curl）。后端 `@PreAuthorize` 才是强制门禁。  
**一票相关：** 若实习生认为「前端藏了就安全」→ 不合格，需纠正。

---

### 9. 动态路由从哪来？前端怎么变成可访问路由？

**合格：**

- 登录后调 **`getRouters`**（`SysLoginController`）拿到当前用户菜单树。  
- 前端 `permission.js` 等逻辑把后端菜单转成 Vue Router 路由并 `addRoutes`（具体 API 名以代码为准）。  
- 无菜单权限则不会生成对应路由。

---

## D. 工具与安全意识

### 10. Swagger 开发怎么开？生产为什么收敛？

**合格：**

- 开发：菜单「系统工具 → 系统接口」或 `/swagger-ui/index.html`；Authorize 后调试。  
- 生产：Swagger/Druid 等若 `permitAll` 等于扩大攻击面，应关闭或鉴权/内网（审计 SEC-003 一类）。

---

### 11. 为什么不能把 `application-druid.yml` 默认口令用于公网？

**合格：** 演示默认密码公开可知；公网会被扫库、拖库。密钥/口令须本地自用并轮换，且**不进 Git 真实密钥**。

---

### 12. 审计 P1 大致有哪些类问题？

**合格（能举 3 类即可）：**

- 默认 JWT secret / 弱口令类（SEC-001/002 一类）  
- 运维端点暴露：Swagger、Druid 匿名可访问（SEC-003）  
- 代码生成器误用、危险 SQL/任务、文件上传等（SEC-007/009 等）  

不要求背编号，要求有「默认配置不能上公网」意识。

---

## 口头验收记录表（可打印）

| 题号 | 合格 | 备注 |
| --- | --- | --- |
| 1 | [ ] |  |
| 2 | [ ] |  |
| 3 | [ ] |  |
| 4 | [ ] |  |
| 5 | [ ] |  |
| 6 | [ ] |  |
| 7 | [ ] |  |
| 8 | [ ] |  |
| 9 | [ ] |  |
| 10 | [ ] |  |
| 11 | [ ] |  |
| 12 | [ ] |  |

**W1 口头建议通过线：** 抽 6 题中至少 5 题合格，且 **第 8 题必须合格**。
