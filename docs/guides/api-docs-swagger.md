# API 文档与在线调试（SpringDoc / Swagger UI）使用指南

本文说明本仓库中 **API 接口文档** 与 **在线试调** 由哪几部分构成、如何打开、如何带 Token 调试、默认扫描范围、如何扩展业务接口，以及开发/生产注意点。

> 技术栈：Spring Boot 4 + **SpringDoc OpenAPI**（`springdoc-openapi-starter-webmvc-ui`）+ Swagger UI。  
> 当前父 POM 属性示例：`springdoc.version`（见根 `pom.xml`）。

---

## 1. 它是什么、不是什么

| 是 | 不是 |
| --- | --- |
| 基于 OpenAPI 3 的接口文档 UI | 独立的 Postman/Apifox 云服务 |
| 可在浏览器里对接口点 “Try it out” 发请求 | 完整自动化集成测试框架 |
| 后台菜单 **系统工具 → 系统接口** 的内嵌入口 | **代码生成**、**表单构建**（同目录下的其它工具） |

同属「系统工具」的其它菜单对比：

| 菜单 | 组件路径 | 用途 |
| --- | --- | --- |
| 系统接口 | `tool/swagger/index` | API 文档 + 在线调试（本文） |
| 代码生成 | `tool/gen/index` | 按表生成前后端代码 |
| 表单构建 | `tool/build/index` | 拖拽表单设计 |

---

## 2. 相关文件与职责

| 文件 | 职责 |
| --- | --- |
| `ruoyi-admin/src/main/resources/application.yml` | `springdoc.*`：UI 开关、文档路径、**扫描包**、分组名 |
| `ruoyi-admin/src/main/java/com/ruoyi/web/core/config/SwaggerConfig.java` | OpenAPI 标题/版本；全局安全方案（请求头 `Authorization`） |
| `ruoyi-admin/src/main/java/com/ruoyi/web/controller/tool/TestController.java` | 默认会被扫到的**演示接口**（`/test/user/**`） |
| `ruoyi-framework/.../config/SecurityConfig.java` | 将 swagger / api-docs 路径 `permitAll`（匿名可打开文档页） |
| `ruoyi-framework/.../config/ResourcesConfig.java` | 部分 swagger 静态资源映射（历史 springfox 路径残留，实际 UI 由 springdoc 提供） |
| `ruoyi-ui/src/views/tool/swagger/index.vue` | 管理端 iframe 页面，加载 Swagger UI |
| `ruoyi-ui/vue.config.js` | 开发代理：`VUE_APP_BASE_API` → 后端；`/v3/api-docs` 代理 |
| `ruoyi-ui/.env.development` 等 | `VUE_APP_BASE_API`（开发默认 `/dev-api`） |
| `sql/ry_*.sql` | 菜单「系统接口」初始化数据 |
| 根 `pom.xml` / `ruoyi-admin/pom.xml` | 依赖 `springdoc-openapi-starter-webmvc-ui` |

菜单初始化（示意，以仓库 SQL 为准）：

- 菜单名称：`系统接口`
- 路由地址：`swagger`
- 组件：`tool/swagger/index`
- 权限字符：`tool:swagger:list`
- 父级：系统工具（`tool`）

---

## 3. 前置条件

1. **后端已启动**（默认 `server.port=8080`，见 `application.yml`）。
2. **数据库已导入** RuoYi 初始化 SQL，否则可能没有「系统工具 → 系统接口」菜单（仍可用浏览器直连 Swagger URL）。
3. 使用菜单入口时：前端已启动，且当前登录用户具备 `tool:swagger:list`（管理员角色通常具备）。
4. Redis、数据源等按项目 README 正常配置，保证登录与业务接口可用（演示 `/test/user` 接口本身用内存数据，不依赖库表）。

---

## 4. 如何打开文档

### 4.1 管理后台菜单（推荐）

1. 启动后端与前端（前端开发默认代理到 `http://localhost:8080`）。
2. 使用管理员账号登录。
3. 左侧导航：**系统工具 → 系统接口**。
4. 页面通过 iframe 加载：

   ```text
   {VUE_APP_BASE_API}/swagger-ui/index.html
   ```

   开发环境下 `VUE_APP_BASE_API` 一般为 `/dev-api`，经 `vue.config.js` 代理后实际访问后端的：

   ```text
   http://localhost:8080/swagger-ui/index.html
   ```

对应前端代码：`ruoyi-ui/src/views/tool/swagger/index.vue`。

### 4.2 浏览器直连后端（不依赖前端菜单）

在后端已启动的前提下，可直接访问：

| URL | 说明 |
| --- | --- |
| `http://localhost:8080/swagger-ui/index.html` | Swagger UI 主页面（常用） |
| `http://localhost:8080/swagger-ui.html` | `application.yml` 中 `springdoc.swagger-ui.path` 配置值，通常会转到 UI |
| `http://localhost:8080/v3/api-docs` | OpenAPI 3 JSON 原始文档 |
| `http://localhost:8080/v3/api-docs/default` | 分组文档（与 `group-configs` 的 group 名相关，以实际返回为准） |

上述文档相关路径在 `SecurityConfig` 中配置为 **permitAll**，因此**无需登录即可打开文档页**。  
注意：打开文档 ≠ 能调用所有业务接口；业务接口仍受 JWT 与 `@PreAuthorize` 约束。

### 4.3 开发代理说明

`ruoyi-ui/vue.config.js` 中：

- `[VUE_APP_BASE_API]`（如 `/dev-api`）→ 转发到 `http://localhost:8080`，并去掉前缀。
- `^/v3/api-docs/(.*)` → 额外转发 OpenAPI 文档，避免部分 UI 拉 schema 失败。

若直连 Swagger 正常、菜单 iframe 空白，优先检查：

1. 前端 `VUE_APP_BASE_API` 是否与网关/代理一致；
2. 浏览器控制台是否有 iframe / 混合内容 / 跨域错误；
3. 后端是否监听 8080、springdoc 是否 `enabled: true`。

---

## 5. 默认扫描范围（非常重要）

`application.yml` 中默认类似：

```yaml
springdoc:
  api-docs:
    path: /v3/api-docs
  swagger-ui:
    enabled: true
    path: /swagger-ui.html
    tags-sorter: alpha
  group-configs:
    - group: 'default'
      display-name: '测试模块'
      paths-to-match: '/**'
      packages-to-scan: com.ruoyi.web.controller.tool
```

含义：

- **UI 默认开启**（`swagger-ui.enabled: true`）。
- 只扫描包 **`com.ruoyi.web.controller.tool`**。
- 因此界面上默认主要是 **测试模块** 里的接口，**不会自动列出** 全部 `system` / `monitor` 业务 Controller。

默认演示控制器：`TestController`，基础路径 `/test/user`。

| 方法 | 路径 | 摘要（注解） |
| --- | --- | --- |
| GET | `/test/user/list` | 获取用户列表 |
| GET | `/test/user/{userId}` | 获取用户详细 |
| POST | `/test/user/save` | 新增用户 |
| PUT | `/test/user/update` | 更新用户 |
| DELETE | `/test/user/{userId}` | 删除用户信息 |

数据保存在进程内 `Map`，**重启后端即丢失**，仅用于熟悉 Swagger 操作，不是真实用户体系。

---

## 6. 在 Swagger UI 里如何调试

### 6.1 调试演示接口（/test/user）

1. 打开 Swagger UI。
2. 找到分组/标签 **用户信息管理**（`@Tag`）。
3. 展开接口 → **Try it out** → 填写参数 → **Execute**。
4. 查看 **Responses** 中的 HTTP 状态码与 JSON Body。

演示接口通常不依赖登录态即可调用（仍以当前 Security 配置为准）。

### 6.2 调试需要登录的业务接口

若已扩大扫描范围并展示出业务 API：

1. **先登录系统**（管理端或调用 `POST /login`），从响应中取出 `token` 字段。
2. 在 Swagger UI 点击 **Authorize**（锁形图标）。
3. 在 `apikey` / `Authorization` 方案中填入：

   ```text
   Bearer <你的token完整字符串>
   ```

   注意：一般需要带 `Bearer ` 前缀与空格（与前端请求拦截器一致）。  
   安全方案定义见 `SwaggerConfig`：类型 APIKEY，header 名 `Authorization`。

4. 确认后，再对需要鉴权的接口 **Try it out → Execute**。
5. 若返回 401：Token 无效/过期/格式错误。  
   若返回 403：已登录但缺少 `@PreAuthorize` 要求的权限字符。

### 6.3 获取 Token 的常用方式

**方式 A：管理端登录**

1. 浏览器登录后台。
2. 开发者工具 → Application / Storage → 查看项目存放 Token 的 Cookie 或 LocalStorage 键（常见与 `Admin-Token` 等相关，以当前 `ruoyi-ui/src/utils/auth.js` 为准）。
3. 或在 Network 里找到 `login` 响应 JSON 的 `token` 字段。

**方式 B：直接调登录接口**

```http
POST /login
Content-Type: application/json

{
  "username": "admin",
  "password": "你的密码",
  "code": "验证码",
  "uuid": "验证码uuid"
}
```

验证码接口一般为 `/captchaImage`（以实际代码为准）。成功响应中含 `token`，再填入 Swagger Authorize。

---

## 7. 如何让文档覆盖业务接口

### 7.1 扩大扫描包（最常见）

编辑 `ruoyi-admin/src/main/resources/application.yml`：

```yaml
springdoc:
  group-configs:
    - group: 'default'
      display-name: '全部 Web 接口'
      paths-to-match: '/**'
      packages-to-scan: com.ruoyi.web.controller
```

或按模块拆分组，例如：

```yaml
springdoc:
  group-configs:
    - group: 'tool'
      display-name: '工具与测试'
      packages-to-scan: com.ruoyi.web.controller.tool
    - group: 'system'
      display-name: '系统管理'
      packages-to-scan: com.ruoyi.web.controller.system
```

修改后 **重启后端**，刷新 Swagger UI。

> `ruoyi-quartz`、`ruoyi-generator` 等模块的 Controller 不在 `com.ruoyi.web.controller` 包下时，需把对应包名一并加入 `packages-to-scan`（可逗号分隔或多个 group，以 springdoc 版本文档为准）。

### 7.2 在代码上补充注解（让文档更可读）

| 注解 | 用途 | 示例位置 |
| --- | --- | --- |
| `@Tag` | 分组/标签名 | 类上 |
| `@Operation` | 接口摘要、说明 | 方法上 |
| `@Schema` | 模型字段说明 | DTO/实体字段 |
| `@Parameter` / `@RequestBody` 等 | 参数说明 | 按需 |

参考：`TestController` 已使用 `@Tag`、`@Operation`、`@Schema`。

业务 Controller 即使没有注解，只要被 `packages-to-scan` 扫到，通常仍会出现在文档中，但说明会较简陋。

### 7.3 开关与路径

| 配置项 | 作用 |
| --- | --- |
| `springdoc.swagger-ui.enabled` | 是否启用 UI |
| `springdoc.swagger-ui.path` | UI 入口 path 配置 |
| `springdoc.api-docs.path` | OpenAPI JSON 路径 |

生产环境建议关闭 UI 或限制访问，见第 9 节。

---

## 8. 与前端联调时的路径习惯

| 环境 | 前端请求前缀 | 实际后端 |
| --- | --- | --- |
| development | `/dev-api` | 代理到 `http://localhost:8080` |
| production | `/prod-api` | 由 Nginx 等反代到后端 |
| staging | `/stage-api` | 视部署而定 |

Swagger 在菜单中使用同一 `VUE_APP_BASE_API` 前缀拼接 `/swagger-ui/index.html`。  
直接调试后端时，可忽略该前缀，使用 `http://localhost:8080/...`。

---

## 9. 安全与生产建议

1. **文档路径默认匿名可访问**（`SecurityConfig` 中 swagger、`/v3/api-docs/**`、`/druid/**` 等 `permitAll`）。  
   - 内网开发方便；**公网暴露有信息泄露与攻击面放大风险**。  
   - 详见仓库审计：`docs/audit/03-security.md` 中 **SEC-003**。
2. 生产建议：
   - `springdoc.swagger-ui.enabled: false`，或
   - 仅内网 / VPN / IP 白名单可访问，并从 Security `permitAll` 中移除后改为需登录。
3. **Authorize 填入的 Token 等同于登录态**，不要在共享屏幕或录屏中泄露。
4. 演示接口 `TestController` 含示例账号字符串，仅作文档演示，勿当作生产用户数据。

---

## 10. 常见问题

### 10.1 菜单里打开是空白页

- 后端未启动或端口不是 8080。  
- 前端代理未生效（检查 `vue.config.js` 与 `.env.development`）。  
- 浏览器拦截混合内容或第三方 Cookie（可改用直连 `http://localhost:8080/swagger-ui/index.html` 验证）。

### 10.2 文档里几乎没有业务接口

- 默认 `packages-to-scan: com.ruoyi.web.controller.tool`，只含测试包。  
- 按第 7 节扩大扫描并重启。

### 10.3 Try it out 返回 401

- 未 Authorize，或 Token 过期。  
- Header 格式错误（缺少 `Bearer ` 前缀等）。  
- Redis 中会话已失效（本系统为 JWT + Redis 会话模型）。

### 10.4 Try it out 返回 403

- Token 有效，但当前用户没有该接口的 `@PreAuthorize` 权限。  
- 使用具备对应权限的角色账号重新登录取 Token。

### 10.5 `/v3/api-docs` 404 或启动报错

- 确认 `ruoyi-admin` 已引入 `springdoc-openapi-starter-webmvc-ui`。  
- 确认没有错误地关闭 api-docs。  
- 查看启动日志中 springdoc 相关报错。

### 10.6 没有「系统接口」菜单

- 未导入完整 SQL，或角色未分配该菜单。  
- 可用浏览器直连 Swagger URL，不依赖菜单。  
- 管理员可在 **系统管理 → 菜单管理 / 角色管理** 中检查 `tool:swagger:list`。

### 10.7 与旧版 springfox 的关系

- 当前栈以 **SpringDoc** 为准。  
- `ResourcesConfig` 中仍可能残留 springfox 静态资源路径注释/映射，不影响以 `/swagger-ui/index.html` 与 `/v3/api-docs` 为主的使用方式。

---

## 11. 快速检查清单

- [ ] 后端启动成功，端口 8080  
- [ ] 浏览器打开 `http://localhost:8080/swagger-ui/index.html` 能看到 UI  
- [ ] `http://localhost:8080/v3/api-docs` 返回 JSON  
- [ ] 能展开并执行 `/test/user/list`  
- [ ]（可选）登录后 Authorize 填入 `Bearer <token>` 再调业务接口  
- [ ]（可选）前端菜单 **系统工具 → 系统接口** 能嵌入同一 UI  
- [ ] 生产环境已关闭或限制 swagger 访问  

---

## 12. 相关文档

| 文档 | 说明 |
| --- | --- |
| [docs/audit/01-architecture.md](../audit/01-architecture.md) | 系统架构与请求链路 |
| [docs/audit/03-security.md](../audit/03-security.md) | 安全审计（含 swagger 暴露 SEC-003） |
| [docs/audit/04-remediation-roadmap.md](../audit/04-remediation-roadmap.md) | 整改路线中关闭/收敛文档暴露的建议 |
| [docs/guides/ci-cd-pipeline.md](./ci-cd-pipeline.md) | CI/CD 与工程流水线（构建/测试/扫描/发布） |
| 项目根 [README.md](../../README.md) | 官方运行与部署说明 |

---

## 13. 修订记录

| 日期 | 说明 |
| --- | --- |
| 2026-07-21 | 初版：结构、打开方式、默认扫描范围、Token 调试、扩展与排障 |
