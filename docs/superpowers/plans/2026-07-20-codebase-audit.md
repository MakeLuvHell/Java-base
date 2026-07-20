# RuoYi-Vue Codebase Audit Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Produce a traceable Chinese audit set covering the repository architecture, frontend UI and color system, security findings, and a prioritized remediation roadmap without changing business code.

**Architecture:** Treat the repository as three audit surfaces: the Maven backend and runtime boundaries, the Vue 2 frontend and design tokens, and cross-cutting security controls. Record stable vocabulary in `CONTEXT.md`; keep evidence and analysis in four focused files under `docs/audit/`, with `README.md` as the baseline and navigation entry.

**Tech Stack:** Java 17, Spring Boot 4, Spring Security, MyBatis, Redis, JWT, Maven, Vue 2, Vue Router 3, Vuex, Element UI, Vue CLI, SCSS, Markdown, Mermaid.

---

## File Map

- Create `CONTEXT.md`: stable glossary for modules, identity, authorization, routing, storage, and risk terminology.
- Create `docs/audit/README.md`: audit baseline, scope, method, limitations, verification summary, executive findings, and navigation.
- Create `docs/audit/01-architecture.md`: module dependencies, runtime components, startup and request flow, login/token flow, dynamic route flow, data access, file flow, and deployment boundary.
- Create `docs/audit/02-frontend-ui.md`: frontend structure, layout, page patterns, component reuse, color tokens, typography and spacing, theme behavior, responsive behavior, and accessibility observations.
- Create `docs/audit/03-security.md`: risk register plus evidence-backed analysis for authentication, authorization, input/output, files, data access, operations, configuration, logging, and dependencies.
- Create `docs/audit/04-remediation-roadmap.md`: risk-linked P0-P3 remediation order, affected files, compatibility impact, and regression checks.
- Reference `docs/superpowers/specs/2026-07-20-codebase-audit-design.md`: approved scope and acceptance criteria; do not modify unless execution reveals a contradiction in the approved design.

## Task 1: Capture Baseline and Stable Vocabulary

**Files:**
- Create: `CONTEXT.md`
- Create: `docs/audit/README.md`
- Reference: `README.md`
- Reference: `pom.xml`
- Reference: `ruoyi-ui/package.json`
- Reference: `ruoyi-admin/src/main/resources/application.yml`
- Reference: `ruoyi-admin/src/main/resources/application-druid.yml`

- [ ] **Step 1: Record repository and toolchain baseline**

Run:

```bash
git rev-parse HEAD
git status --short --branch
java -version
mvn -version
node --version
npm --version
```

Expected: the Git revision and branch are printed; Java is compatible with the POM's Java 17 target; Maven, Node, and npm availability are recorded verbatim. A missing tool is a documented limitation, not silently omitted.

- [ ] **Step 2: Inventory modules and source surfaces**

Run:

```bash
rg '<module>|<spring-boot.version>|<java.version>' pom.xml
find ruoyi-admin ruoyi-common ruoyi-framework ruoyi-generator ruoyi-quartz ruoyi-system -path '*/src/main/*' -type f | sort
find ruoyi-ui/src -type f | sort
find . -path '*/src/test/*' -type f | sort
```

Expected: six Maven modules are confirmed, backend and frontend source inventories are available, and the presence or absence of repository tests is explicitly established.

- [ ] **Step 3: Write the stable glossary**

Write `CONTEXT.md` with only these stable categories:

```markdown
# 项目上下文

## 系统边界
## 后端模块
## 前端边界
## 身份与权限术语
## 数据与运行时术语
## 审计术语
```

Define each term from verified code. Include `ruoyi-admin`, `ruoyi-framework`, `ruoyi-system`, `ruoyi-common`, `ruoyi-quartz`, `ruoyi-generator`, `ruoyi-ui`, `LoginUser`, permissions, roles, data scope, dynamic routes, Redis token state, P0-P3, and the four finding states. Do not include mutable implementation notes, findings, recommendations, passwords, URLs containing credentials, or line-number evidence.

- [ ] **Step 4: Create the audit entry document**

Write `docs/audit/README.md` with these exact sections:

```markdown
# RuoYi-Vue 代码库审计

## 执行摘要
## 审计基线
## 范围
## 方法与证据等级
## 结论概览
## 文档导航
## 验证记录
## 范围限制
```

At this stage, fill the verified baseline, scope, evidence categories, and navigation. Populate the conclusion and verification sections only with facts already established; expand them in Tasks 5 and 6 after risk and build checks finish.

- [ ] **Step 5: Verify glossary and baseline boundaries**

Run:

```bash
rg -n 'password:|username:|secret:|token:' CONTEXT.md docs/audit/README.md
rg -n '^## ' CONTEXT.md docs/audit/README.md
git diff --check
```

Expected: the secret-pattern search returns no copied configuration values; all required headings are present; `git diff --check` exits successfully.

- [ ] **Step 6: Commit the baseline documents**

```bash
git add CONTEXT.md docs/audit/README.md
git commit -m "docs: establish audit baseline and glossary"
```

## Task 2: Audit Backend Architecture and Runtime Flows

**Files:**
- Create: `docs/audit/01-architecture.md`
- Modify: `docs/audit/README.md`
- Reference: `pom.xml`
- Reference: `ruoyi-admin/pom.xml`
- Reference: `ruoyi-framework/pom.xml`
- Reference: `ruoyi-system/pom.xml`
- Reference: `ruoyi-common/pom.xml`
- Reference: `ruoyi-quartz/pom.xml`
- Reference: `ruoyi-generator/pom.xml`
- Reference: `ruoyi-admin/src/main/java/com/ruoyi/RuoYiApplication.java`
- Reference: `ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysLoginController.java`
- Reference: `ruoyi-framework/src/main/java/com/ruoyi/framework/config/SecurityConfig.java`
- Reference: `ruoyi-framework/src/main/java/com/ruoyi/framework/config/ResourcesConfig.java`
- Reference: `ruoyi-framework/src/main/java/com/ruoyi/framework/security/filter/JwtAuthenticationTokenFilter.java`
- Reference: `ruoyi-framework/src/main/java/com/ruoyi/framework/web/exception/GlobalExceptionHandler.java`
- Reference: `ruoyi-framework/src/main/java/com/ruoyi/framework/web/service/PermissionService.java`
- Reference: `ruoyi-framework/src/main/java/com/ruoyi/framework/web/service/SysLoginService.java`
- Reference: `ruoyi-framework/src/main/java/com/ruoyi/framework/web/service/SysPermissionService.java`
- Reference: `ruoyi-framework/src/main/java/com/ruoyi/framework/web/service/TokenService.java`
- Reference: `ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysMenuServiceImpl.java`
- Reference: `ruoyi-framework/src/main/java/com/ruoyi/framework/aspectj/DataScopeAspect.java`
- Reference: `ruoyi-admin/src/main/java/com/ruoyi/web/controller/common/CommonController.java`
- Reference: `ruoyi-quartz/src/main/java/com/ruoyi/quartz/util/JobInvokeUtil.java`
- Reference: `ruoyi-generator/src/main/java/com/ruoyi/generator/controller/GenController.java`

- [ ] **Step 1: Resolve Maven module dependencies**

Run:

```bash
mvn -DskipTests dependency:tree -DoutputType=text
rg -n '<artifactId>ruoyi-(admin|framework|system|common|quartz|generator)</artifactId>' pom.xml ruoyi-*/pom.xml
```

Expected: the effective dependency direction is captured and reconciled with direct POM declarations. Optional, runtime, and transitive boundaries are distinguished in the notes.

- [ ] **Step 2: Trace startup, request, authentication, and authorization flows**

Read the listed entry and security files together with `SysLoginController`, `SysPermissionService`, `PermissionService`, `ResourcesConfig`, and `GlobalExceptionHandler`. Record the initiating endpoint, state transitions, Redis keys or objects, security context creation, method authorization, error handling, and terminal operation for each flow.

Run:

```bash
rg -n '@SpringBootApplication|@EnableMethodSecurity|SecurityFilterChain|authorizeHttpRequests|permitAll|authenticated' ruoyi-admin/src/main/java ruoyi-framework/src/main/java
rg -n 'createToken|verifyToken|refreshToken|setLoginUser|getLoginUser|deleteLoginUser' ruoyi-admin/src/main/java ruoyi-framework/src/main/java
rg -n '@PreAuthorize|@DataScope' ruoyi-admin/src/main/java ruoyi-system/src/main/java ruoyi-quartz/src/main/java ruoyi-generator/src/main/java
```

Expected: evidence exists for anonymous routes, authenticated routes, JWT handling, method permissions, and data-scope application.

- [ ] **Step 3: Trace dynamic menus, persistence, files, jobs, and generator flows**

Read backend menu services and VOs together with frontend route consumers; trace Mapper XML for the selected system flows; trace common upload/download helpers; trace Quartz invocation validation and generator preview/download behavior.

Run:

```bash
rg -n 'buildMenus|buildMenuTree|RouterVo|MetaVo' ruoyi-admin/src/main/java ruoyi-system/src/main/java
rg -n '\$\{|#\{' ruoyi-system/src/main/resources/mapper ruoyi-quartz/src/main/resources/mapper ruoyi-generator/src/main/resources/mapper
rg -n 'upload|download|deleteFile|checkAllowDownload|invokeMethod|isValidClassName|generatorCode' ruoyi-admin/src/main/java ruoyi-common/src/main/java ruoyi-quartz/src/main/java ruoyi-generator/src/main/java
```

Expected: each cross-module flow has entry, validation, service, data/side-effect, and response evidence; `${...}` SQL sites are marked for security review rather than assumed safe.

- [ ] **Step 4: Write the architecture document**

Write `docs/audit/01-architecture.md` with these exact sections:

```markdown
# 系统架构与运行链路

## 系统全景
## Maven 模块与依赖
## 后端分层职责
## 前端与后端边界
## 启动与配置装配
## 请求与异常链路
## 登录、令牌与退出链路
## 菜单、路由与按钮权限链路
## 数据访问与数据权限
## 文件、任务与代码生成链路
## 数据存储与外部依赖
## 部署边界
## 架构观察
```

Include at least one Mermaid module diagram and sequence diagrams for login and dynamic routing. Every non-trivial behavior must cite repository-relative paths with exact line numbers.

- [ ] **Step 5: Verify architecture completeness and commit**

Run:

```bash
rg -n '^## ' docs/audit/01-architecture.md
rg -n '```mermaid|ruoyi-admin|ruoyi-framework|ruoyi-system|ruoyi-common|ruoyi-quartz|ruoyi-generator|ruoyi-ui' docs/audit/01-architecture.md
git diff --check
```

Expected: all required headings, both backend and frontend boundaries, every Maven module, and Mermaid diagrams are present; whitespace validation passes.

```bash
git add docs/audit/01-architecture.md docs/audit/README.md
git commit -m "docs: document system architecture and flows"
```

## Task 3: Audit Frontend Structure, UI, and Color System

**Files:**
- Create: `docs/audit/02-frontend-ui.md`
- Modify: `docs/audit/README.md`
- Reference: `ruoyi-ui/src/main.js`
- Reference: `ruoyi-ui/src/permission.js`
- Reference: `ruoyi-ui/src/router/index.js`
- Reference: `ruoyi-ui/src/store/modules/permission.js`
- Reference: `ruoyi-ui/src/settings.js`
- Reference: `ruoyi-ui/src/layout/index.vue`
- Reference: `ruoyi-ui/src/layout/components/Navbar.vue`
- Reference: `ruoyi-ui/src/layout/components/Sidebar/index.vue`
- Reference: `ruoyi-ui/src/layout/components/TagsView/index.vue`
- Reference: `ruoyi-ui/src/assets/styles/variables.scss`
- Reference: `ruoyi-ui/src/assets/styles/element-variables.scss`
- Reference: `ruoyi-ui/src/assets/styles/sidebar.scss`
- Reference: `ruoyi-ui/src/assets/styles/index.scss`
- Reference: `ruoyi-ui/src/assets/styles/ruoyi.scss`
- Reference: `ruoyi-ui/src/views/login.vue`
- Reference: `ruoyi-ui/src/views/system/user/index.vue`
- Reference: `ruoyi-ui/src/components/FileUpload/index.vue`
- Reference: `ruoyi-ui/src/components/ImageUpload/index.vue`
- Reference: `ruoyi-ui/src/components/Editor/index.vue`

- [ ] **Step 1: Map frontend boot, routing, state, layout, and page patterns**

Run:

```bash
rg -n '^import|Vue\.use|new Vue|router.beforeEach|addRoutes|filterAsyncRouter|constantRoutes|dynamicRoutes' ruoyi-ui/src/main.js ruoyi-ui/src/permission.js ruoyi-ui/src/router/index.js ruoyi-ui/src/store/modules/permission.js
rg -n '<el-(form|table|dialog|pagination|menu|tabs)|app-container|fixed-header|sidebar' ruoyi-ui/src/views ruoyi-ui/src/layout ruoyi-ui/src/components
```

Expected: the boot sequence, route guard, dynamic route installation, shell layout, and representative CRUD composition are established with code locations.

- [ ] **Step 2: Extract actual design tokens and style ownership**

Run:

```bash
rg -n --glob '*.{scss,vue,css}' '#[0-9A-Fa-f]{3,8}|rgba?\(|hsla?\(|\$[A-Za-z][A-Za-z0-9_-]*' ruoyi-ui/src ruoyi-ui/public/styles/theme-chalk
rg -n --glob '*.{scss,vue}' 'font-size|line-height|border-radius|box-shadow|padding|margin|width:|height:' ruoyi-ui/src/assets/styles ruoyi-ui/src/layout ruoyi-ui/src/views/login.vue
rg -n 'theme|sideTheme|themeColor|dark|light|showSettings|topNav|tagsView|fixedHeader|sidebarLogo' ruoyi-ui/src
```

Expected: global variables are separated from one-off component colors, Element UI overrides are identified, and theme settings are traced to their actual consumers.

- [ ] **Step 3: Assess responsiveness and accessibility from implementation evidence**

Run:

```bash
rg -n --glob '*.{vue,scss,css}' '@media|aria-|role=|tabindex|:focus|outline|alt=|label' ruoyi-ui/src
rg -n --glob '*.vue' '@click=.*(div|span)|<div[^>]*@click|<span[^>]*@click' ruoyi-ui/src
```

Expected: responsive breakpoints, keyboard/focus support, image alternatives, form labeling, and clickable non-semantic elements are inventoried. Findings are described as implementation observations unless user impact is directly demonstrable.

- [ ] **Step 4: Write the frontend UI document**

Write `docs/audit/02-frontend-ui.md` with these exact sections:

```markdown
# 前端结构、UI 与配色

## 前端启动与依赖
## 信息架构与路由
## 应用框架布局
## 页面与组件模式
## 样式加载与覆盖关系
## 色彩系统
## 字体、尺寸、间距与层级
## 主题能力
## 响应式行为
## 可访问性审计
## UI 一致性观察
## 维护建议
```

The color section must contain tables with hexadecimal or functional color values, usage, ownership file, and scope. Separate canonical tokens from duplicated or one-off values. Cite exact lines for layout dimensions, tokens, theme switches, and each stated gap.

- [ ] **Step 5: Verify UI evidence and commit**

Run:

```bash
rg -n '^## ' docs/audit/02-frontend-ui.md
rg -n '#[0-9A-Fa-f]{3,8}|rgb|主色|文字色|背景色|边框色|成功|警告|危险|信息' docs/audit/02-frontend-ui.md
rg -n '响应式|可访问性|键盘|焦点|对比度' docs/audit/02-frontend-ui.md
git diff --check
```

Expected: required UI sections, concrete color values, status colors, and accessibility/responsive analysis are present; whitespace validation passes.

```bash
git add docs/audit/02-frontend-ui.md docs/audit/README.md
git commit -m "docs: audit frontend UI and color system"
```

## Task 4: Audit Security Controls and Sensitive Operations

**Files:**
- Create: `docs/audit/03-security.md`
- Modify: `docs/audit/README.md`
- Reference: `ruoyi-framework/src/main/java/com/ruoyi/framework/config/SecurityConfig.java`
- Reference: `ruoyi-framework/src/main/java/com/ruoyi/framework/security/filter/JwtAuthenticationTokenFilter.java`
- Reference: `ruoyi-framework/src/main/java/com/ruoyi/framework/web/service/SysLoginService.java`
- Reference: `ruoyi-framework/src/main/java/com/ruoyi/framework/web/service/TokenService.java`
- Reference: `ruoyi-framework/src/main/java/com/ruoyi/framework/aspectj/DataScopeAspect.java`
- Reference: `ruoyi-common/src/main/java/com/ruoyi/common/filter/XssFilter.java`
- Reference: `ruoyi-common/src/main/java/com/ruoyi/common/utils/file/FileUploadUtils.java`
- Reference: `ruoyi-common/src/main/java/com/ruoyi/common/utils/file/FileUtils.java`
- Reference: `ruoyi-common/src/main/java/com/ruoyi/common/utils/sql/SqlUtil.java`
- Reference: `ruoyi-quartz/src/main/java/com/ruoyi/quartz/util/JobInvokeUtil.java`
- Reference: `ruoyi-generator/src/main/java/com/ruoyi/generator/service/GenTableServiceImpl.java`
- Reference: `ruoyi-admin/src/main/resources/application.yml`
- Reference: `ruoyi-admin/src/main/resources/application-druid.yml`
- Reference: `ruoyi-admin/src/main/resources/logback.xml`
- Reference: `sql/ry_20260417.sql`

- [ ] **Step 1: Build an endpoint and authorization inventory**

Run:

```bash
rg -n '@(Get|Post|Put|Delete|Patch|Request)Mapping|@PreAuthorize|@Anonymous' ruoyi-admin/src/main/java ruoyi-quartz/src/main/java ruoyi-generator/src/main/java
rg -n 'permitAll|anonymous|authenticated|hasPermi|hasRole|@DataScope' ruoyi-framework/src/main/java ruoyi-admin/src/main/java ruoyi-system/src/main/java ruoyi-quartz/src/main/java ruoyi-generator/src/main/java
```

Expected: each sensitive endpoint can be checked against URL security, method permission, and data scope. Missing annotations are traced through class-level or filter-level controls before being classified.

- [ ] **Step 2: Inspect injection, file, network, expression, and reflection sinks**

Run:

```bash
rg -n '\$\{|Runtime\.getRuntime|ProcessBuilder|Class\.forName|Method\.invoke|new URL|openConnection|RestTemplate|WebClient|ObjectInputStream|readObject|ScriptEngine|SpelExpressionParser' --glob '*.{java,xml}' .
rg -n 'MultipartFile|transferTo|getOriginalFilename|download|deleteFile|FileInputStream|FileOutputStream|Paths\.get|new File' --glob '*.java' .
rg -n 'HtmlUtils|escape|unescape|Xss|innerHTML|v-html|dangerouslyUseHTMLString' ruoyi-* --glob '*.{java,js,vue,yml}'
```

Expected: every sink has its input origin and validation traced. Safe constant or allowlisted uses are documented as controls; user-controlled or configuration-controlled uses proceed to the risk register.

- [ ] **Step 3: Inspect secrets, defaults, logging, and operational exposure without echoing secret values into reports**

Run:

```bash
rg -l -i '(password|passwd|secret|token|private.?key|access.?key)[[:space:]]*[:=]' --glob '!docs/**' --glob '!**/target/**' .
rg -n 'druid|swagger|springdoc|profile|actuator|monitor|redis|datasource|logging|logback' ruoyi-admin/src/main/resources ruoyi-admin/src/main/java ruoyi-framework/src/main/java
rg -n 'logger\.|log\.|recordLogininfor|insertOperlog|exception\.getMessage|stackTrace' --glob '*.java' ruoyi-*
```

Expected: only filenames are emitted by the broad secret search; values are inspected locally and never copied to documentation. Default credentials, public operational endpoints, sensitive logging, and environment assumptions are evaluated with deployment conditions.

- [ ] **Step 4: Inspect dependencies and generated artifacts**

Run:

```bash
mvn -DskipTests dependency:tree -Dscope=runtime
mvn help:effective-pom -Doutput=target/effective-pom.xml
npm --prefix ruoyi-ui outdated
```

Expected: resolved runtime dependencies and npm direct dependency drift are recorded. Network or registry failures are retained as explicit limitations.

- [ ] **Step 5: Write the security report and stable risk register**

Write `docs/audit/03-security.md` with these exact sections:

```markdown
# 安全审计

## 结论摘要
## 风险分级与状态
## 风险台账
## 认证与会话
## 授权与数据权限
## 输入、输出与注入面
## 文件上传、下载与路径
## 定时任务与代码生成
## 运维端点与外部暴露
## 配置、秘密与日志
## 依赖与供应链
## 已有安全控制
## 动态验证限制
```

Assign findings sequential IDs `SEC-001`, `SEC-002`, and so on only after confirming evidence. Each risk row must include severity, confidence, state, impact, condition, evidence, recommendation, and validation. Do not create a finding solely because an automated search matched.

- [ ] **Step 6: Cross-check risk claims and commit**

Run:

```bash
rg -n 'SEC-[0-9]{3}' docs/audit/03-security.md
rg -n 'P0|P1|P2|P3|已确认问题|条件性风险|设计观察|未能动态验证' docs/audit/03-security.md
rg -n 'password:|secret:|private.?key|BEGIN .* KEY' docs/audit/03-security.md
git diff --check
```

Expected: IDs are sequential and unique, each finding uses the defined severity and state vocabulary, no secret values or private keys are copied, and whitespace validation passes.

```bash
git add docs/audit/03-security.md docs/audit/README.md
git commit -m "docs: add evidence-based security audit"
```

## Task 5: Run Build and Dependency Verification

**Files:**
- Modify: `docs/audit/README.md`
- Modify: `docs/audit/03-security.md`
- Reference: `pom.xml`
- Reference: `ruoyi-ui/package.json`

- [ ] **Step 1: Run backend tests and package verification**

Run:

```bash
mvn test
mvn package -DskipTests
```

Expected: record exit code, module summary, test count, and elapsed result for both commands. If no tests exist, say so explicitly; a successful package is build evidence, not behavioral test coverage.

- [ ] **Step 2: Run frontend install and production build without creating a lockfile**

Run:

```bash
npm --prefix ruoyi-ui install --no-package-lock --ignore-scripts
npm --prefix ruoyi-ui run build:prod
```

Expected: record install/build result and warnings. Confirm `package-lock.json` was not created. If scripts are required for a valid install, rerun without `--ignore-scripts` only after reviewing package lifecycle scripts in `package.json`.

- [ ] **Step 3: Run available dependency vulnerability checks**

Run:

```bash
mvn org.owasp:dependency-check-maven:12.1.3:aggregate -DskipTests -Dformat=JSON -DfailBuildOnCVSS=11 -DdataDirectory=/tmp/ruoyi-dependency-check-data
npm --prefix ruoyi-ui audit --omit=dev
```

Expected: OWASP Dependency-Check produces a machine-readable report under `target/` or records why data acquisition failed. npm audit may report that a lockfile is required; because the repository has no lockfile, record that limitation instead of committing a generated lockfile. Manually validate component reachability and affected version ranges before adding or changing a finding.

- [ ] **Step 4: Reconcile verification evidence into the reports**

Update `docs/audit/README.md` verification and limitation sections with commands, date, tool versions, exit results, test counts, build warnings, and unavailable checks. Update only affected dependency findings in `docs/audit/03-security.md`; keep existing IDs stable.

- [ ] **Step 5: Confirm verification did not introduce source changes and commit**

Run:

```bash
git status --short
git diff --check
find . -maxdepth 3 -name package-lock.json -o -name yarn.lock -o -name pnpm-lock.yaml
```

Expected: tracked changes are limited to audit documents; generated `target/`, `dist/`, and `node_modules/` paths are ignored; no new lockfile is present; whitespace validation passes.

```bash
git add docs/audit/README.md docs/audit/03-security.md
git commit -m "docs: record audit verification results"
```

## Task 6: Produce the Remediation Roadmap and Executive Summary

**Files:**
- Create: `docs/audit/04-remediation-roadmap.md`
- Modify: `docs/audit/README.md`
- Modify: `docs/audit/03-security.md`

- [ ] **Step 1: Order findings by urgency and dependency**

For every `SEC-NNN` finding, determine whether another remediation must precede it, which code/configuration surfaces it affects, whether it changes external behavior, and which regression checks prove completion. Preserve security-report severity; use implementation dependency only to order items within the same severity.

- [ ] **Step 2: Write the remediation roadmap**

Write `docs/audit/04-remediation-roadmap.md` with these exact sections:

```markdown
# 安全与质量整改路线

## 排序原则
## 立即处置（P0）
## 优先整改（P1）
## 计划整改（P2）
## 持续改进（P3）
## 跨项依赖
## 回归验证矩阵
## 建议实施批次
```

If a severity has no findings, state that the audit identified none rather than inventing work. Each roadmap row must link to the security report ID, name exact affected files, describe compatibility or deployment impact, and provide an executable validation check.

- [ ] **Step 3: Finalize the executive summary**

Update `docs/audit/README.md` with finding counts by severity and state, the highest-priority confirmed risks, the strongest existing controls, key UI/architecture observations, build status, and audit limitations. Link each summary claim to its detailed document.

- [ ] **Step 4: Verify counts and risk-ID consistency**

Run:

```bash
rg -o 'SEC-[0-9]{3}' docs/audit/03-security.md | sort -u
rg -o 'SEC-[0-9]{3}' docs/audit/04-remediation-roadmap.md | sort -u
rg -n 'P0|P1|P2|P3' docs/audit/README.md docs/audit/03-security.md docs/audit/04-remediation-roadmap.md
git diff --check
```

Expected: every security-report ID appears in the roadmap, no roadmap-only ID exists, summary counts match the risk register, and whitespace validation passes.

- [ ] **Step 5: Commit roadmap and summary**

```bash
git add docs/audit/README.md docs/audit/03-security.md docs/audit/04-remediation-roadmap.md
git commit -m "docs: add prioritized remediation roadmap"
```

## Task 7: Validate the Complete Audit Set

**Files:**
- Modify only if validation finds an error: `CONTEXT.md`
- Modify only if validation finds an error: `docs/audit/README.md`
- Modify only if validation finds an error: `docs/audit/01-architecture.md`
- Modify only if validation finds an error: `docs/audit/02-frontend-ui.md`
- Modify only if validation finds an error: `docs/audit/03-security.md`
- Modify only if validation finds an error: `docs/audit/04-remediation-roadmap.md`

- [ ] **Step 1: Scan for placeholders, ambiguous claims, and accidental secrets**

Run:

```bash
rg -n 'TBD|TODO|待定|稍后补充|适当处理|相关内容|类似于|可能存在漏洞' CONTEXT.md docs/audit
rg -n 'BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY|AKIA[0-9A-Z]{16}|password:[[:space:]]+[^*{]' CONTEXT.md docs/audit
```

Expected: no placeholder or unsupported generic vulnerability language remains, and no secret material is present. Conditional findings may use precise conditional language and must name the condition.

- [ ] **Step 2: Validate headings, links, evidence references, and Mermaid blocks**

Run:

```bash
rg -n '^# |^## ' CONTEXT.md docs/audit
rg -n '\]\([^)]+' docs/audit
rg -n '```mermaid|```' docs/audit/01-architecture.md
rg -n '[A-Za-z0-9_./-]+\.(java|xml|yml|js|vue|scss|md):[0-9]+' docs/audit
```

Expected: the designed headings are present, relative links resolve by manual check, Mermaid fences are balanced, and important behavior and findings include path-and-line evidence.

- [ ] **Step 3: Check document scope and repository cleanliness**

Run:

```bash
git diff --check HEAD~5..HEAD
git status --short --branch
git log --oneline -8
```

Expected: recent audit commits contain only `CONTEXT.md`, `docs/audit/`, the approved design, and this plan; business source is unchanged; the worktree is clean except any deliberate final documentation correction.

- [ ] **Step 4: Apply and commit final documentation corrections if required**

After correcting only confirmed documentation defects, run:

```bash
git diff --check
git status --short
git add CONTEXT.md docs/audit
git commit -m "docs: finalize codebase audit"
```

Expected: create this commit only when validation required corrections. If no corrections are needed, do not create an empty commit.

- [ ] **Step 5: Report the completed audit**

Report the document paths, finding counts by P0-P3 and state, highest-priority evidence-backed findings, backend/frontend build results, dependency-scan limitations, commit range, and confirmation that no business code changed.
