# 零基础概念课（先读这个）

> 对象：几乎没做过完整 Web 项目、或只写过单机小程序的同学。  
> 目标：用大白话建立「这个系统在干什么」的图景，再去装环境、看代码。  
> 读完时间：约 1～2 小时。不必一次背会，可边做环境边回看。

---

## 0. 你将要运行的是什么？

本仓库是一个 **管理后台**（像公司内部的「用户管理、角色权限、菜单、通知公告」后台），技术上叫 **前后端分离**：

```text
┌─────────────────┐         HTTP 请求          ┌─────────────────┐
│  前端 ruoyi-ui  │  ───────────────────────►  │ 后端 ruoyi-admin│
│  (Vue 网页)     │  ◄───────────────────────  │ (Java 接口)     │
│  浏览器里看的   │         JSON 数据           │ 端口常 8080     │
└─────────────────┘                            └────────┬────────┘
                                                        │
                              ┌─────────────────────────┼─────────────────────────┐
                              ▼                         ▼                         ▼
                         MySQL 数据库                 Redis 缓存              本地上传目录
                      (用户/菜单等业务数据)        (登录会话等)              (头像/文件)
```

| 名词 | 大白话 |
| --- | --- |
| **前端** | 你在浏览器里看到的页面、按钮、表格。本项目在 `ruoyi-ui` 文件夹。 |
| **后端** | 跑在服务器/本机上的 Java 程序，提供「登录、查用户」等接口。入口模块是 `ruoyi-admin`。 |
| **接口 / API** | 前后端约定好的 URL，例如 `POST /login`。前端发请求，后端返回 JSON。 |
| **数据库 MySQL** | 把用户、角色、菜单等长期存盘的地方。关掉程序数据还在。 |
| **Redis** | 一种很快的内存数据库。本项目主要用来存「谁已登录」的会话，不是存全部业务表。 |
| **JSON** | 一种文本数据格式，像 `{"code":200,"msg":"成功"}`，前后端靠它传数据。 |

**和「打开一个 .html 文件」的区别：**  
这里必须 **同时** 开着后端 + 前端（开发时），并且 MySQL、Redis 已启动，页面才能登录成功。

---

## 1. 仓库里一堆文件夹是什么？

在仓库根目录你会看到类似：

| 路径 | 是什么 | 零基础要记住 |
| --- | --- | --- |
| `ruoyi-admin` | 后端**启动入口** + Controller（对外 HTTP 接口） | 你点「运行」主要跑这里 |
| `ruoyi-framework` | 安全、JWT、登录服务等**框架装配** | 登录链路很多在这里 |
| `ruoyi-system` | 用户/角色/菜单等**业务** Service、Mapper | 业务逻辑常在这里 |
| `ruoyi-common` | 工具类、通用模型 | 被别人依赖，一般不单独启动 |
| `ruoyi-quartz` | 定时任务 | 第 1 周可先忽略 |
| `ruoyi-generator` | 代码生成器 | 第 1 周不要乱用 |
| `ruoyi-ui` | **前端** Vue 项目 | `npm run dev` 在这里执行 |
| `sql/` | 建表和初始数据的 `.sql` 文件 | 装库时要导入 |
| `docs/` | 文档（审计、指南、实习生手册） | 你主要读 `docs/intern` |
| `pom.xml` | Maven 的「总工程说明」 | 后端依赖和模块列表 |

**依赖关系（只需建立印象）：**

```text
浏览器 → ruoyi-admin → ruoyi-framework → ruoyi-system → ruoyi-common
                ↘ ruoyi-quartz / ruoyi-generator → ruoyi-common
```

更细的术语见根目录 [CONTEXT.md](../../CONTEXT.md)（第 1 周后半再精读）。

---

## 2. 一次「打开用户列表」实际发生了什么？

用故事理解（不必一次记住类名）：

1. 你在浏览器登录成功。后端发给你一串 **Token**（可以理解为「临时通行证编号」）。  
2. 前端把 Token 存起来（常见在 Cookie/本地存储），以后每次请求自动放在请求头里。  
3. 你点击左侧 **系统管理 → 用户管理**。  
4. 前端向后端请求「用户列表」API，并带上 Token。  
5. 后端先检查：Token 有效吗？这个人有没有 `system:user:list` 这类**权限字符**？  
6. 通过后，Service 查 MySQL，返回 JSON；前端表格渲染出来。

**三层权限（面试和验收常问）：**

| 层 | 管什么 | 谁负责 | 只靠前端藏按钮够不够？ |
| --- | --- | --- | --- |
| 菜单/路由 | 侧边栏能不能看到这个页面 | 后端菜单 + 前端动态路由 | 不够 |
| 按钮/接口 | 能不能调用某个 API | 后端 `@PreAuthorize` 等 | **必须后端拦** |
| 数据权限 | 能看全公司还是仅本部门 | `@DataScope` 等 | 第 1 周了解名字即可 |

---

## 3. 登录相关：JWT、Redis、验证码（大白话）

| 名词 | 大白话 |
| --- | --- |
| **验证码** | 登录页算式/字符，防止机器人瞎试密码。答案短期存在 Redis。 |
| **用户名密码** | 和数据库里加密后的密码比对（BCrypt，不是明文存）。 |
| **JWT** | 一种令牌格式。本项目里 JWT 更像「钥匙牌上的编号」，完整会话内容在 Redis。 |
| **Redis 中的 login_tokens** | 键前缀类似 `login_tokens:`，后面跟会话 id，值是登录用户信息。 |
| **Authorization 请求头** | 后续请求常带 `Bearer <token>`，后端过滤器靠它认出你是谁。 |

更准确的时序图见 [docs/audit/01-architecture.md](../audit/01-architecture.md)，你写 W1 作业时用**自己的话**重述，不要整段复制。

---

## 4. 开发日常会碰到的工具

| 工具 | 干什么 | 你怎么用 |
| --- | --- | --- |
| **Git** | 代码版本管理 | `clone` 下载，`branch` 开分支，`commit` 提交，`push` 上传 |
| **JDK** | 跑 Java 程序的「运行时」 | 本项目要 **17 或以上** |
| **Maven (`mvn`)** | 下载 Java 依赖、编译打包 | 后端构建常用 |
| **Node.js / npm** | 跑前端工具链 | 在 `ruoyi-ui` 里 `npm install`、`npm run dev` |
| **MySQL** | 业务数据库 | 导入 `sql/ry_*.sql` |
| **Redis** | 缓存/会话 | 必须先启动，否则登录常失败 |
| **IDEA / VS Code** | 写代码、点运行 | 后端常用 IDEA；前端也可用 VS Code |
| **浏览器 F12** | 开发者工具 | Network 看请求；Console 看报错 |
| **Swagger** | 网页上试调 API | 菜单「系统工具 → 系统接口」或见指南 |

---

## 5. Git 最小够用（零基础）

```text
仓库（repository）= 这个项目的全部历史
分支（branch）     = 一条独立修改线；大家默认在 master
提交（commit）     = 一次存档快照
推送（push）       = 把本地提交传到远程（如 GitHub）
拉取（pull）       = 把远程更新拉到本地
PR / Merge Request = 申请把你的分支合并进 master，给导师审查
```

**本实习约定：**

```bash
# 在 master 上更新后，开自己的分支干活
git checkout master
git pull
git checkout -b feature/你的名字-onboarding

# 改完代码
git status                    # 看改了哪些文件
git add <文件或目录>
git commit -m "简短说明做了什么"
# git push -u origin feature/你的名字-onboarding
# 然后在网页提 PR（按团队流程）
```

**绝对不要：**

- 把数据库密码、Token 密钥写进代码再 `commit`
- 在 `master` 上直接乱改后强推
- `git add .` 之前不看 `git status`（容易把临时文件、密码配错提交）

---

## 6. 前端 / 后端代码大概长什么样？

### 后端一个接口（简化理解）

```text
浏览器 POST /system/user/list
    → SysUserController 某个方法（门口接待）
        → 上面可能有 @PreAuthorize("…权限字符…")（门卫）
        → UserService 查业务（办事员）
        → Mapper/XML 访问 MySQL（档案室）
    → 返回 JSON
```

### 前端一次列表加载（简化理解）

```text
用户.vue 页面
  → 调用 api/system/user.js 里的 listUser()
    → axios 发 HTTP（自动带 Token）
  → 拿到 rows 填到表格
```

**你怎么「跟代码」：**

1. 先找 **Controller** 上的 URL 映射（`@GetMapping` / `@PostMapping`）。  
2. 再进 **Service** 方法。  
3. 再打开 **Mapper 接口** 和 `resources/mapper/**/*.xml`。  
4. 前端从 `ruoyi-ui/src/api/**` 和 `views/**` 对应页面找。

W1 任务书里列了具体文件路径，按表填写即可。

---

## 7. 配置文件是什么？为什么一改就能连上数据库？

后端启动时会读：

| 文件 | 常见内容 |
| --- | --- |
| `ruoyi-admin/src/main/resources/application.yml` | 端口 `8080`、Redis、上传目录、验证码类型等 |
| `application-druid.yml` | **MySQL 地址、用户名、密码**（由 `spring.profiles.active=druid` 激活） |

这些是 **YAML 配置**，不是 Java 代码。你改的是「连哪台库」，不是改业务逻辑。

**安全常识：** 仓库里可能有**演示用**默认密码，只允许在你自己电脑上练习。  
**禁止**把真实生产密码提交到 Git；**禁止**把默认配置的服务直接暴露到公网。

---

## 8. 端口、代理（为什么前端 80、后端 8080？）

| 服务 | 默认端口（以配置为准） | 说明 |
| --- | --- | --- |
| 后端 Spring Boot | `8080` | `application.yml` 里 `server.port` |
| 前端 dev server | 常为 `80` | `vue.config.js`；浏览器访问 `http://localhost` |
| MySQL | `3306` | 数据库 |
| Redis | `6379` | 缓存 |

开发时，前端配置了 **代理（proxy）**：  
浏览器请求 `/dev-api/xxx` → 开发服务器转发到 `http://localhost:8080/xxx`。  
这样浏览器觉得前后端「同源」，少很多跨域麻烦。  
详见 `ruoyi-ui/.env.development` 的 `VUE_APP_BASE_API` 与 `vue.config.js` 的 `proxy`。

若 80 端口要管理员权限或被占用，可改前端端口，并问导师怎么改。

---

## 9. 默认演示账号（仅本地）

导入官方 SQL 后，常见初始化用户（以你导入的 SQL 为准；哈希对应官方默认口令习惯）：

| 用户名 | 常见初始密码 | 说明 |
| --- | --- | --- |
| `admin` | `admin123` | 超级管理员，菜单最全 |
| `ry` | `admin123` | 测试员（权限较少） |

登录成功后**建议在本地改成自己的密码**（仍不要写进仓库）。  
若登录失败：先查验证码、Redis 是否启动、用户是否被锁定（密码错太多次）。

---

## 10. 学习时怎么提问（导师最喜欢的格式）

不要只发：「跑不起来怎么办？」

请按下面四行：

```text
1. 我在做：docs/intern/tasks/W1-... 第 X 节
2. 现象：浏览器/终端完整报错（复制文本，不要只截半张图）
3. 已尝试：例如 Redis 已 ping 通、已重启后端、已核对库名 ry-vue
4. 环境：Windows / WSL / macOS；JDK 版本；相关配置键是否改过（不要贴真实密码）
```

---

## 11. 第 1 周你不需要精通的东西

下面这些**知道名字即可**，别在第一周深挖到焦虑：

- Spring 全部注解原理、AOP 实现细节  
- Vue 响应式底层  
- 分布式、微服务、Docker/K8s  
- 完整渗透测试、改生产 Security  hardening  
- 代码生成器批量建复杂业务  

**第 1 周成功标准：** 环境能登录 + 能讲清登录和用户列表链路 + Swagger 能调通。

---

## 12. 建议学习顺序（零基础）

```text
① 本文 07-zero-basics.md
② 05-environment-checklist.md + 08-local-setup-step-by-step.md   ← 动手装
③ tasks/W1-login-and-user-list.md                               ← 正式任务
④ CONTEXT.md（术语）+ docs/audit/01-architecture.md（链路）
⑤ docs/guides/api-docs-swagger.md
⑥ （第 2 周）tasks/W2-notice-enhancement.md
```

带教安排与任务池见 [README.md](./README.md)。

---

## 13. 自测：读完本文能否回答？

1. 前端文件夹和后端启动模块各叫什么？  
2. MySQL 和 Redis 在本项目里大致各存什么？  
3. 为什么「前端隐藏按钮」不能当唯一安全手段？  
4. Token 大概在请求的什么位置携带？  
5. 你应该在哪个 Git 分支上写作业？  

答得含糊没关系，回到对应小节再读一遍，然后去装环境。
