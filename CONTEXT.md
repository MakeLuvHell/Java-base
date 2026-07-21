# 项目上下文

## 系统边界

**RuoYi-Vue**：
基于 Spring Boot 与 Vue 的前后端分离管理后台框架。本仓库当前为 RuoYi 3.9.2，后端目标为 Java 17 与 Spring Boot 4.x，前端为 Vue 2 + Element UI。
_Avoid_：单体页面直出、无 API 边界的一体应用

**后端服务边界**：
由 `ruoyi-admin` 启动的 HTTP API 与安全入口。对外提供登录、业务管理、监控、定时任务和代码生成等接口；身份状态依赖 Redis，业务数据依赖关系型数据库。
_Avoid_：前端本地 mock 即后端

**前端工作台边界**：
`ruoyi-ui` 中的 Vue 管理端。负责登录页、主框架布局、动态路由装配、按钮权限控制和业务页面渲染，通过 HTTP 调用后端 API。
_Avoid_：后端模板渲染页面

**工作区与上传目录**：
由配置项 `ruoyi.profile` 指定的服务器本地文件根路径，用于上传、下载与头像等静态资源映射。
_Avoid_：前端 `public` 目录、浏览器本地存储

## 后端模块

**ruoyi-admin**：
可执行入口模块。包含 `RuoYiApplication`、Web Controller、启动配置与运行配置文件。
_Avoid_：通用工具库

**ruoyi-framework**：
框架与安全装配层。包含 Spring Security 配置、JWT 过滤器、登录与令牌服务、数据权限切面、异常处理与资源映射等横切能力。
_Avoid_：具体业务实体持久化

**ruoyi-system**：
系统管理业务模块。包含用户、角色、菜单、部门、字典等系统域的 Service 与 Mapper。
_Avoid_：HTTP 入口层

**ruoyi-common**：
公共基础模块。包含领域模型、常量、注解、工具类、通用异常与 Redis 缓存封装等，被其他后端模块依赖。
_Avoid_：可独立启动的应用

**ruoyi-quartz**：
定时任务模块。负责任务定义、调度与反射调用执行。
_Avoid_：通用业务 CRUD

**ruoyi-generator**：
代码生成模块。根据数据表元数据生成前后端代码、预览与下载产物。
_Avoid_：运行时业务服务

模块依赖方向（直接 POM 声明）：
`ruoyi-admin` → `ruoyi-framework`、`ruoyi-quartz`、`ruoyi-generator`；
`ruoyi-framework` → `ruoyi-system`；
`ruoyi-system` / `ruoyi-quartz` / `ruoyi-generator` → `ruoyi-common`。

## 前端边界

**ruoyi-ui**：
Vue 2 管理端工程。使用 Vue Router 3、Vuex、Element UI 与 Vue CLI。
_Avoid_：Vue 3 / Vite / Pinia 主线（那些是其他仓库或分支）

**constantRoutes**：
前端本地写死的常量路由，覆盖登录、首页、404 等不依赖后端菜单的基础页面。
_Avoid_：后端返回的业务菜单路由

**dynamicRoutes**：
前端本地声明、需按权限过滤后挂载的受限路由集合，与后端菜单生成的异步路由共同构成可访问路由。
_Avoid_：全部业务菜单本身

**GenerateRoutes / filterAsyncRouter**：
前端权限仓库动作与转换函数。拉取后端菜单后，将组件路径解析为视图组件，并与本地动态路由合并后注入路由器。
_Avoid_：后端直接下发可执行前端代码

## 身份与权限术语

**LoginUser**：
实现 Spring Security `UserDetails` 的登录用户主体。承载用户 ID、部门 ID、令牌标识、权限集合与 `SysUser` 实体，是请求级安全上下文中的核心身份对象。
_Avoid_：数据库用户表行本身

**SysUser / SysRole / SysMenu**：
系统用户、角色与菜单领域实体。角色包含数据权限字段；菜单用于后端构建路由与权限标识。
_Avoid_：前端 Vuex 临时状态

**权限标识（permissions）**：
字符串形式的操作权限，如接口方法级 `@PreAuthorize` 与前端按钮权限使用的 `system:user:list` 一类标识。
_Avoid_：URL 路径本身

**角色（roles）**：
用户所属角色集合。用于角色判断、菜单加载与数据范围计算。
_Avoid_：单个权限字符串

**数据权限（dataScope）**：
角色级数据可见范围控制。由数据权限切面在查询前注入 SQL 过滤条件，限制用户可访问的部门或本人数据。
_Avoid_：菜单显示权限、按钮权限

**方法级权限**：
通过 `@PreAuthorize` 与 `PermissionService` 在 Controller 方法上校验权限标识或角色。
_Avoid_：仅前端隐藏按钮

**匿名访问 / permitAll**：
Spring Security 中允许未认证访问的 URL 规则，以及可通过注解标记的匿名接口。
_Avoid_：已登录用户的全部接口

## 数据与运行时术语

**JWT 访问令牌**：
登录成功后返回给客户端的 Bearer 令牌。令牌中携带登录用户缓存键信息；完整会话状态存放在 Redis。
_Avoid_：仅数据库会话表

**Redis 登录态（login_tokens:）**：
以 `login_tokens:` 为前缀的缓存键空间，保存 `LoginUser` 会话对象，支撑令牌校验、续期与注销。
_Avoid_：仅 JWT 自包含权限即全部真相

**验证码缓存（captcha_codes:）**：
以 `captcha_codes:` 为前缀的验证码缓存键空间，用于登录前校验。
_Avoid_：前端本地验证码

**TokenService**：
令牌创建、解析、刷新、删除登录用户缓存的服务。
_Avoid_：业务用户 CRUD 服务

**SysLoginService**：
登录编排服务。负责验证码、认证、登录日志与创建令牌。
_Avoid_：HTTP 控制器本身

**PermissionService / SysPermissionService**：
前者供方法级权限表达式调用；后者汇总用户角色与菜单权限集合。
_Avoid_：前端 `v-hasPermi` 指令实现

**DataScopeAspect**：
数据权限 AOP 切面。识别 `@DataScope` 并在查询参数中注入范围过滤。
_Avoid_：行级数据库强制策略

**RouterVo / MetaVo**：
后端返回给前端的路由与菜单元数据视图对象，用于动态路由与侧边栏渲染。
_Avoid_：Vue Router 内部匹配记录

**Druid 数据源配置**：
通过 Spring Profile `druid` 激活的数据源与监控相关配置。
_Avoid_：业务 Service

## 审计术语

**P0**：
可导致系统级紧急损害，需立即处置的风险。

**P1**：
高影响且应优先修复的风险。

**P2**：
中等风险或纵深防御缺口。

**P3**：
低风险与维护性改进。

**已确认问题**：
代码行为或可复现检查足以证明问题存在。

**条件性风险**：
仅在特定部署或配置条件下成立，并明确列出这些条件。

**设计观察**：
当前不构成可利用漏洞，但会增加维护或防御成本。

**未能动态验证**：
受本地服务、数据或工具条件限制，不能做出确定结论。
