# 任务书 W1：环境跑通 + 登录链路 + 用户列表跟读

> **给零基础同学：** 本文写得很细。请按「第 1 天 → 第 5 天」顺序做，**不要跳着做第 4 天**。  
> 概念不懂先读：[07-zero-basics.md](../07-zero-basics.md)  
> 安装卡壳先读：[08-local-setup-step-by-step.md](../08-local-setup-step-by-step.md)  
> 勾选进度：[05-environment-checklist.md](../05-environment-checklist.md)

| 项 | 内容 |
| --- | --- |
| 阶段 | 第 1 周（入门周） |
| 难度 | ★（零基础可完成，但要认真跟，不要只「页面点通」） |
| 建议工期 | **5 个工作日**（含装环境；每天有效学习约 4～6 小时） |
| 分支 | `feature/<你的名字>-onboarding`（例：`feature/zhangsan-onboarding`） |
| 基线分支 | `master` |
| 本周性质 | **跟读 + 说明作业为主**；代码改动可选且要小 |

---

## 0. 用大白话：本周结束你要变成什么样？

做完本周，你应该能够：

1. 在自己电脑上 **启动后端 + 前端**，用管理员账号登录；  
2. 用 **自己的话** 说明：登录时验证码、密码、Token、Redis 各起什么作用；  
3. 从「点击用户管理」跟到数据库，填完一张 **路径表**；  
4. 用 **Swagger** 带着 Token 成功调用一个需要登录的接口；  
5. 口头回答导师几个基础问题（见 [02-reading-list.md](../02-reading-list.md)）。

### 本周明确不要做

| 不要做 | 为什么 |
| --- | --- |
| 改 JWT 密钥 / Token 过期策略「图省事」 | 容易弄挂全站登录，且涉及安全红线 |
| 大改 `SecurityConfig` 的 permitAll | 第 1 周理解即可，改要结对 |
| 新建复杂业务表 / 用代码生成器乱建表 | 第 2 周再动手写功能 |
| 大改 UI 样式、换主题 | 与本周目标无关 |
| 把密码、secret 提交到 Git | **红线** |

### 本机默认值（先背下来）

| 项 | 值 |
| --- | --- |
| 后端 | `http://localhost:8080` |
| 前端 | `http://localhost`（以终端提示为准） |
| 管理员 | 用户名 **`admin`**，密码 **`admin123`**（导入本仓 SQL 后的常见默认） |
| 数据库名建议 | `ry-vue` |
| 个人分支 | `feature/<你的名字>-onboarding` |

若 `admin` / `admin123` 登不上：先确认 SQL 已导入、Redis/后端已启动；仍不行把完整报错发给导师（可能是库未导入或密码被改过）。

---

## 1. 开始前阅读（约半天，可与装环境穿插）

按顺序打开。读不懂的标「？」，第二天再读；**不要**第一天把 audit 全读完。

| 顺序 | 文档 | 你要获得什么 | 建议时长 |
| --- | --- | --- | --- |
| 1 | [07-zero-basics.md](../07-zero-basics.md) | 前后端、Git、Token、三层权限大白话 | 1～2 h |
| 2 | [08-local-setup-step-by-step.md](../08-local-setup-step-by-step.md) | 一步步装环境 | 边做边看 |
| 3 | [05-environment-checklist.md](../05-environment-checklist.md) | 勾选进度 | 贯穿全程 |
| 4 | 根目录 `README.md` | 项目是谁、有什么功能 | 30 min |
| 5 | [09-module-map.md](../09-module-map.md) | 登录后扫菜单：各模块干什么、和哪周有关 | 边点边看 0.5～1 h |
| 6 | [CONTEXT.md](../../../CONTEXT.md) | 模块名、权限术语（可先扫标题） | 1～2 h 扫读 |
| 7 | [01-architecture.md](../../audit/01-architecture.md) 的登录/请求章节 | 跟作业时对照 | 写作业时打开 |
| 8 | [api-docs-swagger.md](../../guides/api-docs-swagger.md) | 第 5 天用 | 第 5 天 |

阅读方法与口头题见 [02-reading-list.md](../02-reading-list.md)。

**怎么读代码（零基础方法，后面几天反复用）：**

1. 在 IDE 里用文件名搜索（不要整库瞎翻）。  
2. 先搜字符串 / 方法名：如 `login`、`createToken`、`/system/user/list`。  
3. 从上往下看「谁调用谁」，在纸上或笔记里画箭头：A → B → C。  
4. 遇到注解先当标签：  
   - `@PostMapping("/login")` ≈ 这个方法对应某个 URL  
   - `@Autowired` ≈ 这里注入了别的类  
   - `@PreAuthorize("...")` ≈ **后端权限门禁**（很重要）  
5. 第 1 周不要求背 Spring 原理，但要能指着文件说「登录从这里进」。

---

## 2. 按天执行计划

### 第 1～2 天：环境（必须全部绿灯）

#### 你要做什么

1. **完整跟随** [08-local-setup-step-by-step.md](../08-local-setup-step-by-step.md) 从第 0 步做到前端启动。  
2. 用 [05-environment-checklist.md](../05-environment-checklist.md) **逐项打勾**（A → G）。  
3. 自己验收（必须亲手点一遍）：

| # | 动作 | 期望结果 |
| --- | --- | --- |
| 1 | 浏览器打开前端地址 | 出现登录页（有用户名、密码、验证码） |
| 2 | 输入 `admin` / `admin123` + 验证码 | 进入主界面，左侧有菜单 |
| 3 | 点 **系统管理 → 用户管理** | 表格里有用户数据（至少有 admin） |
| 4 | 点 **系统管理 → 通知公告** | 能打开列表（第 2 周会用，先确认菜单在） |

#### 最高频卡点（先自查这三条）

| 现象 | 优先检查 |
| --- | --- |
| 后端起不来 / 连库失败 | MySQL 是否启动；`application-druid.yml` 密码是否本机密码；库名是否 `ry-vue` 且已导入 SQL |
| 登录一直失败 / 验证码错 | Redis 是否 `PONG`；浏览器是否缓存旧页；验证码是否过期（刷新再试） |
| 上传或启动报路径错 | `ruoyi.profile` 是否还是 `D:/...`（Linux/WSL 必改） |

#### 当天交付

- 把 checklist **A～F 的勾选结果**（截图或复制表格）发给导师，或写在笔记里周五一起交。  
- 若环境未绿：用文末「求助模板」提问，**不要闷头超过半天**。

#### 第 1～2 天结束自检

- [ ] `java -version` 是 17+  
- [ ] `redis-cli ping` → `PONG`  
- [ ] 能登录后台  
- [ ] 用户管理有数据  
- [ ] `git branch` 在个人 feature 分支上  
- [ ] 没有把数据库密码 commit 进 Git  

---

### 第 3 天：跟读「登录」并写一页说明

> 目标：不是背类名，而是能用 2 分钟给同学讲「点登录之后发生了什么」。

#### 3.1 先操作再读代码

1. 打开前端登录页。  
2. 按 **F12** → **Network（网络）**。  
3. 输入账号密码验证码，点登录。  
4. 在 Network 里找到登录相关请求（常见路径含 `/login`）。  
5. 点开看：  
   - Request URL、Method（多为 POST）  
   - Response 里是否有 `token` 字段（不要把完整 token 发到公开群）  
6. 登录成功后随便点一个菜单，再找一条业务请求，看 Request Headers 里是否有 **`Authorization`**。

把你看到的「登录 URL」和「是否有 Authorization」记在笔记里。

#### 3.2 建议打开的文件（在 IDE 里按文件名搜索）

| 顺序 | 文件 | 你要回答的问题 |
| --- | --- | --- |
| 1 | `ruoyi-admin/.../controller/system/SysLoginController.java` | 哪个方法处理登录？URL 是什么？ |
| 2 | `ruoyi-framework/.../web/service/SysLoginService.java` | 验证码、认证、创建 Token 的大概顺序？ |
| 3 | `ruoyi-framework/.../web/service/TokenService.java` | `createToken` 做什么？如何从请求取 Token？ |
| 4 | `ruoyi-framework/.../security/filter/JwtAuthenticationTokenFilter.java` | 每个请求如何恢复「当前登录用户」？ |
| 5 | `ruoyi-framework/.../config/SecurityConfig.java` | 哪些 URL 允许匿名（`permitAll`）？登录接口是否在其中？ |
| 6 | `ruoyi-ui/src/utils/auth.js` | 前端 Token 存哪？用什么函数读写？ |
| 7 | `ruoyi-ui/src/permission.js` | 登录后如何拉用户信息、生成路由？ |
| 8 | `ruoyi-ui/src/views/login.vue` | 登录按钮点下去调用什么？ |

路径前缀 `...` 表示中间包名以仓库为准；用 IDE 全局搜索文件名最快。

#### 3.3 作业：登录说明（必须用自己的话）

新建笔记（二选一，按导师要求）：

- 发到飞书/文档：`W1-登录链路-你的名字.md`  
- 或在个人分支：`notes/w1-login.md`（**仅当导师允许笔记进库**）

**请原样复制下面标题，再填写正文：**

```markdown
# W1 登录链路说明

姓名：
日期：

## 1. 验证码怎么校验？
（提示：登录前/登录时谁检查？和 Redis 哪个键或缓存有关？答错会怎样？）

## 2. 登录成功后，JWT 和 Redis 分别干什么？
（提示：哪个像「钥匙牌」，哪个像「寄存柜里的行李」？）

## 3. 登录之后，前端请求怎么带身份？
（提示：请求头名字是不是 Authorization？要不要 Bearer？前端哪个文件读写 Token？）

## 4. 退出登录时，系统大概清什么？
（提示：只删浏览器里的 Token 够不够？服务端 Redis 里呢？）

## 5. （可选）我仍不懂的点
- ...

## 6. （可选）我在 Network 里看到的
- 登录请求 URL：
- 登录成功后业务请求是否带 Authorization：是 / 否
```

**禁止：** 从架构文档整段复制粘贴当作业。可以对照，但句子必须是你自己的。

**自检：** 合上文档，能否用 2 分钟讲给同学听？讲不出来就再跟一遍代码。

#### 第 3 天结束自检

- [ ] 4 个必答题已写完  
- [ ] 至少打开过上表 1～5 号文件并做了笔记  
- [ ] 能指出「登录入口 Controller」在哪个文件  

---

### 第 4 天：跟读「用户列表」并填路径表

> 目标：建立「菜单 → 前端 API → Controller → Service → Mapper/SQL」的完整印象。

#### 4.1 操作一遍（带着问题点）

1. 登录系统。  
2. 左侧 **系统管理 → 用户管理**。  
3. F12 → **Network**。  
4. 刷新列表或点搜索，找到用户列表请求（常见路径含 **`/system/user/list`**）。  
5. 点开该请求，记录：

| 观察项 | 你的记录 |
| --- | --- |
| Method | GET / POST / … |
| URL（可写相对路径） |  |
| 是否带 `Authorization` | 是 / 否 |
| Response 里大概有什么 | 如 `code`、`rows`、`total`（不要复制隐私数据） |

#### 4.2 建议打开的文件

| 层级 | 文件 | 你要找什么 |
| --- | --- | --- |
| 前端页面 | `ruoyi-ui/src/views/system/user/index.vue` | 列表加载时调哪个 API 函数 |
| 前端 API | `ruoyi-ui/src/api/system/user.js` | 列表函数名、请求 URL |
| 后端 Controller | `ruoyi-admin/.../controller/system/SysUserController.java` | 列表方法、`@PreAuthorize` 权限字符、`@GetMapping` 路径 |
| 后端 Service | `ruoyi-system` 下 `ISysUserService` / `SysUserServiceImpl` | Controller 调用了哪个方法 |
| Mapper | `SysUserMapper.java` + `.../mapper/system/SysUserMapper.xml` | SQL 大概查哪些表 |

在 `SysUserController` 列表方法上，**务必把权限字符抄到路径表**（形如 `system:user:list`）。

#### 4.3 作业：路径表（复制填写）

```markdown
# W1 用户列表路径清单

姓名：
日期：

## 浏览器 Network 中看到的请求
- 方法：
- URL（可写相对路径）：
- 是否带 Authorization：是 / 否
- 响应里是否有 rows/total 一类字段：是 / 否 / 不确定

## 路径表

| 步骤 | 前端文件与函数/位置 | 后端文件与方法 | 权限字符（没有写无） |
| --- | --- | --- | --- |
| 菜单/路由 | （菜单名：用户管理；组件路径可写 system/user/index） | — | （菜单权限字符若知道可填） |
| API 封装 | `ruoyi-ui/src/api/system/user.js` 中的 `________` | — | — |
| Controller | — | `SysUserController.________` | `________` |
| Service | — | `________` | — |
| Mapper/XML | — | `________` | — |

## 我学到的一句结论
（必填。例如：前端 v-hasPermi 只影响按钮显示，真正拦接口的是后端 @PreAuthorize …）

## 我仍不懂的点
- 
```

#### 第 4 天结束自检

- [ ] 路径表每一行至少填了关键列  
- [ ] 权限字符已从代码里抄到表中（不是猜的）  
- [ ] 能口头说：「前端隐藏按钮 ≠ 后端不校验」  

---

### 第 5 天：Swagger 实战 + 可选热身 + 总复习

#### 5.1 Swagger 最短路径

完整说明见 [api-docs-swagger.md](../../guides/api-docs-swagger.md)。零基础最短路径：

1. 确认 **后端已启动**。  
2. 打开方式二选一：  
   - 管理端菜单：**系统工具 → 系统接口**  
   - 或浏览器直链（常见）：`http://localhost:8080/swagger-ui/index.html`  
3. 获取 Token：  
   - 方式 A：在已登录浏览器 Network 里复制某个请求的 `Authorization` 值；  
   - 方式 B：在 Swagger 里先调登录相关接口拿到 `token`。  
4. 点击页面上的 **Authorize**，填入（以项目为准，常见格式）：  
   `Bearer 你的token`  
   有的环境只需填 token 本身——以页面说明 / 指南为准。  
5. 找到用户相关接口（如用户列表）→ **Try it out** → **Execute**。  
6. 记录：HTTP 状态码是否 200；若方便，去掉 Authorize 再调一次，看是否 401。

**作业小表：**

```markdown
# W1 Swagger 记录

姓名：
日期：

- 打开方式：菜单 / 直链（URL：）
- 使用的接口（路径 + 方法）：
- 有 Token 时响应码：
- 去掉 Authorize 后再调的响应码（若测了）：
- 截图或复制一小段响应（不要含密码；token 可打码）
- 我学会的一点：
```

#### 5.2 可选热身（加分，独立小提交）

**仅当** 第 3～4 天作业已完成且环境稳定时再做。任选 **一个**，改动面要小：

| 选项 | 做什么 | 目的 |
| --- | --- | --- |
| A | 改某个管理页上的中文提示文案（一个按钮旁提示即可） | 熟悉前端目录与提 PR |
| B | 系统管理 → 字典，新增一条字典数据，并在某下拉中看到 | 熟悉配置数据（可不改代码） |

若改代码：

```bash
git status
git add <只加相关文件>
git commit -m "chore: 热身-修改xx文案"
# 按导师要求 push / 提 PR；描述里写自测步骤
```

#### 5.3 周五验收前自测清单

- [ ] 能现场演示：登录 → 打开用户管理  
- [ ] 登录说明 4 问已写完（自己的话）  
- [ ] 用户列表路径表已填完  
- [ ] Swagger 记录已写完  
- [ ] 能口头答 [02-reading-list.md](../02-reading-list.md) 里至少 **6** 题  
- [ ] `git status` 干净或只有业务/笔记；**无密码文件**  

---

## 3. 正式验收标准（导师打勾）

- [ ] 环境 checklist 最低标准达成，现场可登录  
- [ ] 登录链路说明（自己的话，含 4 个必答题）  
- [ ] 用户列表路径表完整（含权限字符）  
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

**建议打包方式：** 一个文件夹或一篇飞书文档，四个标题对应四份作业。

---

## 5. 红线与求助

**红线：**

- 不把密码、secret 提交到 Git  
- 不把本机服务乱暴露到公网  
- 不改 Security 全局策略「图省事」  

**求助模板（卡住 > 1 小时请用）：**

```text
任务：W1 第 X 天 / 第 X 节
现象：
已尝试：
环境：WSL / Windows / macOS；JDK 版本；Redis/MySQL 是否已启动
报错全文：
```

---

## 6. 完成后

导师确认 W1 **通过** 后，再领取：

→ [W2-notice-enhancement.md](./W2-notice-enhancement.md)

**不要自己提前大改公告模块**，除非导师提前书面下达 W2。
