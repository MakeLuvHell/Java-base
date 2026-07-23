# W1 参考答案：登录说明 + 用户列表路径 + Swagger

> 导师对照用。实习生应用**自己的话**写；下列表述偏完整，便于你判断「是否讲到点子上」。  
> 关键路径以本仓库当前代码为准（约 2026 基线）。

---

## A. 登录链路说明（4 必答）

### 1. 验证码怎么校验？

**合格要点：**

- 登录接口会先校验验证码，再校验用户名密码。  
- 验证码答案短期存在 **Redis** 里，键前缀与 `captcha_codes:` + 前端传来的 `uuid` 有关。  
- 校验完会删掉该键（防重放）；错误或过期会登录失败。

**参考表述（导师版）：**

前端登录前会请求验证码接口拿到图片/算式和 `uuid`。用户提交登录时，请求体带 `username`、`password`、`code`、`uuid`。  
后端 `SysLoginController.login` → `SysLoginService.login` 里先调 `validateCaptcha`：用  
`CacheConstants.CAPTCHA_CODE_KEY`（`captcha_codes:`）+ `uuid` 从 Redis 取出正确答案，与用户输入比较；然后 **delete** 该 key。  
不匹配抛验证码错误；取不到则过期。配置可关闭验证码时可能跳过（以 `sys.account.captchaEnabled` 等为准）。

**对应代码（便于你带读）：**

- `SysLoginController`：`POST /login`  
- `SysLoginService.validateCaptcha`  
- `CacheConstants.CAPTCHA_CODE_KEY = "captcha_codes:"`

---

### 2. 登录成功后，JWT 和 Redis 分别干什么？

**合格要点（钥匙牌 / 行李 比喻即可）：**

- 客户端拿到一串 **token（JWT）**。  
- JWT 里主要是会话 id（uuid）等声明，**不是**把整个用户对象都塞进 JWT。  
- **Redis** 里用 `login_tokens:` + uuid 存完整的 `LoginUser`（用户、权限等会话信息）。  
- 后续请求带 JWT → 解析出 uuid → 去 Redis 取登录用户。

**参考表述：**

`TokenService.createToken`：生成 uuid，把 `LoginUser` 写入 Redis（`login_tokens:` + uuid，带过期时间），再签发 JWT，claims 中带 `login_user_key`（uuid）和用户名等。  
JWT 像**钥匙牌编号**；Redis 里是**寄存的行李（会话详情）**。吊销/退出主要删 Redis；只改 JWT 密钥是另一回事。

**配置提示：** `application.yml` 中 `token.header=Authorization`，`token.expireTime` 常见 30 分钟（以文件为准）。

---

### 3. 登录之后，前端请求怎么带身份？

**合格要点：**

- 请求头 **`Authorization`**。  
- 值常见为 **`Bearer ` + token**。  
- 前端把 token 存在 Cookie 键 **`Admin-Token`**（`ruoyi-ui/src/utils/auth.js`）。  
- 请求拦截器在 `ruoyi-ui/src/utils/request.js` 里自动附加 header。  
- 后端 `JwtAuthenticationTokenFilter` + `TokenService.getLoginUser` 解析并恢复登录用户。

**参考表述：**

登录成功后前端 `setToken` 写入 Cookie。axios 拦截器：`config.headers['Authorization'] = 'Bearer ' + getToken()`。  
后端从 header 去掉 `Bearer ` 前缀，解析 JWT 得 uuid，再读 Redis。

---

### 4. 退出登录时，系统大概清什么？

**合格要点：**

- **只删浏览器 Cookie/本地 token 不够**（服务端会话可能仍有效直到过期）。  
- 正确退出会打 **`/logout`**，服务端 `LogoutSuccessHandlerImpl` 调 `tokenService.delLoginUser` **删 Redis 会话**，并记退出日志。  
- 前端还会 `removeToken`、清 Vuex 用户状态等。

**参考表述：**

`SecurityConfig` 配置 `logoutUrl("/logout")`。成功处理器删除 Redis 中 `login_tokens:{uuid}`，返回成功 JSON。前端 logout 流程清 Cookie 与 store。

---

### 可选：Network 里常见现象

| 观察 | 期望 |
| --- | --- |
| 登录 | `POST /login`（经前端代理可能是 `/dev-api/login`） |
| 登录响应 | JSON 含 `token` 字段 |
| 登录后业务请求 | Header 含 `Authorization: Bearer ...` |
| 匿名可访问 | `/login`、`/captchaImage`、部分 swagger/druid（开发环境，生产应收敛） |

---

## B. 用户列表路径表（范例填法）

> 实习生表格单元格写不全没关系，**权限字符与 API→Controller 对应**必须对。

### 浏览器 Network

| 项 | 参考值 |
| --- | --- |
| 方法 | `GET` |
| URL | `/system/user/list`（浏览器里可能带 `/dev-api` 前缀与分页参数） |
| Authorization | 是 |
| 响应 | 常见 `code`、`rows`、`total`（TableDataInfo） |

### 路径表

| 步骤 | 前端文件与函数/位置 | 后端文件与方法 | 权限字符 |
| --- | --- | --- | --- |
| 菜单/路由 | 菜单「用户管理」；组件 `system/user/index`；动态路由来自登录后 `getRouters` | 菜单权限字符库表/角色分配 | 菜单侧常见 `system:user:list` |
| API 封装 | `ruoyi-ui/src/api/system/user.js` 的 **`listUser`** | — | — |
| 页面调用 | `views/system/user/index.vue` 的 **`getList`** → `listUser(...)` | — | 按钮另有 `v-hasPermi` |
| Controller | — | `SysUserController.list`：`@GetMapping("/list")`，类上 `@RequestMapping("/system/user")` | **`system:user:list`** |
| Service | — | `ISysUserService` / `SysUserServiceImpl.selectUserList` | — |
| Mapper/XML | — | `SysUserMapper.selectUserList` + `SysUserMapper.xml` 中同 id | — |

### 合格结论句示例

> 前端 `v-hasPermi` 只控制按钮显隐；列表接口真正拦截靠后端 `@PreAuthorize("@ss.hasPermi('system:user:list')")`。没有权限应 403，不能只靠藏按钮。

---

## C. Swagger 记录（范例）

```markdown
# W1 Swagger 记录（范例）

- 打开方式：系统工具 → 系统接口，或 http://localhost:8080/swagger-ui/index.html
- 使用的接口：GET /system/user/list（用户列表）
- Authorize：Bearer <token>（token 来自已登录 Network 的 Authorization 或登录接口）
- 有 Token 响应码：200，body 含 rows/total
- 去掉 Authorize 后再调：401（未认证）或项目统一未登录响应
- 注意：开发环境 swagger 可能 permitAll，生产必须收敛（见口头题 10）
```

---

## D. 批改时一票否决

- 作业整段粘贴 `docs/audit` 且无法口头复述  
- 提交了数据库密码 / token secret  
- 为「调通」注释掉安全校验（W1 一般不应改这些）
