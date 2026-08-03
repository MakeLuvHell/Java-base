# CI/CD 工程流水线说明与操作指南

本文说明本仓库的 CI 边界、目标流水线和日常 Pull Request 流程。详细测试设计见[自动化测试策略](./testing-strategy.md)；发布、部署和回滚约定见[发布、升级与回滚指南](./deployment-and-rollback.md)。

## 1. 文档状态与事实基线

### 1.1 截至 2026-08-03 的已核验事实

| 检查项 | 当前事实 | 对流水线的影响 |
| --- | --- | --- |
| 后端项目 | 根 POM 是 Maven 多模块项目, `java.version` 为 17 | 目标 CI 应使用 JDK 17 |
| 本机后端工具 | 当前环境找不到 `java` 和 `mvn` | 本次不能在本机验证 Maven 构建或测试 |
| Maven 固定方式 | 仓库没有 Maven Wrapper | 当前 Maven 版本不可复现 |
| 后端测试 | 仓库中 `src/test` 文件数为 0, POM 未检出 JUnit/Surefire/Testcontainers/JaCoCo 配置 | `mvn test` 即使退出 0 也不能视为已有测试门禁 |
| 前端项目 | `ruoyi-ui` 使用 Vue `2.6.12`、Vue CLI `4.4.6` | 目标 Node 版本必须先做兼容性验证 |
| 前端 scripts | 只有 `dev`、`build:prod`、`build:stage`、`preview` | 当前没有 `test` 或 `lint` 命令 |
| 前端 lockfile | 仓库中没有 npm/yarn/pnpm lockfile, `ruoyi-ui/.gitignore` 还忽略 `package-lock.json` | 当前不能使用 `npm ci` 作为可复现门禁 |
| 本机前端工具 | Node `v24.16.0`、npm `11.13.0` | 仅为当前机器观测值, 不等于项目目标版本 |
| GitHub Actions | `.github` 只有 `FUNDING.yml`, `.github/workflows` 中没有 workflow | 当前 push/PR 不会自动执行业务构建、测试或扫描 |
| Docker | 仓库未检出 Dockerfile 或 Compose 文件 | 当前没有仓库自带的容器构建/部署入口 |
| 本地辅助脚本 | `bin/package.bat` 跳过测试打包；`ry.sh` / `ry.bat` 启停固定 jar；前端批处理使用 `npm install` | 可作本地辅助，不能充当 CI 门禁或完整发布流程 |

以上是当前基线, 不是对未来落地结果的猜测。基线变化后应在 PR 中同时更新本节和修订记录。

### 1.2 当前能力与目标模板

| 范围 | 当前基线 | W11 目标 |
| --- | --- | --- |
| 构建工具 | JDK/Maven 在当前机器不可用, 无 Wrapper | JDK 17 + 固定 Maven/Wrapper |
| 前端安装 | 无 lockfile, 只能产生漂移安装 | 固定 Node/npm + 提交 lockfile + `npm ci` |
| 自动化测试 | 后端和前端均为零测试能力 | 真实单元、Web/安全、集成和 Vue 2 测试 |
| CI | 无 workflow | PR 自动运行 docs/backend/frontend/audit checks |
| 合并门禁 | 本文未核验远程分支保护设置 | required checks + review 后才能合并 |
| CD | 无已核验部署 workflow 或容器文件 | W12 再设计发布、部署、观察和回滚 |

本文第 5-8 节均为 **推荐目标模板**。在相关文件真正提交且干净环境验证前, 不得在交付记录中写“CI 已存在”“测试已通过”或“Docker 已支持”。

## 2. CI/CD 是什么

| 术语 | 含义 | 本仓库当前定位 |
| --- | --- | --- |
| CI | 每次变更自动构建、测试、检查和扫描 | W11 目标, 当前未落地 |
| Continuous Delivery | 产出可批准发布的版本化制品 | W12 及后续目标 |
| Continuous Deployment | 门禁通过后自动部署到目标环境 | 当前不做, 不能直接自动发生产 |
| Check | PR 上可成功或失败的具体 job | 稳定后设为 required check |
| Artifact | 测试报告、覆盖率、jar、前端构建产物或扫描报告 | 只有 workflow 配置上传后才存在 |
| Gate | 未通过就禁止合并或发布的规则 | 需要 workflow 与平台分支保护共同实现 |

CI 不能替代代码审查, 测试也不能替代生产配置核验。安全整改见 [安全审计台账](../audit/03-security.md) 和 [整改路线图](../audit/04-remediation-roadmap.md)。

## 3. 默认协作流程

默认流程固定为 feature branch + Pull Request + checks:

```text
同步默认分支
  -> 创建 feature/<topic>
  -> 本地运行适用检查
  -> push feature 分支
  -> 创建或更新 Pull Request
  -> required checks 全部通过
  -> Code Review 通过
  -> 合并默认分支
  -> 默认分支再次验证/产出候选制品
```

直接 push `master`/`main` 不是本仓库的日常开发流程。目标分支保护应限制直接 push; 紧急变更也应通过受审计的例外流程, 并补齐同等 checks 和复盘记录。

推荐命令:

```bash
git switch master
git pull --ff-only origin master
git switch -c feature/your-topic

# 修改后只暂存本任务文件
git status
# 将下面路径替换为本任务的实际文件
git add -- path/to/changed-file
git commit -m "type: describe the change"
git push -u origin feature/your-topic
```

随后在平台创建 Pull Request, 等待 checks 和 review。若仓库默认分支不是 `master`, 第一、二行应替换为平台显示的真实默认分支, workflow 的触发分支也必须同步修改。

## 4. 固定工具链策略

### 4.1 JDK 与 Maven

- JDK 目标为 17, 与根 POM 的 `java.version` 一致。
- 团队选择并验证一个受支持的 Maven 版本, 优先提交 Maven Wrapper 和校验配置。
- 本地与 CI 使用同一 Wrapper; 日志记录 `java -version` 和 `./mvnw -version`。
- 在 Wrapper 落地前, 运行器自带 Maven 只能用于探索, 不能称为版本已固定。

### 4.2 Node 与 npm

固定策略是: **团队先选择并验证一个受支持 Node LTS, 随后 pin 主版本**。验证内容至少包括 `npm ci`、Vue 2 单元测试、lint 和 `build:prod`。

当前 Node `v24.16.0`/npm `11.13.0` 只是当前机器的观测值, 不能直接等同于目标 Node LTS, 也不能因为 `package.json.engines` 范围宽松就跳过兼容性验证。

W11 落地后应只有一个版本来源, 例如:

- 根目录 `.node-version` 或 `.nvmrc` 固定已验证的 Node 主版本。
- GitHub Actions 通过 `node-version-file` 读取同一文件。
- npm 版本随所选 Node 固定; 如需单独固定, 使用团队确认的标准方式并记录原因。
- `package.json` 的 `engines` 与实际支持范围保持一致。

不要在不同文档、Dockerfile 和 workflow 中各写一个互相矛盾的 Node 版本。

### 4.3 前端 lockfile

W11 选择 npm 后应:

1. 停止忽略 `ruoyi-ui/package-lock.json`。
2. 在固定 Node/npm 环境生成并提交 lockfile。
3. 本地完整验证和 CI 都使用 `npm ci`。
4. `package.json` 与 lockfile 必须同一 PR 更新。
5. 大量无关依赖变化不得混入业务 PR。

lockfile 落地前, `npm ci` 和依赖 audit 模板均不可用, 这是应显式失败的前置条件, 不是用 `npm install` 静默兜底的理由。

## 5. 目标流水线设计

### 5.1 Job 划分

| job | 责任 | 目标门禁 |
| --- | --- | --- |
| `docs-check` | Markdown 链接、格式、迁移命名和 `git diff --check` | PR 必过 |
| `backend-test` | JDK 17、Maven Wrapper、JUnit 5、Testcontainers、覆盖率 | PR 必过, executed tests > 0 |
| `frontend-test-build` | 固定 Node、`npm ci`、lint、Vue 2 测试、生产构建 | PR 必过, executed tests > 0 |
| `dependency-audit` | 后端和前端依赖扫描、报告与例外校验 | 按批准的风险等级阻断 |
| `package` | 基于已验证 commit 生成版本化 jar/dist 或镜像 | 合并后或 tag 触发 |

详细测试金字塔、JUnit/Surefire 约定、Testcontainers、前端用例和零测试保护统一见 [testing-strategy.md](./testing-strategy.md)。CI 文档只定义如何调度 W11 落地后的测试命令, 不重复维护测试清单。

### 5.2 Job 依赖

```text
docs-check -----------+
backend-test ---------+--> required checks --> merge
frontend-test-build --+
dependency-audit -----+

merge/tag + required checks --> package
package --> W12 的发布审批/部署/回滚流程
```

后端和前端 job 可并行。`package` 不应通过重新跳过测试来制造一个未经验证的制品, 应绑定已经通过 checks 的 commit SHA。

### 5.3 触发策略

- `pull_request`: 针对默认分支的每个 PR 运行必要 checks。
- `push`: 合并到默认分支后再次验证, 可触发候选制品。
- `workflow_dispatch`: 仅用于受控重跑或维护任务, 不能绕过分支保护。
- `schedule`: 适合较慢的完整依赖扫描, 但 PR 仍需执行团队规定的快速阻断检查。
- 路径过滤必须经过评审。修改共享 POM、权限、数据库脚本或前端公共代码时不能跳过相关 job。

## 6. 本地命令契约

> **模板状态:** 以下命令只描述 W11 完成后的统一入口。当前环境缺少 JDK/Maven, 仓库也缺少 Wrapper、测试、lockfile 和前端 test/lint scripts, 因而本文不声称这些命令现在可以运行。

### 6.1 工具版本检查

```bash
java -version
./mvnw -version
node -v
npm -v
```

预期不是“任意能输出版本”, 而是与团队已提交的工具链文件和 CI 日志一致。

### 6.2 后端目标命令

```bash
# 快速反馈: 单元和 Web 切片
./mvnw -B test

# 完整门禁: 集成测试、报告和验证
./mvnw -B verify
```

完整合并门禁使用 `verify`, 并验证 Surefire/Failsafe 报告中的 executed test 数大于 0。不能以 `-DskipTests` 作为合并门禁命令。

### 6.3 前端目标命令

```bash
cd ruoyi-ui
npm ci
npm run lint
npm run test:unit:ci
npm run build:prod
```

这些 script 名是 W11 的推荐契约。落地时必须先写入 `package.json` 并在固定 Node LTS 上验证, 不能只把不存在的命令写进 workflow。

### 6.4 容器构建沙箱

仓库当前没有 Dockerfile 或 Compose。若团队在 W11 只用官方工具镜像提供构建沙箱, 这仍是外部执行方式, 不代表应用已经容器化。目标命令示例:

```bash
# 仅在 Wrapper 已提交、镜像版本已固定后使用
docker run --rm \
  -v "$PWD":/workspace \
  -w /workspace \
  "eclipse-temurin:${TEAM_JDK17_IMAGE_TAG:?set TEAM_JDK17_IMAGE_TAG}" \
  ./mvnw -B verify

# 仅在 Node 版本和 lockfile 已固定后使用
docker run --rm \
  -v "$PWD/ruoyi-ui":/workspace \
  -w /workspace \
  "node:${TEAM_NODE_LTS_IMAGE_TAG:?set TEAM_NODE_LTS_IMAGE_TAG}" \
  sh -c 'npm ci && npm run lint && npm run test:unit:ci && npm run build:prod'
```

`TEAM_JDK17_IMAGE_TAG` 和 `TEAM_NODE_LTS_IMAGE_TAG` 必须在执行前设置为团队验证过的非浮动 tag; 未设置时 shell 会立即报错。整站 Docker/Compose、数据库迁移和运行健康检查属于 W12, 不由这个构建沙箱示例证明。

## 7. GitHub Actions 目标模板

### 7.1 使用前置条件

下列模板只有在这些 W11 交付物已经存在时才可启用:

- `.mvn/wrapper/**` 和可执行的 `mvnw`。
- 后端真实测试、JUnit 5/Surefire/Failsafe 配置和报告路径。
- `.node-version` 中已验证的 Node LTS 主版本。
- `ruoyi-ui/package-lock.json`。
- `lint` 和 `test:unit:ci` scripts 以及真实前端测试。
- 可执行的 `scripts/ci/verify-test-counts.sh`，能解析后端与前端报告并阻止零测试空跑。

截至基线日期, 上述前置条件均未完整具备。模板不是仓库现有 workflow。

### 7.2 最小 PR 模板

目标文件位置为 `.github/workflows/ci.yml`。以下以 `master` 为当前任务约定的默认分支名; 启用前必须在 GitHub Settings 核实。

```yaml
name: CI

on:
  pull_request:
    branches: [master]
  push:
    branches: [master]
  workflow_dispatch:

permissions:
  contents: read

concurrency:
  group: ci-${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  backend-test:
    name: Backend test
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

      - name: Verify target prerequisites
        shell: bash
        run: |
          test -x ./mvnw
          find . -type f \
            \( -path '*/src/test/java/*Test.java' -o -path '*/src/test/java/*IT.java' \) \
            -print -quit | grep -q .

      - name: Test and verify
        run: ./mvnw -B verify

      - name: Verify executed backend tests
        run: ./scripts/ci/verify-test-counts.sh backend

      - name: Upload backend reports
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: backend-test-reports
          path: |
            **/target/surefire-reports/**
            **/target/failsafe-reports/**
            **/target/site/jacoco/**
          if-no-files-found: error

  frontend-test-build:
    name: Frontend test and build
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ruoyi-ui
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Verify target prerequisites
        shell: bash
        run: |
          test -f ../.node-version
          test -f package-lock.json

      - name: Set up Node
        uses: actions/setup-node@v4
        with:
          node-version-file: .node-version
          cache: npm
          cache-dependency-path: ruoyi-ui/package-lock.json

      - name: Verify target scripts and tests
        shell: bash
        run: |
          node -e "const s=require('./package.json').scripts||{}; process.exit(s.lint&&s['test:unit:ci']?0:1)"
          find . -type f \
            \( -name '*.spec.js' -o -name '*.test.js' \) \
            -print -quit | grep -q .

      - name: Install locked dependencies
        run: npm ci

      - name: Lint
        run: npm run lint

      - name: Unit test
        run: npm run test:unit:ci

      - name: Verify executed frontend tests
        run: ../scripts/ci/verify-test-counts.sh frontend

      - name: Build production bundle
        run: npm run build:prod

      - name: Upload frontend reports
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: frontend-test-reports
          path: ruoyi-ui/coverage/**
          if-no-files-found: error
```

注意事项:

- `actions/setup-node` 的 `node-version-file` 路径相对仓库根, 即使后续 `run` 默认目录为 `ruoyi-ui` 也仍写 `.node-version`。
- 源文件检查只能防止测试文件为 0。模板中的 `verify-test-counts.sh` 必须解析实际报告并要求 executed test 数大于 0；脚本契约见[零测试空跑保护](./testing-strategy.md#9-防止零测试空跑)。
- `if-no-files-found: error` 是目标门禁的一部分。报告路径改变时应更新模板, 不能改为忽略来隐藏配置错误。
- 先在 feature branch 的 PR 验证 workflow。首次引入 checks 后, 再把稳定 job 设为 required。

### 7.3 文档与依赖扫描

`docs-check` 应调用团队选定并固定的 Markdown 链接检查器, 同时执行迁移命名检查和差异空白检查。不要在 workflow 临时下载一个未固定版本的任意脚本。

依赖扫描建议独立 job, 在 lockfile 落地后执行前端命令:

```bash
cd ruoyi-ui
npm ci
npm audit --omit=dev --audit-level=high
```

后端扫描工具、CVE 阻断等级和临时例外格式由安全评审确定。允许例外时必须记录漏洞、影响、负责人和到期日, 不能用无条件成功掩盖结果。

## 8. 分支保护与首次启用

### 8.1 首次引入 workflow

1. 在 feature branch 添加工具链、测试和 workflow。
2. 创建 PR, 由维护者检查 workflow 权限、第三方 action 来源和命令。
3. 在 PR 上反复验证真实测试数、失败报告和构建结果。
4. 合并首个 workflow 后, 在默认分支上确认一次完整 run。
5. 将稳定 job 名配置为 required checks。
6. 开启“Require a pull request before merging”和至少一名 reviewer。
7. 限制绕过规则和直接 push 默认分支的权限。

首次 workflow PR 在 required check 尚不存在时需要维护者审查完成引导, 但这不是长期关闭门禁的理由。

### 8.2 Required checks

GitHub Settings 中至少要求:

- PR 合并前通过 `Backend test`。
- PR 合并前通过 `Frontend test and build`。
- `docs-check` 和已批准的依赖扫描按团队规则设为 required。
- 新提交到 PR 后撤销过期批准或重新要求 checks。
- 对话解决后才允许合并。
- 管理员是否允许绕过应有书面策略和审计记录。

job `name` 改名会影响分支保护绑定。重命名前先安排平台配置迁移, 避免出现永远等待的旧 check。

## 9. 制品、缓存和密钥

### 9.1 制品

- 测试失败时仍上传 Surefire/Failsafe/Jest/JaCoCo 报告。
- jar、dist 或镜像必须关联 commit SHA 和版本, 不能只有 `latest`。
- 构建制品与部署凭据分离; PR workflow 不持有生产部署权限。
- Artifact 保留期和可见性由仓库敏感度决定。

### 9.2 缓存

- Maven 和 npm 缓存只用于提速, 不能替代 lockfile 或固定版本。
- 缓存 key 至少随 POM、lockfile 和工具版本变化。
- 排查依赖问题时从空缓存重跑一次, 证明结果可复现。
- 不缓存工作区中的密钥、测试数据库文件或用户上传内容。

### 9.3 密钥与权限

- workflow 顶层从最小 `permissions` 开始, job 需要额外权限时单独说明。
- NVD Key、镜像仓库口令和部署凭据只能放在平台 Secrets/Environment 中。
- 不在日志打印 token、密码、完整 `Authorization` 或数据库连接串。
- 来自 fork 的 PR 默认不能获取敏感 secrets; 不使用高权限事件执行未审查代码。
- 第三方 action 固定到团队批准的版本或 commit, 定期审查更新。

## 10. 失败排查

### 10.1 没有触发 workflow

按顺序检查:

1. `.github/workflows/*.yml` 是否真实存在于远程分支。
2. YAML 是否能被平台解析。
3. `pull_request.branches` 是否匹配目标默认分支。
4. Actions 是否在仓库 Settings 中启用。
5. PR 是否来自受路径过滤影响的变更。
6. 查看的是 `origin` 对应仓库, 不是只查看 `upstream`。

当前基线没有 workflow, 所以“没有 Actions 记录”是预期现象, 不是运行故障。

### 10.2 后端失败

| 现象 | 优先检查 |
| --- | --- |
| `mvnw` 不存在或无执行权限 | Wrapper 是否提交, executable bit 是否保留 |
| 编译版本不一致 | `java -version`、POM `java.version`、setup-java 配置 |
| BUILD SUCCESS 但零测试 | Surefire/Failsafe 版本、命名、报告 executed count |
| Testcontainers 超时 | Runner 容器能力、镜像版本、等待策略、容器日志 |
| 只在 CI 失败 | 时区、locale、共享状态、未提交资源、缓存和外部网络 |

### 10.3 前端失败

| 现象 | 优先检查 |
| --- | --- |
| `npm ci` 报 lockfile 错误 | lockfile 是否提交, 是否与 `package.json` 同版本生成 |
| Node 不兼容 | `.node-version`、setup-node 日志、Vue CLI 4 兼容性记录 |
| script 不存在 | `package.json.scripts`, 不要临时改 workflow 跳过 |
| 测试无用例 | Jest 配置、文件命名、是否误加允许空套件选项 |
| 构建内存不足 | 先确认泄漏/依赖问题, 再评估 Runner 资源和受控 `NODE_OPTIONS` |

### 10.4 通用排查顺序

1. 打开失败 job, 定位第一条根因。
2. 记录 commit SHA 和实际工具版本。
3. 用第 6 节同一命令在固定环境复现。
4. 必要时从空缓存、空 `node_modules` 和空测试数据库重跑。
5. 修复后提交到同一 feature branch, 让 PR checks 重新运行。
6. 不通过跳过测试、降低覆盖率或允许失败来“修绿”。

## 11. 分阶段落地

| 阶段 | 目标 | 完成证据 |
| --- | --- | --- |
| E0 基线 | 记录工具、测试数、lockfile 和 workflow 状态 | 本文第 1 节与 PR 证据一致 |
| E1 工具链 | JDK/Maven/Node/npm 可复现 | Wrapper、Node 版本文件、lockfile, 干净环境日志 |
| E2 真实测试 | 后端/前端有真实断言和隔离依赖 | 报告 executed > 0, 故意破坏会失败 |
| E3 PR CI | docs/backend/frontend jobs 自动运行 | feature PR checks 链接与失败报告 |
| E4 门禁 | required checks 和 review 生效 | 失败 PR 无法合并 |
| E5 扫描 | 报告、阻断等级和例外流程可审计 | 扫描报告及未过期例外 |
| E6 制品 | 已验证 SHA 生成版本化制品 | Artifact/镜像元数据与 commit 对应 |
| E7 发布 | W12 设计并演练部署和回滚 | 独立 runbook 和隔离环境演练记录 |

W11 是 E1-E5 的目标任务, 不是现有能力描述。发布前必须先稳定 CI, 不把自动生产部署塞进首个 workflow。

## 12. 发布与回滚边界

本文不提供生产发布、数据库迁移、健康检查、备份或回滚命令。相关目标约定见[发布、升级与回滚指南](./deployment-and-rollback.md)，并按 [W12 部署与生产就绪](../intern/tasks/W12-deployment-production-readiness.md) 在隔离测试环境演练。

CI 在该边界只负责:

- 证明指定 commit 通过已定义门禁。
- 生成可追溯、版本化的候选制品。
- 保存测试、覆盖率和扫描证据。
- 把制品交给需要审批的发布流程。

没有发布 runbook、恢复点、权限隔离和回滚演练时, CI 成功不能解释为“可以自动部署生产”。

## 13. Definition of Done

### 最小 CI

- [ ] 第 1 节事实基线已随实施结果更新。
- [ ] JDK 17 和 Maven 版本固定, Wrapper 可在干净环境运行。
- [ ] 团队先验证受支持 Node LTS, 再 pin 主版本并让 CI 读取同一来源。
- [ ] 前端 lockfile 已提交, `npm ci` 可重复安装。
- [ ] 后端和前端均有真实测试, executed test 数大于 0。
- [ ] `lint`、测试和 `build:prod` scripts 在固定前端环境通过。
- [ ] `.github/workflows/ci.yml` 真实存在, feature PR 能自动触发。
- [ ] 故意破坏后端规则或前端构建时对应 check 失败。
- [ ] 测试失败时报告仍可查看, 且日志没有密钥。

### 合并门禁

- [ ] 默认流程是 feature branch + PR, 不依赖直接 push 默认分支。
- [ ] required checks 与当前 job 名一致。
- [ ] 至少一名 reviewer, 绕过权限有明确限制。
- [ ] 空测试套件、缺失报告或缺失 lockfile 会失败。
- [ ] 依赖扫描阻断等级和临时例外有负责人、到期日。
- [ ] 缓存清空后仍能重复通过。
- [ ] 文档没有把目标模板描述成现有 workflow、Docker 或测试能力。

### 交付边界

- [ ] 制品关联 commit SHA 和版本。
- [ ] PR workflow 不持有生产凭据。
- [ ] 发布/回滚步骤只在独立 runbook 中维护。
- [ ] W12 未完成前不启用自动生产部署。

## 14. 相关文档

| 文档 | 说明 |
| --- | --- |
| [testing-strategy.md](./testing-strategy.md) | 测试金字塔、JUnit 5、Testcontainers、Vue 2、覆盖率和零测试保护 |
| [W11-testing-and-ci.md](../intern/tasks/W11-testing-and-ci.md) | 自动化测试、可复现构建和 CI 门禁任务书 |
| [W12-deployment-production-readiness.md](../intern/tasks/W12-deployment-production-readiness.md) | 容器化、生产就绪和恢复演练任务书 |
| [deployment-and-rollback.md](./deployment-and-rollback.md) | 已成文的发布与回滚目标约定；当前仓库部署能力仍未落地 |
| [api-docs-swagger.md](./api-docs-swagger.md) | API 文档与在线调试, 不能替代自动化测试 |
| [03-security.md](../audit/03-security.md) | SEC-012 供应链和 SEC-013 自动化测试风险 |
| [04-remediation-roadmap.md](../audit/04-remediation-roadmap.md) | 整改与工程批次 |
| [知识库首页](../README.md) | 当前能力、审计、工程指南与培训导航 |

## 15. 修订记录

| 日期 | 说明 |
| --- | --- |
| 2026-07-22 | 初版: CI/CD 概念、本机/Docker/Actions 路径和阶段规划 |
| 2026-08-03 | 按已核验仓库事实重构: 区分当前基线与 W11 目标, 固定 feature branch + PR + checks 流程, 明确 Node LTS 验证/pin 策略, 将测试与发布/回滚分别交给专项指南 |
