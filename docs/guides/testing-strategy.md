# 自动化测试策略与执行指南

本文定义 Java-base 二次开发的测试分层、测试数据边界、执行约定和合并门禁。它是 [W11 自动化测试与 CI](../intern/tasks/W11-testing-and-ci.md) 的实施参考, 不是当前仓库已经具备测试能力的证明。

## 1. 文档状态与边界

### 1.1 截至 2026-08-03 的已核验基线

| 检查项 | 当前事实 | 结论 |
| --- | --- | --- |
| 后端测试 | 仓库中 `src/test` 文件数为 0 | 当前没有可执行的后端自动化测试 |
| 后端测试配置 | POM 中未检出 JUnit、Surefire、JaCoCo 或 Testcontainers 配置 | 本文中的依赖和插件均为待实施目标 |
| 前端测试 | `ruoyi-ui/package.json` 只有 `dev`、`build:prod`、`build:stage`、`preview` | 当前没有 `test` 或 `lint` script, 也没有前端测试依赖 |
| 依赖锁定 | 仓库没有前端 lockfile, 且 `ruoyi-ui/.gitignore` 忽略 `package-lock.json` | 当前不能把 `npm ci` 当作已可用命令 |
| CI | `.github/workflows` 中没有 workflow | 当前 push 或 PR 不会触发业务 CI |
| 本机后端工具 | 当前环境找不到 `java` 和 `mvn` | 本文未在当前机器执行 Maven 命令 |
| 本机前端工具 | 当前环境为 Node `v24.16.0`、npm `11.13.0` | 这是观测值, 不是目标工具链 |

### 1.2 本文描述的目标

本文中的 JUnit 5、Surefire、Testcontainers、Vue 2 测试工具、覆盖率和 CI 命令都是 **W11 目标设计**。只有在 W11 完成依赖、脚本、固定工具链、lockfile、测试代码和 workflow 后, 才能把相应命令升级为仓库现有能力。

范围边界如下:

- 本文负责测试策略、测试运行约定、失败诊断和测试门禁。
- CI job、缓存、分支保护和流水线模板见 [CI/CD 工程流水线指南](./ci-cd-pipeline.md)。
- 发布、部署和回滚不在本文范围内，目标约定见[发布、升级与回滚指南](./deployment-and-rollback.md)，对应 [W12 部署与生产就绪](../intern/tasks/W12-deployment-production-readiness.md)。
- W8-W10 的工单功能是训练任务目标。下文工单矩阵只定义这些功能实现后应补的测试, 不表示当前代码或测试已经存在。

## 2. 测试原则与金字塔

测试数量从下到上递减, 环境真实性和执行成本从下到上增加:

```text
                 少量端到端/部署冒烟
              Web + Security 切片测试
          持久化与 Service 集成测试
        大量纯 Java 单元测试 + 前端单元测试
```

| 层级 | 主要目标 | 是否启动 Spring | 外部依赖 | 期望速度 |
| --- | --- | --- | --- | --- |
| 纯单元测试 | 业务规则、状态机、值对象、格式与策略 | 否 | 全部替身或纯内存 | 毫秒级 |
| Web/安全测试 | 路由、参数校验、序列化、401/403、方法权限 | Web 切片或最小上下文 | Service 可替身, Security 尽量真实 | 秒级 |
| 持久化/集成测试 | SQL、事务、幂等、并发、DataScope、真实安全链路 | 是 | Testcontainers MySQL/Redis | 秒到分钟级 |
| 端到端/冒烟 | 已部署系统的关键用户路径 | 完整应用 | 隔离测试环境 | 少量、按发布执行 |

分层规则:

1. 能由纯函数或领域对象证明的规则, 不应通过完整 Spring 上下文验证。
2. Mapper、数据库约束、事务和 SQL 方言必须在与目标一致的 MySQL 上验证, 不能用 H2 冒充。
3. 认证、授权和对象级参与者校验是不同边界, 必须分别测试。
4. 一个高层测试不能替代全部低层测试。端到端用例发现链路问题, 单元测试负责精确定位规则问题。
5. 测试失败必须阻断对应门禁。禁止用 `@Disabled`、空断言或 `|| true` 长期隐藏失败。

## 3. 后端测试范围

### 3.1 纯单元测试

纯单元测试使用 JUnit 5, 必要时使用 Mockito, 不使用 `@SpringBootTest`。优先覆盖:

- 工单状态流转、终态限制和 `availableActions` 计算。
- 通知接收人去重、排除操作者和事件到接收人的映射。
- 附件大小、扩展名、文件名清理和终态上传限制。
- 工单编号格式、冲突重试策略和失败上限。
- DTO/命令到领域输入的显式转换和边界校验。
- 时间窗口、过期和排序等容易出现边界错误的规则。

外部调用只替换真正的边界, 例如 Mapper、消息发送器和文件存储。不要 mock 被测对象内部的每一层, 也不要只验证 `verify(mock).method()` 而没有验证业务结果。

### 3.2 Web 与安全测试

Web 层目标使用 JUnit 5、Spring MVC Test、MockMvc 和 Spring Security Test。按风险选择两类测试:

| 类型 | 用途 | 关键要求 |
| --- | --- | --- |
| `@WebMvcTest` 切片 | 参数校验、JSON、状态码、Controller 到 Service 的契约 | 加载真实过滤器和方法安全配置, Service 可替身 |
| 安全集成测试 | 登录态、权限字符、参与者/DataScope、对象所有权 | 至少保留一组真实 Security 配置和真实 Service/数据库链路 |

至少区分以下结果:

- 未认证请求返回 401。
- 已认证但缺方法权限返回 403。
- 有方法权限但不是工单参与者时返回稳定的业务拒绝, 且数据库零写入。
- 请求参数非法时不进入 Service 写路径。
- A 用户不能读取 B 用户的通知或下载 B 无权访问的附件。

只把 `PermissionService` mock 为 `true` 不能证明权限链路正确。安全测试需要断言响应, 也需要断言拒绝后没有状态、流水、通知或文件副作用。

### 3.3 持久化与 Service 集成测试

集成测试验证无法从 mock 推导出的行为:

- Mapper SQL、分页、排序、逻辑删除和 DataScope。
- 唯一约束、外键或等价约束、乐观锁 `version`。
- 状态更新和 flow 插入同事务提交。
- flow 或通知写入失败时主事务回滚。
- 相同 `requestId` 重放不重复写入。
- 并发更新只有一个成功, 失败方得到稳定冲突结果。
- MySQL 字符集、时区、精度和索引相关行为。
- Redis 中会话、幂等键或缓存行为, 仅在相关代码真实依赖 Redis 时加入。

测试不得连接开发者本机 `ry-vue` 数据库, 不得清空共享数据库, 不得依赖某位开发者提前准备的数据。

### 3.4 Testcontainers 约定

W11 目标默认用 Testcontainers 提供可丢弃的 MySQL, Redis 按实际业务依赖决定是否同时启用。

1. 镜像版本由团队固定, 不使用浮动的 `latest`。
2. 容器连接参数通过 `@DynamicPropertySource` 或测试专用配置注入, 不写入生产配置。
3. 数据库结构只通过正式迁移脚本初始化, 测试不能维护一份长期漂移的影子 schema。
4. 容器可按测试类或测试套件复用, 但表数据必须在用例之间隔离。
5. CI Runner 必须明确支持容器运行。无法运行 Docker 时, 该 job 应明确失败或使用团队批准的隔离服务, 不能悄悄改连共享库。
6. 容器启动失败时保留镜像名、端口映射、等待策略和容器日志, 但不输出密码。

迁移至少验证两条目标路径:

```text
空库 -> 所有 V 脚本 -> 集成测试
W8 基线库 -> 后续 V 脚本 -> 集成测试
```

回滚脚本在独立临时库验证, 不与正在运行的正向迁移用例共享容器或 schema。

## 4. JUnit 5 与 Maven 约定

### 4.1 依赖与插件

W11 实施时应在实际拥有测试的模块中最小引入测试依赖:

- JUnit Jupiter 或 `spring-boot-starter-test`。
- Mockito, starter 已提供时不重复固定版本。
- `spring-security-test`。
- Testcontainers JUnit Jupiter 和 MySQL 模块。
- JaCoCo, 只在确定报告聚合方式后启用门槛。

仓库导入 Spring Boot BOM, 但没有继承 Spring Boot parent。团队必须在根 POM 的插件管理中显式固定一个支持 JUnit 5 的 Maven Surefire 版本, 不能假设环境自带版本一定能发现 Jupiter 测试。

实际拥有测试的模块可按以下目标形态启用空套件保护, 版本属性由团队兼容性验证后写入根 POM:

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-surefire-plugin</artifactId>
    <version>${maven-surefire.version}</version>
    <configuration>
        <failIfNoTests>true</failIfNoTests>
    </configuration>
</plugin>
```

这是 W11 配置示例, 不是当前 POM 已有内容。若配置放在根 POM, 应通过 `pluginManagement` 让有测试的模块显式启用, 避免尚无测试的聚合模块因继承 `failIfNoTests` 而全部失败。

推荐命名:

| 文件 | 执行插件 | 用途 |
| --- | --- | --- |
| `*Test.java` | Surefire, `test` 阶段 | 快速单元和 Web 切片测试 |
| `*IT.java` | Failsafe, `integration-test`/`verify` 阶段 | Testcontainers 和完整集成测试 |

如果 W11 暂不引入 Failsafe, 必须明确配置 Surefire 同时发现 `*Test` 和 `*IT`, 并以 `mvn verify` 作为完整门禁命令。不能让 `*IT` 只是文件命名约定却从未执行。

### 4.2 用例风格

- 测试类与生产类使用相同包结构。
- 名称表达 `条件_动作_结果`, 或使用一致的英文 `given_when_then`。
- 一个用例验证一个业务行为, 可以包含证明该行为所需的多条关联断言。
- 使用 AssertJ/JUnit 断言最终状态和副作用, 不只验证方法被调用。
- 异常测试断言稳定异常类型和业务码, 避免依赖可能调整的整段文案。
- 禁止依赖测试执行顺序。默认不启用并行测试, 直到数据和上下文证明可隔离。
- `@Disabled` 必须关联可追踪事项、负责人和恢复条件; 合并门禁中的关键用例不得禁用。

## 5. Fixture、隔离与确定性

### 5.1 Fixture 设计

建立小而明确的 builder/factory, 不复制大段 SQL 或 JSON。工单域目标 fixture 至少包含:

- 两个有父子关系的部门。
- 管理员、工单管理员、两个处理人、两个创建人和无权限用户。
- 覆盖全部状态的最小工单集合。
- 重复 `requestId`、不同 `version`、已读/未读通知和附件元数据。

Fixture 只能使用虚构数据, 不包含真实姓名、手机号、邮箱、附件或生产导出数据。默认值应明显可读, 每个测试只覆盖与场景相关的字段。

### 5.2 状态隔离

- 纯单元测试每次创建新对象, 不共享可变静态状态。
- 数据库用例采用事务回滚、每例独立 schema 或显式清理中的一种, 并在测试设计中写明。
- 涉及真实提交、异步或多线程的测试不能假装依赖事务回滚, 应使用唯一业务键并在结束时显式清理。
- Redis key 带每个测试的唯一前缀, 结束后只删除该前缀下的数据。
- 文件测试使用 JUnit `@TempDir`, 结束后断言临时文件和数据库元数据符合预期。
- 安全上下文、线程变量和 mock 的全局状态在每例后清理。

### 5.3 时钟与随机性

- 生产代码通过 `Clock` 或项目统一的时间提供者读取当前时间; 测试使用固定 `Clock`。
- UUID、工单编号和随机退避通过可替换生成器注入; 测试提供固定序列。
- 不用 `Thread.sleep` 等待异步结果。使用有超时的 latch、Awaitility 或可控执行器。
- 并发测试设置总超时, 并在失败时输出每个参与方的结果和版本, 不能无限等待。
- 时区在测试启动时固定, 并为日期跨日、闰日或夏令时相关规则增加边界用例。

## 6. 工单域目标测试矩阵

> **状态: W11 目标, 当前不存在。** 下表用于 W8-W10 工单功能实现后的设计评审和验收, 不能登记为当前覆盖率或当前测试数量。

| 风险 | 建议层级 | 目标场景 | 关键断言 |
| --- | --- | --- | --- |
| 状态流转 | 单元 | 每个合法/非法 action, 终态再次操作 | 新状态、可用动作、非法动作零副作用 |
| 参与者权限 | 单元 + 安全集成 | 创建人、处理人、管理员、旁观用户 | 允许矩阵准确, 越权零写入 |
| DataScope | 持久化集成 | 本部门、子部门、跨部门查询 | 返回集合不多不少, 不能靠前端过滤 |
| 事务一致性 | Service 集成 | flow 插入或通知写入失败 | 状态、flow、通知一起提交或一起回滚 |
| 幂等 | Service 集成 | 同一 `requestId` 重放 | 只产生一次状态变化和一次流水 |
| 乐观锁 | 并发集成 | 两个相同 `version` 同时更新 | 仅一个成功, 另一方得到冲突响应 |
| 工单编号 | 单元 + 持久化 | 格式、并发冲突、重试耗尽 | 不使用 `select max`, 失败可诊断 |
| 通知 | 单元 + 持久化 | 接收人去重、排除操作者、已读 | 唯一约束有效, 查询包含 `receiverId` |
| 附件 | 单元 + Web/集成 | 类型/大小、终态上传、越权下载 | 拒绝时无公开 URL、无残留元数据/文件 |
| 参数校验 | Web | 缺字段、非法枚举、超长文本 | 稳定 4xx 和业务码, Service 未执行 |
| 认证授权 | Web/安全 | 未登录、无方法权限、非参与者 | 分别得到 401、403、业务拒绝 |
| 迁移 | 集成 | 空库升级、W8 基线升级、独立库回滚 | schema 版本、约束和关键查询正确 |

每个 PR 不必一次完成整张表, 但新增或修改规则必须同时更新对应行的自动化测试和未覆盖风险记录。

## 7. Vue 2 前端测试策略

### 7.1 工具选择边界

当前前端是 Vue `2.6.12` 和 Vue CLI `4.4.6`。W11 应选择与 Vue 2 兼容的 Vue Test Utils v1、Jest 和 Babel 组合, 并在固定 Node LTS 上验证。不要直接套用只支持 Vue 3 的 Vue Test Utils v2 配置。

目标 scripts 建议统一为:

```json
{
  "scripts": {
    "lint": "<团队选定并验证的 lint 命令>",
    "test:unit": "<适合本地 watch 的 Jest 命令>",
    "test:unit:ci": "<单次运行并生成报告/覆盖率的 Jest 命令>"
  }
}
```

上面是命名契约, 不是当前 `package.json` 已有内容。具体参数应在 W11 工具兼容性验证后写实, CI 只调用已在本地验证的 script。

### 7.2 测试范围

| 对象 | 优先测试 | 不建议 |
| --- | --- | --- |
| 纯工具函数/状态映射 | action 可见性、日期/状态格式化、请求参数构造 | 为简单常量写测试 |
| 组件 | loading/disabled、提交成功/失败、事件和错误提示 | 对 Element UI 大段 DOM 做快照 |
| 页面交互 | 筛选重置、分页、冲突后重新加载、通知徽标 | 依赖真实后端和任意网络 |
| API 边界 | URL、method、关键 payload 和错误映射 | 重复测试 axios 自身 |
| 权限 UI | `availableActions` 与权限指令下的显示/禁用 | 把按钮隐藏当成后端授权证明 |

工单域的首批目标用例:

- `availableActions` 决定动作按钮显示和禁用。
- 提交中按钮不可重复点击; 成功后刷新; 失败时保留用户输入。
- 乐观锁冲突显示重新加载入口。
- 未读数为 0 时不显示徽标, 正数变化能更新。
- 附件请求失败或越权时不生成可访问链接。
- 查询重置同时恢复筛选值和页码。

测试通过 API 模块的替身控制响应, 使用 `nextTick`/`flushPromises` 等待 Vue 更新。计时器只在需要时使用 fake timers, 每例后恢复。优先断言用户可见行为和发出的业务请求, 快照仅用于小且稳定的自有组件。

## 8. 覆盖率使用原则

覆盖率是发现盲区的信号, 不是测试质量本身。

1. 先记录 W11 首次真实基线, 再由导师为新增工单包和关键前端目录确定门槛。
2. 优先看分支覆盖率, 因为状态机、权限和失败补偿的风险通常不在线覆盖率中体现。
3. 门槛按模块或新增代码逐步提高, 不为了达标给 getter/setter、生成代码或框架配置补无意义测试。
4. 排除项必须按路径列出理由, 不允许用宽泛通配符排除业务包。
5. 覆盖率门槛只能通过有评审记录的变更调整。修复红灯时不能直接降低阈值。
6. 后端报告建议由 JaCoCo 生成, 前端报告由已选 Jest 配置生成; CI 失败时仍归档报告。
7. 事务、幂等、并发、越权和附件泄露等高风险项即使整体覆盖率达标, 仍必须有显式用例。

W11 中“建议新增业务包行覆盖率不低于 60%”是评审起点, 不是当前仓库已经达到的指标。

## 9. 防止零测试空跑

`BUILD SUCCESS` 不等于执行了测试。W11 必须同时落实以下保护:

1. 至少一个 CI 前置检查确认仓库存在符合命名约定的 `*Test.java`/`*IT.java` 和前端测试文件。
2. 在实际拥有测试的 Maven 模块为 Surefire/Failsafe 配置 `failIfNoTests=true`。不要在仍无测试的所有聚合模块盲目全局继承。
3. CI 解析 Surefire/Failsafe XML 报告, 汇总 executed test 数并要求大于 0; 只检查报告目录存在不够。
4. 前端 CI script 使用单次运行模式, 并让 Jest 的“未发现测试”保持非零退出码; 不使用允许空套件的选项。
5. job 日志和 PR 摘要记录后端单元、后端集成、前端测试的发现数、执行数、失败数和跳过数。
6. 路径过滤不能让修改业务代码的 PR 跳过对应测试 job。

推荐的源文件前置检查模板:

```bash
# W11 建立测试文件后才能使用。它只能防止源码为零, 仍需解析测试报告确认实际执行数。
find . -type f \
  \( -path '*/src/test/java/*Test.java' -o -path '*/src/test/java/*IT.java' \) \
  -print -quit | grep -q .

find ruoyi-ui -type f \
  \( -name '*.spec.js' -o -name '*.test.js' \) \
  -print -quit | grep -q .
```

建议把“解析 XML/JSON 报告并验证执行数”的逻辑放入版本化脚本并为脚本自身加测试, 而不是在 workflow 中维护难以审查的长串 shell。

## 10. 本地与 CI 命令模板

> **重要:** 以下仅为 W11 推荐命令契约。截至 2026-08-03, 当前机器没有 JDK/Maven, 仓库没有 Maven Wrapper、测试代码、前端 lockfile、测试/lint script 或 workflow, 因而不能声称这些命令现在可运行或已通过。

### 10.1 W11 完成后的本地模板

```bash
# 后端: W11 增加并固定 Maven Wrapper 后
./mvnw -B test
./mvnw -B verify

# 前端: 先切换到团队选定并验证的 Node LTS, 且已提交 lockfile/scripts
cd ruoyi-ui
npm ci
npm run lint
npm run test:unit:ci
npm run build:prod
```

`test` 用于快速反馈, `verify` 是包含集成测试和报告校验的完整后端门禁。若团队未采用 Wrapper, 必须用等价方式固定 Maven 版本, 并在本地与 CI 记录 `mvn -version`。

### 10.2 目标 CI job 命令

| job | 推荐命令契约 | 前置条件 |
| --- | --- | --- |
| `backend-test` | `./mvnw -B verify` | JDK 17、Wrapper、测试依赖和 Testcontainers 已落地 |
| `frontend-test-build` | `npm ci && npm run lint && npm run test:unit:ci && npm run build:prod` | 固定 Node LTS、lockfile 和 scripts 已落地 |
| `test-count-check` | 解析 Surefire/Failsafe/Jest 报告并要求 executed > 0 | 报告路径和格式已版本化 |
| `docs-check` | Markdown 链接检查和 `git diff --check` | 团队选择并固定文档检查器 |

CI 环境版本、job 设计和完整 workflow 模板见 [CI/CD 工程流水线指南](./ci-cd-pipeline.md)。

## 11. 失败排查

先找第一条根因, 不从最后一行 `BUILD FAILURE` 猜测。

| 现象 | 检查顺序 |
| --- | --- |
| JUnit 测试未发现 | 文件命名 -> Jupiter engine -> Surefire 版本/配置 -> 模块是否进入 reactor |
| 本地通过、CI 失败 | JDK/Maven/Node/npm 版本 -> 时区/locale -> lockfile -> 未提交文件 -> 环境变量 |
| Testcontainers 启动失败 | Runner 是否支持容器 -> 镜像拉取 -> 等待策略 -> 容器日志 -> 端口/资源限制 |
| 数据库测试单独通过、整套失败 | 共享数据 -> 事务是否真实提交 -> 清理顺序 -> 唯一键 -> 测试执行顺序依赖 |
| 权限测试意外通过 | 是否 mock 掉 Security -> 测试身份/权限字符 -> 对象参与者 -> 拒绝后的副作用 |
| 并发测试偶发超时 | 阻塞点 -> latch/执行器 -> 总超时 -> 数据锁 -> 双方结果日志 |
| 前端测试卡住 | 未恢复 fake timer/mock -> 未等待 Promise/Vue tick -> watch 模式误用于 CI -> open handles |
| 前端 snapshot 大面积变化 | 是否断言 Element UI 结构 -> 升级影响 -> 改为用户行为和稳定文本断言 |
| 覆盖率骤降 | 测试是否未发现 -> 报告聚合路径 -> 新包是否纳入 -> 排除规则是否变化 |

提交求助信息时附: 失败 job、固定工具版本、首个根因日志、最小复现命令、测试报告路径、容器日志和最近一次成功 commit。日志必须先移除 token、密码和连接密钥。

## 12. 合并门禁

默认开发流程是 feature branch -> Pull Request -> required checks -> review -> merge。禁止把直接 push 默认分支作为日常教程或绕过门禁的替代流程。

W11 稳定后, 默认分支保护至少要求:

- 后端单元/Web 测试通过。
- 后端 Testcontainers 集成测试通过。
- 前端 lint、单元测试和生产构建通过。
- 后端与前端 executed test 数均大于 0。
- 覆盖率未低于团队已批准门槛。
- 文档/迁移检查通过。
- 必要的依赖扫描通过或具有未过期、可追踪的例外。
- 至少一名评审者批准; 提交者不能通过关闭测试或降低阈值自行放行。

偶发失败先按真实失败处理。隔离 flaky test 只能作为短期措施, 必须记录负责人、原因、修复期限, 且高风险权限/事务用例不得被长期隔离。

## 13. Definition of Done

### 单个业务变更

- [ ] 验收条件已映射到合适测试层级。
- [ ] 正常、边界、拒绝和失败补偿路径均已考虑。
- [ ] 新测试在修复前能因目标行为失败, 修复后通过。
- [ ] 测试不依赖共享数据库、真实用户数据、执行顺序或系统当前时间。
- [ ] 权限拒绝同时验证响应和零副作用。
- [ ] 前端测试断言用户行为, 后端仍有独立授权测试。
- [ ] 本地执行了适用于本变更的固定命令, PR 中记录版本、测试数和结果。
- [ ] 未覆盖风险已记录, 不是用覆盖率数字掩盖。

### W11 测试能力

- [ ] JDK、Maven、Node 和 npm 版本策略已固定并在干净环境验证。
- [ ] 前端 lockfile 已提交, CI 使用 `npm ci`。
- [ ] Surefire/Failsafe 能发现并执行 JUnit 5 测试。
- [ ] 后端单元、Web/安全、持久化/集成测试均有真实断言。
- [ ] Testcontainers 与开发/生产数据完全隔离。
- [ ] Vue 2 测试脚本在单次 CI 模式下可重复执行。
- [ ] 零测试保护会让空测试套件失败。
- [ ] 测试和覆盖率报告在失败时仍可查看。
- [ ] required checks 已绑定默认分支保护。
- [ ] 人为破坏规则和前端构建时, CI 确实变红; 恢复后重新通过。

## 14. 相关文档

| 文档 | 关系 |
| --- | --- |
| [CI/CD 工程流水线指南](./ci-cd-pipeline.md) | 当前 CI 基线、目标 workflow、分支保护和排障 |
| [W11 自动化测试与 CI](../intern/tasks/W11-testing-and-ci.md) | 本策略的实施任务和验收标准 |
| [W12 部署与生产就绪](../intern/tasks/W12-deployment-production-readiness.md) | 部署冒烟、升级和恢复演练 |
| [deployment-and-rollback.md](./deployment-and-rollback.md) | 已成文的发布与回滚目标约定；当前仓库部署能力仍未落地 |
| [API 文档与 Swagger](./api-docs-swagger.md) | API 调试边界; Swagger 不能替代自动化测试 |
| [安全审计台账](../audit/03-security.md) | SEC-012 供应链与 SEC-013 自动化测试风险 |
| [整改路线图](../audit/04-remediation-roadmap.md) | 工程批次和风险整改顺序 |

## 15. 修订记录

| 日期 | 说明 |
| --- | --- |
| 2026-08-03 | 初版: 明确当前零测试基线, 定义后端/前端分层、确定性、工单目标矩阵、零测试保护、命令模板和合并门禁 |
