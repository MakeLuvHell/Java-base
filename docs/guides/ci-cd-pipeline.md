# CI/CD 工程流水线说明与操作指南

本文说明 **CI/CD 是什么、有什么作用**，以及在本仓库（RuoYi-Vue / Java-base 二次开发）中如何理解、落地与日常操作。  
内容覆盖：概念、与审计风险的关系、本仓库现状、本机 / Docker / GitHub Actions 三种跑法、推荐落地阶段、开发者日常流程、排障与检查清单。

> **范围说明：** 本文为工程与流程文档。仓库在编写本文时 **可能尚未提交** 正式的 `.github/workflows/ci.yml` 或 Dockerfile；文中的命令与 YAML 为 **推荐落地模板**，以你仓库中实际文件为准。  
> 安全整改（密钥、Druid、Swagger 暴露等）见 [docs/audit/04-remediation-roadmap.md](../audit/04-remediation-roadmap.md)，与 CI/CD **互补**：CI 负责发现与门禁，整改负责消除配置/代码风险。

---

## 1. 它是什么、不是什么

| 是 | 不是 |
| --- | --- |
| 一套「提交代码后自动检查，通过后再交付/部署」的工程实践 | 某一个必须装在本机的桌面软件 |
| **CI**：持续集成 —— 自动构建、测试、扫描 | 替代代码审查（Code Review）本身 |
| **CD**：持续交付/部署 —— 自动或一键发布到环境 | 必须一上来就自动发生产（很多团队只做 CI） |
| 可用 GitHub Actions、GitLab CI、Jenkins、本机脚本、Docker 实现 | 只有云厂商才能做 |
| 对应审计中的 **SEC-012（供应链/构建扫描）**、**SEC-013（测试）** 的落地手段 | 审计文档本身；文档只描述风险与建议 |

同属「二次开发工程化」的其它主题对比：

| 主题 | 文档 | 关注点 |
| --- | --- | --- |
| API 文档与在线调试 | [api-docs-swagger.md](./api-docs-swagger.md) | SpringDoc / Swagger 怎么用 |
| 安全整改批次 | [04-remediation-roadmap.md](../audit/04-remediation-roadmap.md) | P1–P3 改什么配置/代码 |
| **CI/CD 流水线（本文）** | 本文 | 构建、测试、扫描、发布如何自动化 |

---

## 2. 术语速查

| 术语 | 含义 |
| --- | --- |
| **CI（Continuous Integration）** | 持续集成。多人/多次提交后，系统自动合并构建与验证，尽早发现冲突与破坏。 |
| **CD（Continuous Delivery）** | 持续交付。流水线产出**随时可发布**的制品（jar、镜像、静态资源包），上线通常仍可人工确认。 |
| **CD（Continuous Deployment）** | 持续部署。验证通过后**自动部署**到目标环境（要求门禁更严）。口语里常与 Delivery 统称 CD。 |
| **Pipeline / 流水线** | 按阶段串联的自动化任务：检出代码 → 构建 → 测试 → 扫描 →（打包）→（部署）。 |
| **Job / Step** | 流水线中的作业与步骤；失败通常使整次运行失败（fail-fast，可配置）。 |
| **Artifact（制品）** | 构建产物，如 `ruoyi-admin.jar`、`ruoyi-ui/dist`、扫描 HTML 报告。 |
| **Runner** | 执行流水线的机器。GitHub 托管为 `ubuntu-latest` 等；也可自建 Runner。 |
| **门禁（Gate）** | 未通过则不允许合并/发布，例如 PR 必须 CI 绿。 |
| **锁文件（lockfile）** | 如 `package-lock.json`，锁定前端依赖精确版本，便于 `npm ci` 可复现安装。 |
| **SEC-012 / SEC-013** | 审计台账项：供应链与 CI 扫描；补充自动化测试。见 [03-security.md](../audit/03-security.md)。 |

---

## 3. 为什么需要 CI/CD（作用）

### 3.1 CI 的作用

| 作用 | 没有 CI 时 | 有 CI 时 |
| --- | --- | --- |
| 统一构建 | 「我本机能编过」≠ 别人/服务器能编过 | 固定环境（JDK 17、同一 Maven/Node）每次重跑 |
| 尽早失败 | 合并很久后才发现编译/测试挂了 | push/PR 当时就红，改动面还小 |
| 自动测试 | 靠人工记得跑，仓库还可能几乎无测试 | `mvn test` 等进入固定步骤（SEC-013） |
| 依赖与漏洞可见 | 偶尔有人手动 audit | 定期/每次流水线出报告（SEC-012） |
| 保护主分支 | 坏代码直接进 `master` | PR Checks 不绿不合并（可配置） |
| 可追溯 | 口口相传「上次发版步骤」 | 每次 run 有日志与提交 SHA |

### 3.2 CD 的作用

| 作用 | 说明 |
| --- | --- |
| 缩短上线路径 | 从「制品已有」到「环境已更新」步骤脚本化 |
| 减少人为失误 | 少手工 scp、少漏改配置项（密钥仍应走密钥管理，勿写死镜像） |
| 可重复与回滚 | 同一 tag/镜像可重部署；失败可切回上一版本 |
| 环境一致 | 测试/预发/生产用相近的构建产物与启动方式 |

### 3.3 和「安全整改」的分工

```text
安全整改  →  消除已知风险（换密钥、关 Swagger 公网、收紧 CORS…）
CI/CD     →  每次变更自动验证构建/测试/扫描，防止回退与漏检
```

两者并行：先做 P1 整改不阻塞搭 CI；搭好 CI 后，整改提交也会被自动验证「是否还能编过」。

---

## 4. 端到端流程长什么样

```text
开发者改代码
    │
    ▼
git commit
    │
    ▼
git push  /  打开或更新 Pull Request
    │
    ▼
┌──────────────────────── CI ────────────────────────┐
│  1. Checkout 仓库                                   │
│  2. 准备 JDK 17 / Node（或 Docker 镜像内工具链）     │
│  3. 后端：mvn -B clean package / test               │
│  4. 前端：npm ci（或 install）+ npm run build:prod  │
│  5. 可选：OWASP Dependency-Check、npm audit         │
│  6. 上传制品或扫描报告（Artifact）                    │
│  结果：成功（绿）或失败（红 + 日志）                   │
└────────────────────────────────────────────────────┘
    │
    │ 失败 → 根据日志修复 → 再 push（不进入发布）
    ▼
┌──────────────────────── CD ────────────────────────┐
│  持续交付：保留 jar / dist / 镜像，待人工批准发布      │
│  持续部署：自动发布到测试或生产（需额外配置与权限）    │
└────────────────────────────────────────────────────┘
    │
    ▼
目标环境运行新版本（健康检查 / 必要时回滚）
```

**对开发者而言：** 日常「运行流水线」≈ **push 或开 PR**（或在 Actions 页手动 Run），而不是在本机点一个叫 CI 的程序。

---

## 5. 本仓库现状（基线）

以下为审计与文档编写时的常见状态，落地后请以仓库实际文件为准并回写本节。

| 项 | 典型现状 | 含义 |
| --- | --- | --- |
| 后端 | Maven 多模块，Java 17，Spring Boot 4.x | CI 应使用 **JDK 17** |
| 前端 | `ruoyi-ui`，Vue 2 + Vue CLI | CI 需 Node；建议 **Node 18/20 LTS** |
| 测试代码 | 仓库内 `src/test` 往往很少或为 0 | `mvn test` 可能「空跑通过」，需逐步补 SEC-013 |
| 前端 lockfile | 可能无 `package-lock.json` | `npm ci` / `npm audit` 受限；需团队约定是否提交 lock |
| GitHub Actions | 可能仅有 `.github/FUNDING.yml`，**无业务 workflow** | **CI 未落地** 时 push 不会自动构建 |
| Docker | 官方骨架通常无 Dockerfile/compose | 可用官方 `maven`/`node` 镜像做构建沙箱；整站编排需自补 |
| 远程 | `origin` 指向自有 GitHub（如 Java-base）时，Actions 在该仓库生效 | 需仓库 **Settings → Actions** 允许运行 |

**审计对应：**

- 构建与依赖扫描未进流水线 → [03-security.md](../audit/03-security.md) **SEC-012**
- 缺少自动化测试 → **SEC-013**
- 整改批次 B3/B4 → [04-remediation-roadmap.md](../audit/04-remediation-roadmap.md)

---

## 6. 三种实现路径（任选组合）

### 6.1 路径对比

| 路径 | 本机需要 | 触发方式 | 适合 |
| --- | --- | --- | --- |
| **A. 本机工具链** | JDK 17、Maven、Node | 手动敲命令 | 深度调试、无网络 CI 时 |
| **B. Docker 构建沙箱** | 主要 Docker | 手动 `docker run` / 以后 compose | 本机不想装 JDK/Node |
| **C. GitHub Actions** | 只需 Git（能 push） | push / PR / 手动 Run | 团队门禁、与远程协作 |

推荐组合：

```text
日常开发    →  A 或 B 本地验证（可选）
合并门禁    →  C 必跑
联调整站    →  本机或 compose 起 MySQL + Redis + 应用（属运行环境，不单是 CI）
生产发布    →  CD（后期）：制品/镜像 + 服务器或 K8s
```

### 6.2 路径 A：本机命令（参考）

```bash
# 工具检查
java -version    # 17
mvn -version
node -v
npm -v

cd /path/to/Java-base

# 后端构建（当前测试少时可先 skip）
mvn -B clean package -DskipTests

# 后端测试（补齐用例后作为门禁）
mvn -B test

# 前端
cd ruoyi-ui
npm install          # 若已提交 lockfile，CI 侧优先 npm ci
npm run build:prod
npm audit --omit=dev || true
```

### 6.3 路径 B：Docker 仅构建（无需本机 JDK）

```bash
cd /path/to/Java-base

# 后端（建议挂载 Maven 本地仓库卷加速二次构建）
docker run --rm \
  -v "$PWD":/app \
  -v maven-repo:/root/.m2 \
  -w /app \
  maven:3.9-eclipse-temurin-17 \
  mvn -B clean package -DskipTests

# 后端测试
docker run --rm \
  -v "$PWD":/app \
  -v maven-repo:/root/.m2 \
  -w /app \
  maven:3.9-eclipse-temurin-17 \
  mvn -B test

# 前端
docker run --rm \
  -v "$PWD/ruoyi-ui":/app \
  -w /app \
  node:20-bookworm \
  bash -c "npm install && npm run build:prod"
```

说明：

- 产物写在**宿主机**目录（`-v "$PWD":/app`），与本机构建一致。
- 首次拉镜像与下依赖较慢，属正常现象。
- **整站** `docker compose up`（MySQL/Redis/后端）需另补 compose 文件，与「仅 CI 构建」不是同一件事。

### 6.4 路径 C：GitHub Actions（云端 CI）

**开发者操作：**

```bash
git add .
git commit -m "说明变更"
git push origin <branch>
# 浏览器：GitHub 仓库 → Actions → 查看本次 run
```

或：开 Pull Request → 在 PR 页查看 **Checks**。

**平台侧：** 由 `.github/workflows/*.yml` 定义何时跑、跑什么（见第 8 节模板）。

---

## 7. 推荐落地阶段（工程批次）

与整改路线中的工程项对齐，建议分阶段，避免一次做完所有 CD。

| 阶段 | 目标 | 完成标准 | 对应 |
| --- | --- | --- | --- |
| **E0** | 任意环境能构建 | 本机或 Docker 或 CI 上 `mvn package` + 前端 `build:prod` 成功 | 基线 |
| **E1** | 提交 lock 策略 | 团队决定是否提交 `ruoyi-ui/package-lock.json`；CI 用 `npm ci` 或 `npm install` | 可复现 |
| **E2** | GitHub Actions CI | 存在 workflow；push/PR 自动跑后端构建 + 前端构建 | **最小可用 CI** |
| **E3** | 测试门禁 | 至少若干单元/切片测试；`mvn test` 有真实断言 | SEC-013 |
| **E4** | 扫描 | PR 或 nightly：OWASP 与/或 `npm audit`；报告可下载 | SEC-012 |
| **E5** | 制品归档 | Actions 上传 jar/dist 或扫描 HTML | 交付准备 |
| **E6** | CD（可选） | 部署到测试环境；生产需审批/手动 | 持续交付/部署 |

原则：

1. **先 CI 后 CD** —— 构建不稳时不要自动发生产。  
2. **扫描可夜间跑** —— OWASP 拉 NVD 慢，勿强行拖死每个 PR。  
3. **空测试套件变绿 ≠ 质量足够** —— 需按 SEC-013 补关键路径。

---

## 8. GitHub Actions 推荐配置（模板）

### 8.1 文件位置

```text
.github/workflows/ci.yml
```

### 8.2 最小可用示例（构建 + 测试 + 前端）

以下为**模板**，落地时请按仓库是否已有 lockfile 调整前端步骤；提交到默认分支后即可在 Actions 中看到运行。

```yaml
name: CI

on:
  push:
    branches: [master]
  pull_request:
    branches: [master]
  workflow_dispatch:  # 允许在 Actions 页手动「Run workflow」

concurrency:
  group: ci-${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  backend:
    name: Backend (Maven)
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'
          cache: maven

      - name: Build
        run: mvn -B clean package -DskipTests

      - name: Test
        run: mvn -B test

      # 可选：上传 jar（路径以实际 target 为准）
      # - name: Upload admin jar
      #   uses: actions/upload-artifact@v4
      #   with:
      #     name: ruoyi-admin-jar
      #     path: ruoyi-admin/target/*.jar
      #     if-no-files-found: ignore

  frontend:
    name: Frontend (Vue CLI)
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ruoyi-ui
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up Node
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          # 若已提交 package-lock.json，取消下一行注释并改用 npm ci
          # cache: npm
          # cache-dependency-path: ruoyi-ui/package-lock.json

      - name: Install
        run: npm install
        # 有 lockfile 时改为: npm ci

      - name: Build production
        run: npm run build:prod

      - name: Audit (report only)
        run: npm audit --omit=dev || true
```

### 8.3 扫描如何放入流水线

| 频率 | 建议 |
| --- | --- |
| **每个 PR** | 编译 + 测试 + 前端 build；`npm audit` 可只出报告不失败 |
| **每日/每周 / 手动** | OWASP Dependency-Check；完整依赖报告上传 Artifact |
| **发版前** | 全量 CI + 人工过一遍高危 CVE 与整改项 |

OWASP 示例（宜独立 job 或 `schedule`，避免拖慢每个 PR）：

```yaml
  dependency-check:
    name: OWASP Dependency-Check
    runs-on: ubuntu-latest
    # 可改为 only schedule / workflow_dispatch
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'
          cache: maven
      - name: Dependency-Check
        run: |
          mvn -B org.owasp:dependency-check-maven:check \
            -DfailBuildOnCVSS=11 \
            -DskipProvidedScope=true
        # failBuildOnCVSS=11：先只报告不因 CVE 失败；成熟后可降到 9 或 7
      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: dependency-check-report
          path: '**/dependency-check-report.html'
```

首次/无 NVD 缓存时会很慢；可配置 NVD API Key（以 OWASP 插件文档为准）并注意 **不要把密钥写进仓库明文**（用 GitHub Secrets）。

### 8.4 分支保护（推荐，在 GitHub 网页配置）

1. 仓库 **Settings → Branches → Branch protection rules**  
2. 对 `master`（或 `main`）：  
   - Require a pull request before merging（团队协作时）  
   - **Require status checks to pass** → 勾选 `Backend (Maven)` / `Frontend (Vue CLI)` 等  
3. 效果：CI 不绿无法合并，形成真正门禁。

---

## 9. 开发者日常怎么操作

### 9.1 第一次启用 CI 时

1. 将 workflow 文件加入仓库（或由维护者提交）。  
2. 推送：

   ```bash
   git add .github/workflows/ci.yml
   git commit -m "ci: add GitHub Actions build pipeline"
   git push origin master
   ```

3. 打开 `https://github.com/<owner>/<repo>/actions`  
4. 确认最新 run 为成功；失败则点进 job 日志排查。  
5. 若 Actions 被禁用：**Settings → Actions → General → Allow actions**。

### 9.2 日常开发（直接推 master —— 个人仓库常见）

```bash
# 1. 修改代码
# 2. 提交
git status
git add .
git commit -m "清晰说明本次变更"

# 3. 推送即触发 CI
git push origin master

# 4. 浏览器打开 Actions，等待结果
```

### 9.3 日常开发（分支 + PR —— 推荐）

```bash
git checkout master
git pull origin master
git checkout -b feature/your-topic

# 修改 → 提交
git add .
git commit -m "feat: ..."
git push -u origin feature/your-topic
```

1. 在 GitHub 创建 Pull Request。  
2. 等待 PR 上 **Checks** 全部通过。  
3. 代码审查通过后 Merge。  
4. 合并进默认分支后，可能再次触发 `push` 工作流。

### 9.4 如何阅读结果

| 界面 | 看什么 |
| --- | --- |
| **Actions** 列表 | 某次 commit 的 run 绿/红/黄（进行中） |
| 某次 run → job | 是后端挂还是前端挂 |
| 展开失败 step | 编译错误、测试断言、npm 错误原文 |
| **Re-run jobs** | 怀疑瞬时网络/缓存问题时重跑同一提交 |
| **Artifacts** | 下载扫描报告或 jar（若已配置上传） |

### 9.5 红了怎么办（通用顺序）

1. 打开失败 step 日志，定位**第一条 ERROR**。  
2. 在本地或 Docker 用**同一命令**复现（见第 6 节）。  
3. 修复后重新 commit + push（或推同一 PR 分支）。  
4. 不建议：为了变绿而盲目 `-DskipTests` 长期留在主分支门禁（临时排查除外）。

---

## 10. CD：持续交付 / 部署（后期）

当前文档以 **CI 为主**。CD 常见演进：

| 级别 | 做法 | 触发 |
| --- | --- | --- |
| L0 手工 | CI 只验证；人用 `scp`/面板上传 jar 与前端 dist | 发版日 |
| L1 半自动 | CI 产出 Artifact；脚本一键拉制品部署测试机 | 手动 workflow / 打 tag |
| L2 自动测试环境 | merge 到 master 后自动部署 **staging** | push 到 master |
| L3 生产 | 需审批、蓝绿/滚动、密钥与回滚预案 | 发布负责人批准 |

**注意：**

- 生产 **密钥、数据库口令、JWT secret** 使用环境变量或密钥管理，不要打进镜像层或提交到 Git（与 SEC-001/002 一致）。  
- 生产应关闭或限制 Swagger/Druid 公网暴露（SEC-003），部署清单里单独检查。  
- CD 失败要有回滚：保留上一版 jar/镜像 tag。

本仓库若后续增加 `Dockerfile` / `docker-compose.yml` / 部署 workflow，在本节或单独运维文档中补充真实命令。

---

## 11. 与本项目模块的对应关系

| 流水线步骤 | 项目路径 / 命令 | 说明 |
| --- | --- | --- |
| 后端构建 | 根目录 `mvn -B clean package` | 多模块 reactor；入口模块 `ruoyi-admin` |
| 后端测试 | `mvn -B test` | 测试类放在各模块 `src/test/java` |
| 前端安装 | `ruoyi-ui` 下 `npm ci` / `npm install` | 依赖见 `package.json` |
| 前端生产构建 | `npm run build:prod` | 产物 `ruoyi-ui/dist`（通常 gitignore） |
| 前端预发构建 | `npm run build:stage` | 可选 |
| 运行后端（非 CI 必需） | jar 或 `spring-boot:run` | 依赖 MySQL、Redis、正确 yml |
| 运行前端开发服 | `npm run dev` | 开发代理见 `vue.config.js` |
| API 调试 | Swagger | 见 [api-docs-swagger.md](./api-docs-swagger.md) |

集成测试若访问真实 Redis/MySQL，CI 中可使用 **GitHub Actions services** 启动容器数据库（进阶，E3 之后再做）。

---

## 12. 前端 lockfile 与 npm audit 策略

| 策略 | 做法 | 优点 | 缺点 |
| --- | --- | --- | --- |
| **A. 提交 package-lock.json** | `npm install` 后提交 lock；CI 用 `npm ci` | 可复现、audit 可用 | 与上游无 lock 习惯不一致，合并上游需处理 lock |
| **B. 不提交 lock** | CI 用 `npm install` | 与部分上游一致 | 依赖漂移；`npm audit` 可能 ENOLOCK |

审计期间曾出现：无 lockfile 时 `npm audit` 失败（ENOLOCK）。若目标包含 SEC-012 前端扫描，**策略 A 更省事**。

`npm audit --omit=dev || true`：先报告、不挡 PR；待团队有修复节奏后再改为失败即红。

---

## 13. 安全与密钥（流水线相关）

1. **GitHub Secrets** 存放 NVD Key、部署 SSH 密钥、镜像仓库口令等；workflow 中用 `${{ secrets.NAME }}` 引用。  
2. **不要**在日志中打印 token、密码、完整 `Authorization`。  
3. Fork PR 使用 secrets 有额外限制，注意供应链投毒与恶意 PR workflow（仅可信协作者写 workflow）。  
4. 扫描报告可能含依赖路径信息，Artifact 权限按仓库可见性管理。  
5. CI 绿 **不等于** 生产安全配置正确；P1 整改项仍须单独验收。

---

## 14. 常见问题

### 14.1 push 了但 Actions 里没有记录

- 默认分支名是否为 `master`（与 workflow `on.push.branches` 一致）。  
- Actions 是否被禁用。  
- workflow 文件 YAML 语法错误（有时不显示 run）。  
- 是否推送到了正确的远程 `origin`（自有 GitHub 而非仅 upstream）。

### 14.2 本机没有 JDK，能否用 CI？

可以。用 **GitHub Actions** 或 **Docker maven 镜像** 构建即可。本机只需能 `git push`。

### 14.3 `mvn test` 一直通过但什么也没测

仓库缺少测试时，Surefire 可能 0 tests。需按 SEC-013 增加用例；门禁价值来自断言，而非「命令退出码 0」。

### 14.4 前端 build 在 CI 内存不足

Vue CLI 生产构建较吃内存。可在 job 中增大 Node 内存，例如：

```yaml
env:
  NODE_OPTIONS: --max_old_space_size=4096
```

或升级 Runner 规格（自建/更大 runner）。

### 14.5 OWASP 每次超时或极慢

- 改为 `schedule` 夜间任务。  
- 缓存数据目录 / 使用 NVD API Key。  
- 不要与每个 PR 的编译绑死。

### 14.6 与官方上游 RuoYi 同步时 CI 冲突

- 使用 `upstream` 拉官方更新、`origin` 推自有仓库时，workflow 以**你的仓库**为准。  
- 合并上游后若破坏构建，以 CI 日志为准修复后再发 PR。

### 14.7 Docker 构建成功但 jar 无法启动

CI/Docker **构建成功**只说明编译打包通过。启动还依赖：

- 数据库已导入 `sql/`  
- Redis 可用  
- `application.yml` / `application-druid.yml` 中的连接与密钥  
- 端口与防火墙  

启动问题属于运行与部署，不单属 CI。

### 14.8 是否必须 CD？

不必。许多二次开发项目长期停在 **CI + 手工部署**。有稳定测试环境与发布节奏后再上 CD。

---

## 15. 快速检查清单

### 启用 CI 前

- [ ] 远程 `origin` 指向自有 GitHub 仓库且可 push  
- [ ] 了解默认分支名（`master` / `main`）  
- [ ] 已安装本机工具链 **或** Docker **或** 仅依赖 Actions  

### 最小 CI 就绪

- [ ] 存在 `.github/workflows/ci.yml`（或等价）  
- [ ] `on: push` / `pull_request` 配置正确  
- [ ] 后端 job：JDK 17 + `mvn package`（及 `test`）  
- [ ] 前端 job：Node + install + `build:prod`  
- [ ] 至少一次 Actions run 为绿色  
- [ ]（推荐）分支保护要求 status check  

### 工程增强

- [ ] 前端 lockfile 策略已文档化并执行  
- [ ] 存在真实自动化测试（SEC-013）  
- [ ] 依赖扫描报告可获取（SEC-012）  
- [ ] 密钥仅通过 Secrets/环境注入  
- [ ]（可选）CD 与回滚预案  

### 每次发版前

- [ ] 默认分支 CI 绿  
- [ ] 扫描高危项已评估  
- [ ] P1 安全项（密钥、Druid/Swagger、生成器）已按环境检查  
- [ ] 数据库迁移/SQL 与版本说明已准备  

---

## 16. 建议实施顺序（操作剧本）

```text
第 1 天
  ├─ 确认 origin 与 GitHub 仓库
  ├─ 添加 ci.yml（第 8 节最小模板）
  └─ push → Actions 首次跑通（允许先 skip 严苛 audit）

第 1 周
  ├─ 约定 lockfile 策略
  ├─ 修复 CI 红灯（依赖、内存、路径）
  └─（可选）打开 branch protection

第 2–4 周
  ├─ 补充登录/权限/上传等测试（SEC-013）
  ├─ 增加 nightly 依赖扫描（SEC-012）
  └─ 与安全整改 B1 并行：密钥与暴露面

之后
  └─ 需要时再上 Artifact 部署与 CD
```

---

## 17. 相关文档

| 文档 | 说明 |
| --- | --- |
| [docs/audit/README.md](../audit/README.md) | 审计总览与验证记录 |
| [docs/audit/01-architecture.md](../audit/01-architecture.md) | 模块与运行链路 |
| [docs/audit/03-security.md](../audit/03-security.md) | 风险台账（含 SEC-012、SEC-013） |
| [docs/audit/04-remediation-roadmap.md](../audit/04-remediation-roadmap.md) | 整改与工程批次 B3/B4 |
| [docs/guides/api-docs-swagger.md](./api-docs-swagger.md) | API 文档与在线调试 |
| 项目根 [README.md](../../README.md) | 官方功能与运行说明 |
| [CONTEXT.md](../../CONTEXT.md) | 稳定术语与系统边界 |

---

## 18. 修订记录

| 日期 | 说明 |
| --- | --- |
| 2026-07-22 | 初版：CI/CD 概念与作用、本仓库基线、本机/Docker/Actions 路径、阶段规划、workflow 模板、日常操作、CD 演进、FAQ 与检查清单 |
