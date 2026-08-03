# 系统模块地图（扫菜单用）

> **读者：** 零基础实习生、带教人带读菜单时对照  
> **目标：** 知道侧边栏每一项是干什么的、代码大概在哪、和第几周任务有关  
> **不必第 1 天背完**；W1 登录后点一遍，W2～W7 按周回到已有模块，W8～W12 再进入工单毕业项目

相关：概念 [07-zero-basics.md](./07-zero-basics.md) · 任务 [tasks/](./tasks/) · 官方功能摘要见根目录 `README.md`「内置功能」

---

## 0. 先建立一张总图

登录成功后，左侧大致是三大目录（另有「若依官网」外链，可忽略）：

```text
系统管理  →  用户/角色/菜单/部门/岗位/字典/参数/公告/日志……（业务配置，实习主战场）
系统监控  →  在线用户/定时任务/Druid/服务/缓存……（运行态，先会点会看）
系统工具  →  表单构建/代码生成/Swagger……（开发辅助；生成器共享库慎用）
```

**和代码的对应关系（大白话）：**

| 你在浏览器 | 后端常在 | 前端常在 |
| --- | --- | --- |
| 系统管理 → 某菜单 | `ruoyi-admin/.../controller/system/` + `ruoyi-system` | `ruoyi-ui/src/views/system/` |
| 系统监控 → 某菜单 | `controller/monitor/` 等 | `ruoyi-ui/src/views/monitor/` |
| 系统工具 | `controller/tool/`、`ruoyi-generator`、swagger | `ruoyi-ui/src/views/tool/` |
| 工单中心（W8 计划新增） | `ruoyi-admin/.../controller/ticket/` + `ruoyi-ticket` | `ruoyi-ui/src/views/ticket/` |
| 登录 / Token / 权限框架 | `ruoyi-framework`（无单独菜单） | `login.vue`、`permission.js`、`utils/auth.js` |

菜单本身存在数据库表 **`sys_menu`**（初始化见 `sql/ry_*.sql`）。改菜单权限 ≠ 只改前端路由文件。

---

## 1. 系统管理（逐项）

### 1.1 用户管理 `system/user`

| 项 | 说明 |
| --- | --- |
| **干什么** | 系统里的「人」：账号、部门、岗位、角色、重置密码、启停、导入导出 |
| **你能点到的** | 列表/搜索、新增、修改、删除、导入、导出、重置密码、分配角色 |
| **权限字示例** | `system:user:list` / `add` / `edit` / `remove` / `export` / `import` / `resetPwd` / `query` |
| **关键代码** | `SysUserController`；`views/system/user/index.vue`；`api/system/user.js` |
| **实习** | **W1 第 4 天**跟读列表全链路；**W5** 增强已有导入结果并做原子批量部门/角色；**W6** 接入性别筛选 |

### 1.2 角色管理 `system/role`

| 项 | 说明 |
| --- | --- |
| **干什么** | 把「能看哪些菜单、能点哪些按钮、能看哪些数据范围」打成包，再赋给用户 |
| **你能点到的** | 角色 CRUD、菜单树勾选、数据权限（全部/自定义/本部门/仅本人等）、角色与用户 |
| **权限字示例** | `system:role:list` / `add` / `edit` / `remove` / `export` … |
| **关键代码** | `SysRoleController`；`views/system/role/` |
| **实习** | W1 口头题「三层权限」；W2/W3 测 403 时要**改角色勾选**；DataScope 观摩可放 W4 加餐 |

### 1.3 菜单管理 `system/menu`

| 项 | 说明 |
| --- | --- |
| **干什么** | 配置侧边栏目录/页面菜单/按钮；填写**权限字符**、路由、组件路径 |
| **菜单类型** | `M` 目录 · `C` 菜单 · `F` 按钮（按钮常不显示在侧栏，只控权限） |
| **权限字示例** | `system:menu:list` / `add` / `edit` / `remove` … |
| **关键代码** | `SysMenuController`；`views/system/menu/`；数据在 `sys_menu` |
| **实习** | W3 新增「公告导出」按钮 = 往菜单里加一条 `F` + `system:notice:export` |

### 1.4 部门管理 `system/dept`

| 项 | 说明 |
| --- | --- |
| **干什么** | 公司/部门树；用户挂在部门上；和**数据权限**强相关 |
| **权限字示例** | `system:dept:list` / `query` / `add` / `edit` / `remove` |
| **关键代码** | `SysDeptController`；`views/system/dept/` |
| **实习** | 第 1 周会点即可；数据权限深入放到加餐（任务池 T20） |

### 1.5 岗位管理 `system/post`

| 项 | 说明 |
| --- | --- |
| **干什么** | 职务（如董事长、项目经理）；用户可关联岗位 |
| **特别点** | 列表**导出 Excel** 是标准样板（`@Excel` + `ExcelUtil` + `system:post:export`） |
| **权限字示例** | `system:post:list` / `add` / `edit` / `remove` / `export` |
| **关键代码** | `SysPostController.export`；`views/system/post/index.vue` 的 `handleExport` |
| **实习** | **W3**：做公告导出时**对照抄结构**，不要凭空想 |

### 1.6 字典管理 `system/dict`

| 项 | 说明 |
| --- | --- |
| **干什么** | 维护下拉选项等「较固定」的数据（类型 + 数据项） |
| **例子** | 公告类型 `sys_notice_type`、公告状态 `sys_notice_status` |
| **权限字示例** | `system:dict:list` / `add` / `edit` / `remove` / `export` … |
| **关键代码** | `SysDictTypeController` / `SysDictDataController`；`views/system/dict/` |
| **实习** | W1 可选热身 T01；**W6** 复现并修复类型重命名旧 key，再把已有字典接入业务查询 |

### 1.7 参数设置 `system/config`

| 项 | 说明 |
| --- | --- |
| **干什么** | 系统运行参数（键值），如账号相关策略、是否强制改密等 |
| **权限字示例** | `system:config:list` / `add` / `edit` / `remove` / `export` … |
| **关键代码** | `SysConfigController`；`views/system/config/` |
| **实习** | 知道「有些开关不在 yml 而在库表」即可；乱改生产参数危险 |

### 1.8 通知公告 `system/notice` ⭐ 实习主线模块

| 项 | 说明 |
| --- | --- |
| **干什么** | 发布通知/公告：标题、类型、状态、内容（可富文本） |
| **开箱已有** | CRUD；按标题/操作人/类型查询；权限 list/query/add/edit/remove；本仓另有**已读**、listTop、markRead 等 |
| **权限字（基线）** | `system:notice:list` / `query` / `add` / `edit` / `remove` |
| **关键代码** | `SysNoticeController`；`SysNotice` / Mapper；`views/system/notice/`；`api/system/notice.js` |
| **表** | `sys_notice`（另有已读相关表/对象时**不要和置顶搞混**） |

**实习在本模块上的增量（循序渐进）：**

| 周 | 你要交付的功能 | 任务书 |
| --- | --- | --- |
| W2 | **置顶** `is_top`；列表置顶优先；表单可改；无 edit → 403 | [W2-notice-enhancement.md](./tasks/W2-notice-enhancement.md) |
| W3 | **按置顶筛选**；**导出 Excel**；权限 `system:notice:export`；操作日志说明；模块 README | [W3-notice-deepen.md](./tasks/W3-notice-deepen.md) |
| W4 | Demo 串讲本模块 + 权限对比 | [W4-demo-and-wrapup.md](./tasks/W4-demo-and-wrapup.md) |

> **注意：** 实体里可能已有 `isRead`（是否已读）≠ 置顶。置顶用 W2 的 `isTop` / `is_top`。

### 1.9 日志管理（目录）

下挂两个页面（见监控侧实现，菜单挂在系统管理下）：

#### 操作日志 `monitor/operlog`

| 项 | 说明 |
| --- | --- |
| **干什么** | 记录带 `@Log` 的后台操作（模块名、操作类型、操作人、时间、状态等） |
| **权限字示例** | `monitor:operlog:list` / `query` / `remove` / `export` |
| **代码线索** | 注解 `@Log` 在 Controller 方法上；切面 `LogAspect` |
| **实习** | **W3**：改一条公告 / 导出一次 → 来这里找记录并写说明 |

#### 登录日志 `monitor/logininfor`

| 项 | 说明 |
| --- | --- |
| **干什么** | 登录成功/失败记录；可配合解锁等 |
| **权限字示例** | `monitor:logininfor:list` / `query` / `remove` / `export` / `unlock` |
| **实习** | W1 了解「登录失败会记日志」即可 |

---

## 2. 系统监控（逐项）

| 菜单 | 干什么 | 权限字前缀 | 实习建议 |
| --- | --- | --- | --- |
| **在线用户** | 看当前会话；强退会话（动 Redis 登录缓存） | `monitor:online:*` | **W7**：批量强退、`deptId` 筛选、会话口径统计 |
| **定时任务** | Quartz 任务 CRUD、启停、执行日志、导出 | `monitor:job:*` | **W7**：异常 Top5、平均耗时、每日趋势；勿乱对生产调度 |
| **数据监控** | Druid 控制台：连接池、SQL | `monitor:druid:*` | **只读观摩**；生产暴露面见审计 SEC-003 |
| **服务监控** | CPU/内存/磁盘/JVM | `monitor:server:*` | 会打开看一眼即可 |
| **缓存监控** | Redis 信息、命令统计 | `monitor:cache:*` | 结合登录会话理解 Redis |
| **缓存列表** | 按 key 查看/清理 | `monitor:cache:*` | 勿在共享环境乱删 `login_tokens:*` |

前端目录：`ruoyi-ui/src/views/monitor/`。

---

## 3. 系统工具（逐项）

| 菜单 | 干什么 | 权限字前缀 | 实习建议 |
| --- | --- | --- | --- |
| **表单构建** | 拖拽生成表单 HTML | `tool:build:*` | 了解即可 |
| **代码生成** | 选表生成前后端 CRUD 代码包 | `tool:gen:*` | **仅本地库实验**；共享/生产库禁止乱 gen（SEC-007） |
| **系统接口** | Swagger UI，调试 API | `tool:swagger:*` | **W1 第 5 天**必做；Authorize 带 Token |

前端目录：`ruoyi-ui/src/views/tool/`。  
Swagger 指南：`docs/guides/api-docs-swagger.md`。

---

## 4. 计划新增：工单中心（W8～W10）

> 当前基线没有 `ruoyi-ticket`。它从 W8 开始创建，W9/W10 在同一业务模块上继续增量，不要提前在 W5～W7 新建空壳。

### 4.1 模块边界

| 层 | 计划位置 | 职责 |
| --- | --- | --- |
| HTTP 入口 | `ruoyi-admin/src/main/java/com/ruoyi/web/controller/ticket/` | Controller、请求校验、`@PreAuthorize`、`@Log`；**Controller 仍属于 `ruoyi-admin`** |
| 工单业务 | `ruoyi-ticket/src/main/java/com/ruoyi/ticket/` | Domain、Mapper 接口、Service、状态规则、附件/通知业务 |
| Mapper XML | `ruoyi-ticket/src/main/resources/mapper/ticket/` | 工单、流转、评论、附件、通知查询与写入 |
| 前端 API | `ruoyi-ui/src/api/ticket/` | 工单、流转、附件、通知请求封装 |
| 前端页面 | `ruoyi-ui/src/views/ticket/` | 工单列表、详情、动作区、时间线、附件和通知 |
| 数据脚本 | `sql/migrations/` | W8～W10 的 `V001～V003` 正向脚本与 `U001～U003` 回滚脚本 |
| 菜单与权限 | `sys_menu` + Controller 权限注解 + 前端 `v-hasPermi` | 权限字符统一使用 `ticket:*` 前缀 |

默认依赖方向：

```text
ruoyi-admin  →  ruoyi-ticket  →  ruoyi-common
      │
      └─ Controller / HTTP 入口

ruoyi-ui     →  /ticket/** API
```

接入新模块时要同时检查根 `pom.xml` 的 `modules` / `dependencyManagement`，以及 `ruoyi-admin/pom.xml` 对 `ruoyi-ticket` 的依赖。不要把 Controller 下沉到 `ruoyi-ticket`，也不要让 `ruoyi-ticket` 反向依赖 `ruoyi-admin`。

### 4.2 三周增量

| 周 | 增量 | 主要表/资源 | 任务书 |
| --- | --- | --- | --- |
| W8 | 工单 CRUD、逻辑删除、DataScope、菜单与字典 | `biz_ticket`、`V001/U001` | [W8-ticket-center-mvp.md](./tasks/W8-ticket-center-mvp.md) |
| W9 | 状态动作、分派/领取、评论、时间线、事务、幂等与乐观锁 | `biz_ticket_flow`、`biz_ticket_comment`、`V002/U002` | [W9-ticket-workflow-collaboration.md](./tasks/W9-ticket-workflow-collaboration.md) |
| W10 | 鉴权附件、站内通知、未读状态、提交后副作用与审计事件 | `biz_ticket_attachment`、`biz_ticket_notification`、附件目录、`V003/U003` | [W10-ticket-attachments-notifications-audit.md](./tasks/W10-ticket-attachments-notifications-audit.md) |

---

## 5. W5～W12 代码与模块映射

W5～W7 使用当前仓库已有模块；W8～W12 的路径是任务计划交付，开始当周前可能还不存在。

| 周 | 后端重点 | 前端重点 | 数据 / 工程重点 | 任务书 |
| --- | --- | --- | --- | --- |
| W5 | `ruoyi-admin/.../SysUserController`；`ruoyi-system` 的 User Service/Mapper | `views/system/user/`；`ExcelImportDialog`；`api/system/user.js` | `sys_user`、`sys_user_role`、部门与角色 DataScope、事务 | [W5](./tasks/W5-user-batch-import-role-dept.md) |
| W6 | `ruoyi-system` 的 `SysDictTypeServiceImpl` 与 User Mapper | `views/system/user/index.vue`；现有字典 mixin | `sys_dict_type`、`sys_dict_data`、Redis 旧/新字典 key | [W6](./tasks/W6-dict-management.md) |
| W7 | `SysUserOnlineController`；`SysJobLogController`；Online/JobLog Service 与 Mapper | `views/monitor/online/index.vue`；`views/monitor/job/log.vue`；对应 API | Redis `login_tokens:*`、`exception_info`、`start_time/end_time`、fixture | [W7](./tasks/W7-online-user-and-job-monitor.md) |
| W8 | 根/admin POM；`ruoyi-admin/.../controller/ticket/`；新 `ruoyi-ticket` | `api/ticket/ticket.js`；`views/ticket/ticket/` | `biz_ticket`、字典、菜单、`V001/U001` | [W8](./tasks/W8-ticket-center-mvp.md) |
| W9 | `ruoyi-ticket` 状态规则、事务 Service、Flow/Comment Mapper；ticket Controller | 工单详情、动作对话框、评论与时间线 | `biz_ticket_flow`、`biz_ticket_comment`、`V002/U002` | [W9](./tasks/W9-ticket-workflow-collaboration.md) |
| W10 | `ruoyi-ticket` Attachment/Notification；`FileUploadUtils` / `FileUtils`；鉴权下载 Controller | 工单附件区、通知入口/列表、统一时间线 | 附件存储、`biz_ticket_attachment`、`biz_ticket_notification`、`V003/U003` | [W10](./tasks/W10-ticket-attachments-notifications-audit.md) |
| W11 | 各模块 `src/test`、测试配置、根/子模块 POM、`.github/workflows/ci.yml` | 前端测试、`package-lock.json`、测试/build 脚本 | Testcontainers MySQL/Redis、迁移验证、测试/覆盖率/扫描报告 | [W11](./tasks/W11-testing-and-ci.md) |
| W12 | 后端生产配置、后端镜像、健康/指标端点、发布 runbook | 前端镜像、Nginx 静态资源与 API 代理 | Compose、Secret 注入、数据卷、迁移、备份、升级和回滚 | [W12](./tasks/W12-deployment-production-readiness.md) |

---

## 6. 没有菜单但必须知道的「隐形模块」

| 能力 | 说明 | 关键位置 | 实习 |
| --- | --- | --- | --- |
| **登录 / 登出** | `POST /login`、`/logout`、`getInfo`、`getRouters` | `SysLoginController`；`TokenService`；`SecurityConfig` | **W1 第 3 天** |
| **JWT 过滤器** | 每个请求恢复登录用户 | `JwtAuthenticationTokenFilter` | W1 跟读 |
| **验证码** | 防刷登录；答案在 Redis | captcha 相关 + `captcha_codes:` | W1 登录说明 |
| **方法权限** | `@PreAuthorize("@ss.hasPermi('…')")` | 各 Controller | W1 结论句；W2/W3 403 |
| **前端路由守卫** | 动态路由、Token 校验 | `permission.js`、`utils/auth.js`（Cookie `Admin-Token`） | W1 |
| **全局异常 / 统一返回** | `AjaxResult`、`TableDataInfo` 等 | `ruoyi-common` / framework | 看接口响应时会遇到 |

---

## 7. 按实习周「该点哪些菜单 / 工程入口」（检查清单）

### 第 1 周（W1）

- [ ] 登录页 → 进首页  
- [ ] 系统管理 → **用户管理**（跟列表）  
- [ ] 系统管理 → 角色 / 菜单 / 字典（会打开即可）  
- [ ] 系统管理 → **通知公告**（确认菜单在，为 W2 热身）  
- [ ] 系统工具 → **系统接口**（Swagger）  
- [ ] （可选）系统管理 → 日志 → 登录日志  

### 第 2 周（W2）

- [ ] **通知公告** 增删改查 + 置顶全流程  
- [ ] 角色管理：准备/使用**无公告编辑权**账号测 403  

### 第 3 周（W3）

- [ ] **通知公告**：置顶筛选、导出  
- [ ] **岗位管理**：只读对照导出按钮与权限  
- [ ] **菜单管理** 或 SQL：确认导出按钮权限字符  
- [ ] **操作日志**：找到自己的修改/导出记录  

### 第 4 周（W4）

- [ ] 按 Demo 脚本串：登录 → 用户结论 → 公告能力 → 有/无权限  
- [ ] （加分）Druid/Swagger 未登录访问现象（只记笔记）  

### 第 5 周（W5）

- [ ] **用户管理**：确认现有单用户增改、导入入口和角色选择基线
- [ ] 混合合法/非法导入行时能看到逐行原因，并确认整批零写入
- [ ] 验证批量分配部门、角色替换在成功和中途失败时都满足事务契约
- [ ] **角色 / 菜单管理**：核对 `system:user:import`、`system:user:dept`、`system:user:role`；无权账号直调对应接口为 403

### 第 6 周（W6）

- [ ] **字典管理**：先让旧编码进入缓存，再重命名并确认历史 key 被清理
- [ ] **用户管理**：性别筛选和标签来自 `sys_user_sex`，不在 Vue 中复制选项数组
- [ ] 模拟重复编码和事务回滚，确认数据库与 Redis 没有发布半成品
- [ ] 用受限账号确认用户性别筛选不绕过原有 DataScope

### 第 7 周（W7）

- [ ] **在线用户**：用同一用户的两个浏览器验证会话数和去重用户数，再测批量强退与 `deptId` 筛选
- [ ] **定时任务 → 调度日志**：用专用 fixture 对账统计卡片、异常 Top5、平均耗时和每日趋势
- [ ] 默认 7 天、空数据、31 天边界和无效日期范围均符合接口契约
- [ ] 用无权限账号直调批量强退和统计接口，确认后端拒绝

### 第 8 周（W8）

- [ ] **工单中心**菜单、按钮权限、前端路由和 `/ticket/**` API 全部可达
- [ ] 根 POM、`ruoyi-admin` 依赖和 `ruoyi-ticket` 模块方向正确，Controller 位于 `ruoyi-admin`
- [ ] 工单 CRUD、逻辑删除、字典和 DataScope 使用管理员/本部门/仅本人账号验证
- [ ] `V001/U001` 在干净测试库完成正向与回滚，未误删系统表

### 第 9 周（W9）

- [ ] 从 DRAFT 提交到关闭/重开的合法状态路径完整走通
- [ ] 非法动作、非参与者操作和过期 version 均由后端拒绝
- [ ] 重放同一 requestId 不重复写流转；两个并发领取只有一个成功
- [ ] 详情页 `availableActions`、评论和统一时间线刷新后与服务端一致

### 第 10 周（W10）

- [ ] 合法附件可上传和鉴权下载；非法类型、超限、猜 ID 与 `/profile/**` 绕过均失败
- [ ] 文件写入/删除失败时，元数据、可见性和补偿记录按设计收敛
- [ ] 分派、评论、解决、重开等事件生成正确且不重复的站内通知
- [ ] 用户只能读取自己的通知；附件、通知和时间线在前端状态完整

### 第 11 周（W11）

- [ ] 固定 JDK/Maven/Node/npm，提交前端 lockfile，并从空 `node_modules` 使用 `npm ci`
- [ ] 后端单元、真实 MySQL/Redis 集成、401/403 权限和前端关键交互测试均有真实断言
- [ ] CI 自动执行 docs、backend、frontend 和 dependency audit jobs，并保存报告
- [ ] 故意破坏一条规则和一次前端构建，确认门禁先红；恢复后重新跑绿

### 第 12 周（W12）

- [ ] 在只有 Docker/Compose 的干净测试机启动 MySQL、Redis、后端和 Nginx
- [ ] 生产型配置通过运行时注入；Swagger、Druid、CORS、generator 和受保护附件暴露面符合基线
- [ ] liveness/readiness、request ID、日志、指标和 10k 工单性能基线有真实证据
- [ ] 使用明确镜像 SHA 演练升级、应用回滚、数据库回滚和测试备份恢复
- [ ] runbook 由非作者在隔离环境成功复现，不接触真实生产数据

---

## 8. 一张「功能 → 训练点」速查

| 你想练… | 优先模块 | 任务/池 |
| --- | --- | --- |
| 前后端列表链路 | 用户管理 | W1 |
| 垂直切片改字段 | 通知公告 | W2 |
| 查询条件 + 导出 + 新权限字 | 通知公告（对照岗位） | W3 |
| 操作日志 / `@Log` | 操作日志 + 公告 Controller | W3 / T12 |
| 批量导入 / 批量关联 | 用户管理 | W5 |
| cache-aside 与业务字典 | 字典管理 + 用户管理 | T01、W6 |
| Redis 会话 + 聚合统计 | 在线用户、调度日志 | W7 |
| 按钮与菜单 SQL | 菜单管理 | T11、W3 导出按钮 |
| 数据权限 | 角色 + 用户/部门列表、工单中心 | T20（进阶）、W8 |
| API 调试 | 系统接口 | W1、T04 |
| 代码生成 | 代码生成（仅本地） | T24，需导师同意 |
| 独立 Maven 业务模块 | 工单中心 | W8 / T25 |
| 状态机、事务、幂等与并发 | 工单流转 | W9 / T26～T27 |
| 文件安全、通知与补偿 | 工单附件 / 通知 | W10 / T28～T29 |
| 自动化测试与 CI | 工单模块 + 工程配置 | W11 / T30 |
| 容器部署、观测与回滚 | 全系统 | W12 / T31 |

---

## 9. 默认账号与入口（提醒）

| 项 | 常见值 |
| --- | --- |
| 管理员 | `admin` / `admin123`（导入本仓 SQL 后常见默认，仅本机） |
| 前端 | `http://localhost`（以 `npm run dev` 为准） |
| 后端 | `http://localhost:8080` |
| Swagger | 菜单「系统接口」或 `/swagger-ui/index.html` |

密码与密钥**不要**提交 Git。更细的环境步骤见 [08-local-setup-step-by-step.md](./08-local-setup-step-by-step.md)。

---

## 10. 和任务书、答案的链接

| 文档 | 用途 |
| --- | --- |
| [tasks/W1-login-and-user-list.md](./tasks/W1-login-and-user-list.md) | 登录 + 用户列表 |
| [tasks/W2-notice-enhancement.md](./tasks/W2-notice-enhancement.md) | 公告置顶 |
| [tasks/W3-notice-deepen.md](./tasks/W3-notice-deepen.md) | 公告筛选/导出/日志/文档 |
| [tasks/W4-demo-and-wrapup.md](./tasks/W4-demo-and-wrapup.md) | Demo 收口 |
| [tasks/W5-user-batch-import-role-dept.md](./tasks/W5-user-batch-import-role-dept.md) | 用户导入增强、批量部门和角色替换 |
| [tasks/W6-dict-management.md](./tasks/W6-dict-management.md) | 字典缓存一致性与用户性别筛选 |
| [tasks/W7-online-user-and-job-monitor.md](./tasks/W7-online-user-and-job-monitor.md) | 在线会话与可复现调度统计 |
| [tasks/W8-ticket-center-mvp.md](./tasks/W8-ticket-center-mvp.md) | 工单中心 MVP、独立模块与 DataScope |
| [tasks/W9-ticket-workflow-collaboration.md](./tasks/W9-ticket-workflow-collaboration.md) | 工单状态机、协作、事务与并发 |
| [tasks/W10-ticket-attachments-notifications-audit.md](./tasks/W10-ticket-attachments-notifications-audit.md) | 工单附件、站内通知与审计 |
| [tasks/W11-testing-and-ci.md](./tasks/W11-testing-and-ci.md) | 自动化测试、可复现构建与 CI |
| [tasks/W12-deployment-production-readiness.md](./tasks/W12-deployment-production-readiness.md) | 容器部署、可观测性与生产就绪演练 |
| [04-task-pool.md](./04-task-pool.md) | 加餐任务池 |
