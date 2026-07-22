# 本地环境逐步安装指南（零基础 / Linux 与 WSL）

> 按章节**从上到下**做。每做完一节，回到 [05-environment-checklist.md](./05-environment-checklist.md) 打勾。  
> 本指南以 **Linux / WSL2** 为主（与当前常见开发环境一致）。纯 Windows 见文末附录。  
> 命令行提示符以 `$` 开头，**不要**把 `$` 一起复制。

**安全：配置里的密码只用于本机；不要 `git commit` 进仓库。**

---

## 第 0 步：你需要准备什么？

| 条件 | 说明 |
| --- | --- |
| 一台电脑 | 内存建议 8GB 及以上 |
| 磁盘 | 至少数 GB 空余（依赖较多） |
| 网络 | 能下载 Maven/npm 依赖（可配镜像，见后文） |
| 导师提供的仓库地址 | 例如 GitHub/Gitee 上的 fork 地址 |
| 心态 | 第一次装环境卡 1～2 天很正常，按「提问模板」找导师 |

**将要安装/启动的组件：**

1. Git  
2. JDK 17+  
3. Maven  
4. Node.js + npm  
5. MySQL 8（或兼容版本）  
6. Redis  
7. 本仓库代码  
8. （推荐）IDEA 或 VS Code  

---

## 第 1 步：安装 Git 并验证

```bash
# Debian/Ubuntu/WSL 示例
sudo apt update
sudo apt install -y git

git --version
```

看到类似 `git version 2.x.x` 即可。  
勾选 checklist **A4**。

配置身份（提交会用到，用你自己的名字和邮箱）：

```bash
git config --global user.name "你的名字"
git config --global user.email "你的邮箱@example.com"
```

---

## 第 2 步：安装 JDK 17

```bash
# Ubuntu/WSL 示例（包名因源而异，任选一种能装上 17 的方式）
sudo apt install -y openjdk-17-jdk

java -version
javac -version
```

`java -version` 应显示 **17**（或更高）。  
若仍是 8/11，需要调整 `JAVA_HOME` 或默认 java（问导师或搜：`update-alternatives --config java`）。

勾选 **A1**。

---

## 第 3 步：安装 Maven

```bash
sudo apt install -y maven
mvn -version
```

应能看到 Maven 版本，且指向 Java 17。  
勾选 **A2**。

> 第一次编译会下载大量依赖，时间长、需要网络，属正常。

---

## 第 4 步：安装 Node.js 与 npm

推荐使用 **Node 16+ 或 18 LTS**（以能成功 `npm install` 为准）。  
示例（用 NodeSource 或 nvm 均可；以下为示意，以你系统文档为准）：

```bash
node -v
npm -v
```

若未安装，可在导师指导下安装 nvm 再装 Node，或：

```bash
# 仅作参考；不同发行版命令不同
sudo apt install -y nodejs npm
```

勾选 **A3**。

**国内网络慢时**，可对 npm 使用镜像（示例）：

```bash
npm config set registry https://registry.npmmirror.com
```

---

## 第 5 步：安装并启动 MySQL

### 5.1 安装（示例）

```bash
sudo apt install -y mysql-server
sudo service mysql start
# 或：sudo systemctl start mysql
```

### 5.2 登录并建库

```bash
sudo mysql -u root
```

在 MySQL 提示符下（密码按你环境设置；开发机可设本地密码）：

```sql
CREATE DATABASE `ry-vue` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
-- 若使用密码用户，请按你们规范创建用户并授权；开发示例：
-- CREATE USER 'ruoyi'@'localhost' IDENTIFIED BY '你的本地密码';
-- GRANT ALL ON `ry-vue`.* TO 'ruoyi'@'localhost';
-- FLUSH PRIVILEGES;
EXIT;
```

勾选 **A5、C1**。

> 库名 `ry-vue` 与仓库默认 `application-druid.yml` 中 URL 一致，**初学建议不要改库名**，少踩坑。

---

## 第 6 步：安装并启动 Redis

```bash
sudo apt install -y redis-server
sudo service redis-server start
# 或：redis-server &

redis-cli ping
```

应返回 `PONG`。勾选 **A6**。

若 Redis 设置了密码，后面要在 `application.yml` 的 `spring.data.redis.password` 填写（**不要提交真实密码**）。

---

## 第 7 步：获取本仓库代码

把下面的 `仓库地址` 换成导师给你的地址：

```bash
cd ~
# 示例：
# git clone https://github.com/MakeLuvHell/Java-base.git
git clone <仓库地址>
cd Java-base   # 若目录名不同，以实际为准

git checkout master
git pull
git checkout -b feature/你的名字-onboarding
```

勾选 **B1、B2、B3**。

用资源管理器或 `ls` 确认能看到 `ruoyi-admin`、`ruoyi-ui`、`sql` 等目录。

---

## 第 8 步：导入初始化 SQL

仓库中主脚本文件名示例：`sql/ry_20260417.sql`（**以你目录下实际文件名为准**）。

```bash
cd ~/Java-base   # 你的项目根目录
ls sql/
```

导入示例（密码按你的 MySQL 设置；`-p` 后会提示输入）：

```bash
mysql -u root -p ry-vue < sql/ry_20260417.sql
```

若第 1 周需要「定时任务」菜单完整数据，再导入：

```bash
mysql -u root -p ry-vue < sql/quartz.sql
```

导入后可简单检查：

```bash
mysql -u root -p -e "USE \`ry-vue\`; SHOW TABLES;" | head
```

应能看到 `sys_user`、`sys_menu` 等表。勾选 **C2**（及可选 **C3**）。

---

## 第 9 步：修改后端配置（最容易错）

### 9.1 数据源 `application-druid.yml`

文件路径：

```text
ruoyi-admin/src/main/resources/application-druid.yml
```

关注：

```yaml
url: jdbc:mysql://localhost:3306/ry-vue?......
username: root
password: password    # ← 改成你本机 MySQL 密码
```

把 `username` / `password` 改成你自己的。  
**改完不要 commit 到 Git**（见第 14 步）。勾选 **C4、D2**。

### 9.2 主配置 `application.yml`

文件路径：

```text
ruoyi-admin/src/main/resources/application.yml
```

| 配置项 | 建议 |
| --- | --- |
| `server.port` | 默认 `8080`，被占用可改，并同步前端代理 |
| `spring.data.redis.host` | 本机一般为 `localhost` |
| `spring.data.redis.port` | 默认 `6379` |
| `spring.data.redis.password` | 无密码可留空（按文件原有写法） |
| `ruoyi.profile` | **上传文件目录**。仓库示例可能是 Windows 的 `D:/ruoyi/uploadPath`。在 Linux/WSL 请改成你有写权限的路径，例如 `/home/你的用户名/ruoyi/uploadPath`，并先 `mkdir -p` 创建 |

勾选 **D1、D3**。

### 9.3 关于「默认演示密钥」

文件中可能有 `token.secret`、Druid 控制台账号等**演示值**。  
**仅限本机学习**。不要把服务映射到公网；不要把公司真实密钥写进仓库。

---

## 第 10 步：启动后端

### 方式 A：命令行（不依赖 IDEA）

在项目**根目录**（有最外层 `pom.xml` 的目录）：

```bash
# 首次会下载依赖，可能需 10～30 分钟
mvn -pl ruoyi-admin -am spring-boot:run
```

或先打包再运行（较慢，但接近部署形态）：

```bash
mvn clean package -DskipTests
java -jar ruoyi-admin/target/ruoyi-admin.jar
```

> 具体 jar 文件名以 `ruoyi-admin/target/` 下为准。

### 方式 B：IDEA

1. 用 IDEA 打开项目根目录（识别为 Maven 工程）。  
2. 等待依赖索引完成。  
3. 找到 `ruoyi-admin/src/main/java/com/ruoyi/RuoYiApplication.java`（类名以实际为准，一般为 `RuoYiApplication`）。  
4. 右键 Run。

### 启动成功的标志

终端日志中出现类似「启动成功」提示；浏览器访问：

```text
http://localhost:8080
```

可能看到后端提示页或 JSON，而不是完整管理 UI（完整 UI 在前端）。  

若失败，看第 15 步排障。勾选 **D4、D5**。

---

## 第 11 步：启动前端

新开一个终端：

```bash
cd ~/Java-base/ruoyi-ui
npm install
# 若很慢：
# npm install --registry=https://registry.npmmirror.com

npm run dev
```

成功后终端会提示本地访问地址，常见：

```text
http://localhost
```

（端口以 `vue.config.js` / 环境变量为准，可能是 80 或其他。）

浏览器打开该地址 → 应看到若依登录页。勾选 **E1～E4**。

### 登录

| 用户名 | 密码（常见初始值） |
| --- | --- |
| admin | admin123 |

若验证码看不清，点验证码图片刷新。  
登录成功后进入布局页。勾选 **E5**。

---

## 第 12 步：冒烟点击（确认「真的可用」）

登录后依次点：

1. **系统管理 → 用户管理**（有表格数据）  
2. **系统管理 → 角色管理 / 菜单管理**  
3. **系统管理 → 字典管理**  
4. **系统工具 → 系统接口**（Swagger 页，若菜单存在）  

勾选 **F1～F3**。

Swagger 详细用法见 [docs/guides/api-docs-swagger.md](../guides/api-docs-swagger.md)。  
完成一次 Authorize 后勾选 **F4**。

---

## 第 13 步：开发时两个终端怎么摆？

```text
终端 1：后端一直运行（mvn spring-boot:run 或 IDEA Run）
终端 2：前端一直运行（npm run dev）
终端 3：Git、mysql、临时命令
```

改后端 Java 后通常需等待热重启或手动重启。  
改前端 Vue 后一般自动热更新。

---

## 第 14 步：千万别把密码提交进 Git

每次准备提交前：

```bash
git status
git diff
```

检查是否出现：

- `password: 真实密码`
- 公司密钥、连接串  

本机修改配置的推荐做法（与导师确认其一）：

1. **只改本地，永远不 add 该文件**；或  
2. 使用本地覆盖配置（若团队有 `application-local.yml` 且已 gitignore）；或  
3. 提交前用 `git checkout -- 某配置文件` 恢复，仅保留业务代码提交  

勾选 **B4**。

---

## 第 15 步：常见问题排障

| 现象 | 可能原因 | 试法 |
| --- | --- | --- |
| 登录提示验证码错误 | Redis 没开 / 连错 Redis / 验证码过期 | `redis-cli ping`；重启后端；刷新验证码 |
| 登录提示用户不存在/密码错 | SQL 未导入或库连错 | 查 `application-druid.yml` 库名；查 `sys_user` 表 |
| 后端启动报连库失败 | 密码错、MySQL 未启动、库名错 | `sudo service mysql status`；手动 `mysql` 登录 |
| 后端启动报 Redis 相关错 | Redis 未启动或要密码 | 启动 Redis；核对 yml |
| 前端页面空白/网络错误 | 后端没开；代理不对 | 确认 8080 可访问；看浏览器 F12 Network |
| `npm install` 失败 | 网络/Node 版本 | 换镜像；换 Node 18；删 `node_modules` 重装 |
| `mvn` 下载极慢 | 网络 | 配置国内 Maven 镜像（settings.xml，问导师） |
| 端口占用 | 8080/80 被占 | 改 `server.port` 或关掉占用进程 |
| Linux 上传/头像报错 | `ruoyi.profile` 仍是 `D:/...` | 改成 Linux 路径并 `mkdir -p` |
| 密码错误次数过多被锁 | 安全策略 | 等锁定时间或清 Redis 中相关键（问导师） |
| WSL 里 localhost 混乱 | Windows/WSL 网络 | MySQL/Redis 装在同一侧；统一用 WSL 内地址 |

仍然不行 → 用 [07-zero-basics.md](./07-zero-basics.md) 第 10 节提问模板找导师。

---

## 第 16 步：装好后立刻做什么？

1. 打开 [05-environment-checklist.md](./05-environment-checklist.md) 把 A～F 勾完。  
2. 打开 [tasks/W1-login-and-user-list.md](./tasks/W1-login-and-user-list.md) 从「阅读」和「登录链路」继续。  
3. 阅读 [07-zero-basics.md](./07-zero-basics.md) 未消化的章节。  

---

## 附录 A：纯 Windows 提示（摘要）

| 组件 | 提示 |
| --- | --- |
| JDK/Maven | 可用官方安装包；配置 `JAVA_HOME`、`Path` |
| MySQL/Redis | 可用安装版或 Docker Desktop |
| 上传目录 | `ruoyi.profile` 可用 `D:/ruoyi/uploadPath`，先建文件夹 |
| 命令行 | PowerShell / Windows Terminal；SQL 导入可用 MySQL Workbench |
| 端口 80 | 可能需要管理员权限才能 `npm run dev`，可改端口 |

步骤逻辑与上文相同：**先库和 Redis → 改配置 → 启后端 → 启前端 → 登录**。

---

## 附录 B：你需要记住的默认端口与路径

| 项 | 默认/示例 |
| --- | --- |
| 后端 | `http://localhost:8080` |
| 前端开发 | `http://localhost`（或终端提示） |
| 数据库名 | `ry-vue` |
| 主 SQL | `sql/ry_20260417.sql`（以实际为准） |
| 数据源配置 | `ruoyi-admin/src/main/resources/application-druid.yml` |
| 主配置 | `ruoyi-admin/src/main/resources/application.yml` |
| 前端目录 | `ruoyi-ui/` |
| 演示账号 | `admin` / `admin123`（仅本地） |

---

## 附录 C：一次成功的「最小命令回顾」

```bash
# 基础设施
sudo service mysql start
sudo service redis-server start
redis-cli ping

# 后端（项目根）
mvn -pl ruoyi-admin -am spring-boot:run

# 前端（另一终端）
cd ruoyi-ui && npm run dev
```

浏览器打开前端地址 → `admin` / `admin123` → 进系统。
