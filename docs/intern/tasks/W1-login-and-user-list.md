# 任务书 W1：环境跑通 + 登录链路 + 用户列表跟读

> **给零基础同学：** 本文写得很细。请按「第 0 天 → 第 5 天」顺序做，不要跳着做第 4 天。  
> 概念不懂先读：[07-zero-basics.md](../07-zero-basics.md)  
> 安装卡壳先读：[08-local-setup-step-by-step.md](../08-local-setup-step-by-step.md)

| 项 | 内容 |
| --- | --- |
| 阶段 | 第 1 周 |
| 难度 | ★（零基础可完成，但要认真跟） |
| 建议工期 | 4～6 天（含装环境） |
| 分支 | `feature/<你的名字>-onboarding` |
| 基线分支 | `master` |
| 每天建议 | 有效学习 4～6 小时；卡住超过 1 小时就按模板提问 |

---

## 0. 本周目标（用大白话）

做完本周，你应该能够：

1. 在自己电脑上 **启动后端 + 前端**，用管理员账号登录；  
2. 用 **自己的话** 说明：登录时验证码、密码、Token、Redis 各起什么作用；  
3. 从「点击用户管理」跟到数据库，填完一张 **路径表**；  
4. 用 **Swagger** 带着 Token 成功调用一个需要登录的接口；  
5. 口头回答导师几个基础问题（见阅读清单）。

**本周不要做：** 改 JWT 密钥逻辑、改生产安全配置、新建复杂业务表、大改 UI 样式。

---

## 1. 开始前阅读（约半天，可与装环境穿插）

按顺序打开（读不懂的标记「？」，第二天再读）：

| 顺序 | 文档 | 你要获得什么 |
| --- | --- | --- |
| 1 | [07-zero-basics.md](../07-zero-basics.md) | 前后端、Git、Token 大白话 |
| 2 | [08-local-setup-step-by-step.md](../08-local-setup-step-by-step.md) | 一步步装环境 |
| 3 | [05-environment-checklist.md](../05-environment-checklist.md) | 勾选进度 |
| 4 | 根目录 `README.md` | 项目是谁、有什么功能 |
| 5 | [CONTEXT.md](../../../CONTEXT.md) | 模块名、权限术语（可先扫） |
| 6 | [01-architecture.md](../../audit/01-architecture.md) 的登录/请求章节 | 跟作业时对照 |
| 7 | [api-docs-swagger.md](../../guides/api-docs-swagger.md) | 第 4～5 天用 |

阅读方法见 [02-reading-list.md](../02-reading-list.md)。

---

## 2. 按天执行计划

### 第 1～2 天：环境（必须全部绿灯）

1. 完整跟随 [08-local-setup-step-by-step.md](../08-local-setup-step-by-step.md)。  
2. 用 [05-environment-checklist.md](../05-environment-checklist.md) **逐项打勾**。  
3. 验收动作（自己做）：  
   - 浏览器能打开前端登录页；  
   - `admin` / 初始密码能进系统（常见为 `admin123`，以 SQL/文档为准）；  
   - 能打开 **系统管理 → 用户管理** 并看到表格数据。  

**卡点提示：** 90% 问题是 MySQL 密码、Redis 没开、`ruoyi.profile` 路径在 Linux 下仍是 `D:/...`。

**当天交付：** 把 checklist 勾选结果（截图或复制表格）发给导师，或写在笔记里周五一起交。

---

### 第 3 天：跟读「登录」并写一页说明

#### 3.1 建议打开的文件（在 IDE 里用文件搜索文件名）

| 顺序 | 文件 | 你看什么 |
| --- | --- | --- |
| 1 | `ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysLoginController.java` | 哪个方法处理登录？URL 是什么？ |
| 2 | `ruoyi-framework/src/main/java/com/ruoyi/framework/web/service/SysLoginService.java` | 验证码、认证、调用创建 Token 的顺序 |
| 3 | `ruoyi-framework/src/main/java/com/ruoyi/framework/web/service/TokenService.java` | 如何 createToken？如何从请求取 Token？ |
| 4 | `ruoyi-framework/src/main/java/com/ruoyi/framework/security/filter/JwtAuthenticationTokenFilter.java` | 每个请求如何恢复登录用户？ |
| 5 | `ruoyi-framework/src/main/java/com/ruoyi/framework/config/SecurityConfig.java` | 哪些 URL 允许匿名（permitAll）？ |
| 6 | `ruoyi-ui/src/utils/auth.js` | 前端 Token 存哪？ |
| 7 | `ruoyi-ui/src/permission.js` | 登录后如何拉用户信息、生成路由？ |
| 8 | `ruoyi-ui/src/views/login.vue`（若存在） | 登录按钮点下去调用什么 |

**怎么读（零基础方法）：**

1. 先搜方法名 / 字符串：`login`、`createToken`、`getLoginUser`。  
2. 从上往下看方法调用，在纸上画箭头：A 调用 B，B 调用 C。  
3. 遇到注解 `@PostMapping`、`@Autowired` 先当「标签」：映射 URL、注入依赖，第 1 周不要求背原理。  
4. 对照 [01-architecture.md](../../audit/01-architecture.md) 登录时序图，看自己是否理解每一步。

#### 3.2 作业：登录说明（必须用自己的话）

新建笔记（二选一，按导师要求）：

- 发到飞书/文档：`W1-登录链路-你的名字.md`  
- 或在个人分支：`notes/w1-login.md`（若导师允许笔记进库）

**必须回答的 4 个问题（复制当标题）：**

```markdown
# W1 登录链路说明

## 1. 验证码怎么校验？
（提示：登录前/登录时谁检查？和 Redis 哪个键前缀有关？答错会怎样？）

## 2. 登录成功后，JWT 和 Redis 分别干什么？
（提示：哪个像「钥匙牌」，哪个像「寄存柜里的行李」？）

## 3. 登录之后，前端请求怎么带身份？
（提示：请求头名字？Bearer？前端哪个文件读写 Token？）

## 4. 退出登录时，系统大概清什么？
（提示：只删浏览器里的 Token 够不够？服务端呢？）

## 5. （可选）我仍不懂的点
- ...
```

**禁止：** 从架构文档整段复制粘贴当作业。可以对照，但句子必须是你自己的。

**自检：** 合上文档，能否用 2 分钟讲给同学听？讲不出来就再跟一遍代码。

---

### 第 4 天：跟读「用户列表」并填路径表

#### 4.1 操作一遍（带着问题点）

1. 登录系统。  
2. 左侧 **系统管理 → 用户管理**。  
3. 按 F12 打开开发者工具 → **Network（网络）**。  
4. 刷新列表或点击搜索，找到用户列表相关请求（常见路径含 `/system/user/list`）。  
5. 点开该请求，看：  
   - Request URL  
   - Request Headers 里有没有 `Authorization`  
   - Response 里 `rows` / `code` 大概长什么样  

把 URL 和方法（GET/POST）记下来。

#### 4.2 建议打开的文件

| 层级 | 文件 |
| --- | --- |
| 前端页面 | `ruoyi-ui/src/views/system/user/index.vue`（路径以实际为准，可在 `views/system/user` 下找） |
| 前端 API | `ruoyi-ui/src/api/system/user.js` |
| 后端 Controller | `ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysUserController.java` |
| 后端 Service | 在 `ruoyi-system` 下搜索 `ISysUserService` / `SysUserServiceImpl` |
| Mapper | `SysUserMapper.java` + `ruoyi-system/src/main/resources/mapper/system/SysUserMapper.xml`（路径以实际为准） |

在 `SysUserController` 里找到列表方法，看上面的：

- `@PreAuthorize` 里的**权限字符**（很重要，抄到表里）  
- `@GetMapping` / `@PostMapping` 的路径  

#### 4.3 作业：路径表（复制填写）

```markdown
# W1 用户列表路径清单

## 浏览器 Network 中看到的请求
- 方法：
- URL（可写相对路径）：
- 是否带 Authorization：是 / 否

## 路径表

| 步骤 | 前端文件与函数/位置 | 后端文件与方法 | 权限字符（没有写无） |
| --- | --- | --- | --- |
| 菜单/路由 | | | |
| API 封装 | `ruoyi-ui/src/api/system/user.js` 中的 `___` | — | — |
| Controller | — | `SysUserController.___` | |
| Service | — | | — |
| Mapper/XML | — | | — |

## 我学到的一句结论
（例如：前端 v-hasPermi 只影响按钮显示，真正拦接口的是……）
```

---

### 第 5 天：Swagger 实战 + 可选热身 + 总复习

#### 5.1 Swagger 步骤（极简）

完整说明见 [api-docs-swagger.md](../../guides/api-docs-swagger.md)。最短路径：

1. 确认后端已启动。  
2. 管理端：**系统工具 → 系统接口**（或浏览器直接打开后端 Swagger UI，常见  
   `http://localhost:8080/swagger-ui/index.html`）。  
3. 先调用登录相关接口拿到 `token`（或浏览器已登录时从 Network 里复制 Token）。  
4. 点击 **Authorize**，填入（注意格式，以项目配置为准，常见）：  
   `Bearer 你的token`  
   或按页面说明只填 token。  
5. 找到用户相关接口，**Try it out** → Execute。  
6. 记录：HTTP 状态码、是否 200、无 Token 时是否 401。  

**作业小表：**

```markdown
# W1 Swagger 记录
- 打开方式：菜单 / 直链
- 使用的接口：
- 有 Token 响应码：
- 去掉 Authorize 后再调响应码（若方便测）：
- 截图或复制一小段响应（不要含密码）
```

#### 5.2 可选热身（加分，独立小提交）

任选 **一个**，改动面要小：

| 选项 | 做什么 | 目的 |
| --- | --- | --- |
| A | 改某个管理页上的中文提示文案 | 熟悉前端目录与提 PR |
| B | 系统管理 → 字典，新增一条字典数据，并在某下拉中看到 | 熟悉配置数据 |

提交信息示例：`docs: 或 chore: 热身-修改xx文案`。

#### 5.3 周五验收前自测清单

- [ ] 能现场演示登录并打开用户管理  
- [ ] 登录说明 4 问已写完  
- [ ] 用户列表路径表已填完  
- [ ] Swagger 记录已写完  
- [ ] 能口头答 [02-reading-list.md](../02-reading-list.md) 里至少 6 题  
- [ ] `git status` 干净或只有业务/笔记；**无密码文件**  

---

## 3. 正式验收标准（导师打勾）

- [ ] 环境 checklist A～F 基本完成，现场可登录  
- [ ] 登录链路说明（自己的话，含 4 个必答题）  
- [ ] 用户列表路径表完整  
- [ ] Swagger 带 Token 调通至少一个需登录接口  
- [ ] 口头题至少 6 题合格  
- [ ] 无密钥/口令进入 Git  

---

## 4. 交付物清单（打包发给导师）

1. 环境 checklist 勾选结果  
2. 登录说明 Markdown  
3. 用户列表路径表 Markdown  
4. Swagger 记录  
5. （可选）热身 PR 链接  

---

## 5. 红线与求助

**红线：**

- 不把密码、secret 提交到 Git  
- 不把本机服务乱暴露到公网  
- 不改 Security 全局策略「图省事」  

**求助模板：**

```text
任务：W1 第 X 天 / 第 X 节
现象：
已尝试：
环境：WSL/Windows/macOS，JDK 版本，Redis/MySQL 是否已启动
报错全文：
```

---

## 6. 完成后

导师确认 W1 通过后，再领取：

→ [W2-notice-enhancement.md](./W2-notice-enhancement.md)

**不要自己提前大改公告模块**，除非导师提前下达 W2。
