# 安全审计

## 结论摘要

本仓库具备较完整的后台安全骨架：BCrypt 密码、验证码、登录失败锁定、JWT+Redis 会话、方法级权限、数据权限切面、XSS 过滤器、上传扩展名白名单、定时任务调用白名单等。主要风险集中在 **默认密钥/口令与运维端点默认开放**、**CORS 过宽**、**同进程暴露 Druid/Swagger**、**数据权限与生成器中的 `${}` SQL 拼接面**，以及 **前端 HTML 渲染出口**。当前环境无 JDK/Maven，依赖 CVE 扫描与后端动态验证未能执行。

## 风险分级与状态

| 严重度 | 含义 |
| --- | --- |
| P0 | 可导致系统级紧急损害 |
| P1 | 高影响，应优先修复 |
| P2 | 中等风险或纵深防御缺口 |
| P3 | 低风险与维护性改进 |

| 状态 | 含义 |
| --- | --- |
| 已确认问题 | 代码行为足以证明 |
| 条件性风险 | 特定部署/配置下成立 |
| 设计观察 | 非直接可利用，但增加成本 |
| 未能动态验证 | 工具或环境限制 |

## 风险台账

| ID | 标题 | 严重度 | 置信度 | 状态 |
| --- | --- | --- | --- | --- |
| SEC-001 | 默认 JWT 签名密钥写入配置 | P1 | 高 | 条件性风险 |
| SEC-002 | 数据源与 Druid 控制台使用默认口令类配置 | P1 | 高 | 条件性风险 |
| SEC-003 | `/druid/**` 与 Swagger 在 Security 层 permitAll | P1 | 高 | 条件性风险 |
| SEC-004 | CORS 允许任意 Origin Pattern | P2 | 高 | 已确认问题 |
| SEC-005 | CSRF 关闭（无状态 JWT 设计） | P3 | 高 | 设计观察 |
| SEC-006 | 数据权限 `${params.dataScope}` 字符串拼接 | P2 | 中 | 设计观察 |
| SEC-007 | 代码生成建表路径使用 `${sql}` | P1 | 高 | 条件性风险 |
| SEC-008 | 定时任务反射调用面（已有白名单） | P2 | 中 | 条件性风险 |
| SEC-009 | 上传目录经 `/profile/**` 匿名可读 | P2 | 高 | 条件性风险 |
| SEC-010 | XSS 过滤范围有限 + 前端 `v-html` 出口 | P2 | 中 | 条件性风险 |
| SEC-011 | 开发态日志级别 `com.ruoyi: debug` | P3 | 高 | 设计观察 |
| SEC-012 | 依赖漏洞与构建验证未执行 | P2 | 低 | 未能动态验证 |
| SEC-013 | 仓库无自动化测试 | P3 | 高 | 设计观察 |

### SEC-001 默认 JWT 签名密钥写入配置

- **影响：** 若生产沿用仓库默认 `token.secret`，攻击者可伪造 JWT claims 中的会话 UUID 指针；完整利用仍需匹配 Redis 中会话或进一步攻击，但密钥可预测显著降低伪造成本。
- **条件：** 部署未轮换 `token.secret`；密钥出现在版本库中。
- **证据：** `application.yml` 存在 `token.secret` 配置键及仓库默认值（文档不复制具体值）；`TokenService` 使用该 secret 做 HS512 签名与解析（`TokenService.java:42-43`、`179-183`、`193-198`）。
- **建议：** 生产强制环境变量/密钥管理注入；拒绝默认值启动；轮换后使全部会话失效。
- **验证：** 部署清单检查 secret 非默认；启动时配置校验。

### SEC-002 数据源与 Druid 控制台使用默认口令类配置

- **影响：** 数据库与 Druid 控制台若以仓库默认凭据暴露到可达网络，可导致数据泄露或控制台滥用。
- **条件：** `application-druid.yml` 中数据源凭据与 `statViewServlet` 登录凭据未在部署时替换；Druid 控制台可网络访问。
- **证据：** `application-druid.yml` 含 `spring.datasource.druid.master.username/password` 与 `statViewServlet.login-username/login-password` 键；`allow` 白名单为空注释为允许所有（`application-druid.yml:10-11`、`44-51`）。
- **建议：** 部署密钥注入；Druid `allow` 限制管理网段；生产关闭或鉴权强化控制台。
- **验证：** 配置扫描确认无默认口令；网络层确认 `/druid/*` 不可公网访问。

### SEC-003 `/druid/**` 与 Swagger 在 Security 层 permitAll

- **影响：** 未认证用户即可访问 API 文档与 Druid 路径（后者仍可能有自身登录，但入口不再经业务认证）。
- **条件：** 服务对不可信网络暴露；swagger-ui enabled；Druid servlet enabled。
- **证据：** `SecurityConfig.java:106` permitAll swagger 与 `/druid/**`；`application.yml` `springdoc.swagger-ui.enabled: true`（`120-125`）；Druid `statViewServlet.enabled: true`（`application-druid.yml:44-45`）。
- **建议：** 生产关闭 springdoc UI 与 Druid 控制台，或置于管理端鉴权/IP 限制之后。
- **验证：** 未带 Token 访问 `/swagger-ui.html`、`/druid/index.html` 的响应码与暴露面。

### SEC-004 CORS 允许任意 Origin Pattern

- **影响：** 浏览器侧任意来源可对 API 发起跨域请求（配合用户 Token 的 CSRF 类场景取决于前端存 Token 方式）；扩大跨域滥用面。
- **条件：** 浏览器环境 + 用户令牌可被跨站请求携带或读取的存储方式。
- **证据：** `ResourcesConfig.corsFilter` `addAllowedOriginPattern("*")`、允许所有头与方法（`ResourcesConfig.java:57-68`）。
- **建议：** 配置显式允许的前端 Origin 列表；禁用以凭证场景下的 `*`。
- **验证：** 使用非信任 Origin 预检，确认被拒绝。

### SEC-005 CSRF 关闭（无状态 JWT 设计）

- **影响：** 不依赖 Cookie Session 的常见 CSRF 面下降，但若 Token 存 Cookie 且自动携带，则缺少 CSRF 令牌。
- **条件：** 前端将 JWT 存于可自动发送的 Cookie。
- **证据：** `SecurityConfig` `csrf.disable()` 注释说明不使用 session（`SecurityConfig.java:89-90`、`97-98`）。
- **建议：** 保持 Token 于内存/`localStorage` 并手动加头则与现状一致；若改 Cookie 方案需同步 CSRF。
- **验证：** 审查前端 `utils/auth.js` 存储位置与请求拦截器。

### SEC-006 数据权限 `${params.dataScope}` 字符串拼接

- **影响：** MyBatis `${}` 不做预编译占位；若 `params.dataScope` 被污染可导致 SQL 注入。当前由 `DataScopeAspect` 服务端写入，正常路径为可信拼接。
- **条件：** 调用方传入可被用户控制的 `params.dataScope`，或绕过切面。
- **证据：** `DataScopeAspect` 写入过滤片段（`DataScopeAspect.java:35-55`、`90-120`）；Mapper `${params.dataScope}`（如 `SysUserMapper.xml:86`）。
- **建议：** 保持仅切面写入；可改为结构化条件 API；审计所有 `${}` 点。
- **验证：** 静态确认无控制器把用户输入写入 `params.dataScope`。

### SEC-007 代码生成建表路径使用 `${sql}`

- **影响：** 高权限用户可执行建表 SQL；若授权过宽或账号被盗，等同数据库结构级写能力。
- **条件：** 攻击者具备 `tool:gen` 相关权限；接口可达。
- **证据：** `GenController.createTableSave` 接收 SQL（`GenController.java:130-145`）；`GenTableMapper.xml` `${sql}`（约 178 行）；`GenTableServiceImpl.createTable`（`161-163`）。
- **建议：** 生产禁用代码生成模块；限制权限与网络；仅允许 DDL 子集。
- **验证：** 无权限用户调用应 403；生产构建排除 generator。

### SEC-008 定时任务反射调用面（已有白名单）

- **影响：** 任务配置最终 `Class.forName` / `Method.invoke`（`JobInvokeUtil.java:23-38`）。若白名单被绕过，可导致远程代码执行类影响。
- **条件：** 具备任务管理权限且绕过 `ScheduleUtils.whiteList` / 危险串检查；或白名单包内存在危险 bean。
- **证据：** 控制器拒绝 RMI/LDAP/HTTP 与 `JOB_ERROR_STR`，并要求白名单（`SysJobController.java:90-110` 一带）；白名单默认 `com.ruoyi.quartz.task`（`Constants.java:166`）；错误串含 `URL`、`InitialContext` 等（`Constants.java:171+`）。
- **建议：** 维持白名单最小化；禁止生产热配置未知目标；监控任务变更审计日志。
- **验证：** 尝试非法 `invokeTarget` 应被拒绝；审查白名单包内容。

### SEC-009 上传目录经 `/profile/**` 匿名可读

- **影响：** 上传成功的文件若可知 URL，未认证即可 GET；敏感文件误上传会泄露。
- **条件：** 文件名/路径可被猜测或泄露；文件落在 profile 映射下。
- **证据：** `SecurityConfig` GET `/profile/**` permitAll（`105`）；`ResourcesConfig` 映射到本地 profile（`32-34`）；下载另有 `checkAllowDownload` 防 `..` 与扩展名校验（`FileUtils.java:153-168`）。
- **建议：** 敏感附件改为鉴权下载接口；随机化路径；生产 CDN/鉴权网关。
- **验证：** 未登录访问已知上传 URL 是否 200。

### SEC-010 XSS 过滤范围有限 + 前端 `v-html` 出口

- **影响：** 存储型/反射型 HTML 若进入 `v-html` 可能在管理端执行脚本。
- **条件：** XSS 过滤器未覆盖的路径写入富文本；公告等内容被 `v-html` 渲染。
- **证据：** XSS 配置匹配 `/system/*` 等并排除 `/system/notice`（`application.yml:141-147`）；`XssFilter`/`EscapeUtil.clean`（`XssFilter.java`、`XssHttpServletRequestWrapper.java:40-41`）；富文本 `Editor` 使用 `Quill.clipboard.dangerouslyPasteHTML` 并读 `innerHTML`（`ruoyi-ui/src/components/Editor/index.vue:112,141-143`）；公告详情 `v-html="detail.noticeContent"`（`HeaderNotice/DetailView.vue:45`）；另有 HeaderSearch 高亮、导入结果 `dangerouslyUseHTMLString`。
- **建议：** 公告等富文本服务端白名单消毒；Editor 输出消毒；前端避免不可信 `v-html`；CSP。
- **验证：** 在排除路径写入脚本标签后以普通用户查看是否执行（授权测试环境）。

### SEC-011 开发态日志级别 `com.ruoyi: debug`

- **影响：** 可能记录过多请求/业务细节，增加日志泄露与磁盘压力。
- **条件：** 生产沿用 debug。
- **证据：** `application.yml:35-38`。
- **建议：** 生产 `info`/`warn`；脱敏。
- **验证：** 生产配置与日志抽样。

### SEC-012 依赖漏洞与构建验证未执行

- **影响：** 未知 CVE 或不可构建状态未被本轮确认。
- **条件：** 当前环境无 Java/Maven；npm 无 lockfile。
- **证据：** 基线命令 `java`/`mvn` not found；`src/test` 0 文件；无 package-lock。
- **建议：** 在具备 JDK17 的 CI 中执行 `mvn test/package` 与 OWASP Dependency-Check、`npm audit`。
- **验证：** CI 产出报告。

### SEC-013 仓库无自动化测试

- **影响：** 权限与回归依赖人工，安全修复易回退。
- **条件：** 持续。
- **证据：** 盘点 `src/test` 文件数 0。
- **建议：** 至少补充登录鉴权与关键权限的集成测试。
- **验证：** 测试目录与 CI。

## 认证与会话

| 控制 | 实现 | 证据 |
| --- | --- | --- |
| 验证码 | Redis `captcha_codes:`，可配置开关 | `SysLoginService.validateCaptcha` `110-128` |
| 密码错误锁定 | `maxRetryCount`/`lockTime` + Redis 计数 | `SysPasswordService`；`application.yml:41-46` |
| 密码存储 | BCrypt | `SecurityConfig.bCryptPasswordEncoder` `123-126` |
| 登录编排 | captcha → preCheck → authenticate → createToken | `SysLoginService.login` `63-99` |
| IP 黑名单 | 配置 `sys.login.blackIPList` | `loginPreCheck` `158-163` |
| JWT+Redis | UUID 入 claims，LoginUser 入 Redis | `TokenService` |
| 续期 | 剩余 ≤20 分钟刷新 | `TokenService.verifyToken` |
| 退出 | `/logout` 删除缓存 | `SecurityConfig` + Logout handler |

## 授权与数据权限

- URL：默认 `anyRequest().authenticated()`，显式 permitAll 列表见架构文档（`SecurityConfig.java:100-108`）。
- 方法：`@EnableMethodSecurity`；Controller 层大量 `@PreAuthorize`（admin/quartz/generator 约 116 处）。
- 权限 bean：`PermissionService` `hasPermi`/`hasRole`。
- 数据权限：`@DataScope` + `DataScopeAspect`；管理员跳过（`DataScopeAspect.java:49-54`）。
- 前端按钮隐藏不能替代后端注解。

## 输入、输出与注入面

| 面 | 控制/风险 |
| --- | --- |
| Order by | `SqlUtil.escapeOrderBySql` 白名单模式与长度限制（`SqlUtil.java:31-42`） |
| 关键字过滤 | `SqlUtil.filterKeyword`（`55-71`） |
| 数据权限 SQL | `${params.dataScope}`（SEC-006） |
| 生成器 SQL | `${sql}`（SEC-007） |
| XSS 请求过滤 | `XssFilter` 按 urlPatterns（SEC-010） |
| 全局异常 | `GlobalExceptionHandler` 统一出口 |

## 文件上传、下载与路径

- 上传扩展名：`MimeTypeUtils.DEFAULT_ALLOWED_EXTENSION`（`FileUploadUtils`）。
- 大小：multipart 10MB/20MB（`application.yml:57-61`）。
- 下载：禁止 `..` + 扩展名允许列表（`FileUtils.checkAllowDownload`）。
- 静态映射匿名读：SEC-009。

## 定时任务与代码生成

- 任务：白名单 + 危险串拒绝 + `@PreAuthorize`（SEC-008）。
- 生成：预览/下载/写盘/建表均需工具权限；建表 DDL 风险见 SEC-007。
- 生产建议禁用或网络隔离 generator 与 job 管理接口。

## 运维端点与外部暴露

| 端点/能力 | 安全层 | 备注 |
| --- | --- | --- |
| `/druid/**` | permitAll | 另有 Druid 登录；allow 空则宽（SEC-002/003） |
| springdoc/swagger | permitAll + enabled | SEC-003 |
| `/profile/**` GET | permitAll | SEC-009 |
| 监控业务 API | 通常需认证+权限 | 仍属高权限功能面 |
| CORS `*` | 全局 | SEC-004 |

## 配置、秘密与日志

- 版本库中存在默认 secret/口令类配置键（SEC-001/002）；**报告不复制值**。
- `logging.level.com.ruoyi: debug`（SEC-011）。
- 登录成功/失败异步记 `AsyncFactory.recordLogininfor`。
- Referer 防盗链默认 `enabled: false`（`application.yml:134-136`）。

## 依赖与供应链

| 检查 | 结果 |
| --- | --- |
| `mvn dependency:tree` / OWASP | 未能执行（无 Maven） |
| `npm install --no-package-lock --ignore-scripts` | 2026-07-21 成功，1476 packages；deprecated 含 Vue 2 EOL、highlight.js 9.x 等 |
| `npm run build:prod` | 2026-07-21 成功，`dist` 约 7.3M（未入库） |
| `npm audit --omit=dev` | 失败：`ENOLOCK`（无 lockfile，未生成 lockfile） |
| 直接依赖版本 | 见 `pom.xml` 属性与 `ruoyi-ui/package.json`（如 axios 0.30.3、element-ui 2.15.14） |
| 测试 | 无 `src/test` |

## 已有安全控制

1. 无状态 JWT + Redis 可吊销会话。  
2. BCrypt、验证码、失败锁定、IP 黑名单配置点。  
3. 方法级权限 + 数据权限切面。  
4. XSS Filter + 部分字段 `@Xss`。  
5. 上传/下载扩展名与路径穿越基础防护。  
6. Quartz 调用白名单与协议黑名单。  
7. 防重复提交拦截器（`ResourcesConfig`）。  
8. OrderBy SQL 规范化。

## 动态验证限制

1. 无 JDK/Maven：无法编译、测试、依赖树与 OWASP 扫描。  
2. 未连接目标 MySQL/Redis 做在线利用验证。  
3. 未启动完整前后端做浏览器 CORS/XSS 动态复现。  
4. 前端 `build:prod` 已通过；`npm audit` 仍因无 lockfile 不可用。
5. 所有“条件性风险”需在实际部署配置确认后升级为已确认或降级关闭。
