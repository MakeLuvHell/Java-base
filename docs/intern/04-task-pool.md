# 任务池（按难度）

带教人按实习生进度挑选；标注「结对」的不要甩锅独立完成。

## ★ 入门（0.5–1 天）

| ID | 任务 | 训练点 |
| --- | --- | --- |
| T01 | 字典类型下新增字典数据，并在某页面下拉使用 | 配置驱动、前后端字典 |
| T02 | 用户列表增加一个只读展示字段（已有列即可） | 字段对齐、表格列 |
| T03 | 修改某管理页空状态/提示文案（中文） | 前端工程结构、提交流程 |
| T04 | 用 Swagger 调试 3 个接口并整理请求示例 | API 文档、Token |

**第 1 周任务书：** [tasks/W1-login-and-user-list.md](./tasks/W1-login-and-user-list.md)

覆盖：环境验收、登录/Token 链路、用户列表全链路、Swagger 调试和第一份技术笔记。

## ★★ 常规（1–3 天）

| ID | 任务 | 训练点 |
| --- | --- | --- |
| T10 | **通知公告增强（置顶）— 首选**；默认只做 P0；筛选/过期为 P1 | CRUD 全链路 | 
| T11 | 新菜单 + 权限字符 + 按钮级权限（可挂在 tool 或 system 下） | 菜单 SQL、`@PreAuthorize` |
| T12 | 操作日志中定位并说明自己接口是否被记录 | 日志注解 / AOP |
| T13 | 列表导出字段扩展或查询条件扩展 | 查询对象、Excel 导出惯例 |
| T14 | 对照现有模块写「本模块 README」（接口表 + 表字段） | 文档能力 |

**第 2 周任务书：** [tasks/W2-notice-enhancement.md](./tasks/W2-notice-enhancement.md)  

**下达 W2 时建议钉死（可复制进聊天）：**  
「只做 P0 置顶；字段 `is_top` char(1) 默认 0；排序置顶优先；权限复用 `system:notice:edit`；不要改 isRead/已读；第 1 天先交设计再写码。」

**第 3 周任务书（W2 通过后）：** [tasks/W3-notice-deepen.md](./tasks/W3-notice-deepen.md)  

覆盖：T12 操作日志说明 + T13 筛选/导出 + T14 模块 README；新权限 `system:notice:export`。  

**下达 W3 时建议钉死：**  
「继续公告模块；P0=置顶筛选+导出+日志说明+模块文档；导出权限 system:notice:export；对照岗位 post 导出；第 1 天先交设计；不做 DataScope。」

**第 4 周任务书：** [tasks/W4-demo-and-wrapup.md](./tasks/W4-demo-and-wrapup.md)

**第 5 周任务书：** [tasks/W5-user-batch-import-role-dept.md](./tasks/W5-user-batch-import-role-dept.md)

覆盖：增强仓库已有用户导入，改为结构化逐行结果与“先校验、整批提交”；新增带事务/DataScope 的批量部门和角色替换。`system:user:import` 已存在，只新增 `system:user:dept`、`system:user:role`。

**第 6 周任务书：** [tasks/W6-dict-management.md](./tasks/W6-dict-management.md)

覆盖：修复字典类型重命名后的旧 Redis key 一致性缺陷，并把现有 `sys_user_sex` 接入用户列表筛选与标签展示；不重做已有字典 CRUD。

**第 7 周任务书：** [tasks/W7-online-user-and-job-monitor.md](./tasks/W7-online-user-and-job-monitor.md)

覆盖：在线**会话**批量强退、按 `deptId` 筛选与会话口径统计；调度日志按 `exception_info` 聚合失败原因、按 `start_time/end_time` 统计耗时，并用固定 fixture 验证每日趋势。

**全栈毕业项目 W8～W12：**

| 周 | 任务书 | 主要训练点 |
| --- | --- | --- |
| W8 | [工单中心 MVP](./tasks/W8-ticket-center-mvp.md) | 独立模块、建模、DataScope、迁移/回滚 |
| W9 | [工单流转与协作](./tasks/W9-ticket-workflow-collaboration.md) | 状态机、事务、幂等、乐观锁 |
| W10 | [附件、通知与审计](./tasks/W10-ticket-attachments-notifications-audit.md) | 鉴权文件、副作用、补偿、通知去重 |
| W11 | [自动化测试与 CI](./tasks/W11-testing-and-ci.md) | 测试分层、可复现构建、CI 门禁 |
| W12 | [部署与生产就绪](./tasks/W12-deployment-production-readiness.md) | 容器化、配置安全、观测、备份/回滚 |

## ★★★ 进阶（2–5 天，需带教审设计）

| ID | 任务 | 训练点 |
| --- | --- | --- |
| T20 | 某业务列表增加数据权限（本部门 / 仅本人） | `@DataScope`、角色 dataScope |
| T21 | 上传策略说明 + 非法扩展名用例（文档或测试） | 对照 SEC-009 思路 |
| T22 | 登录失败锁定的验证步骤文档化或单测骨架 | 认证、SEC-013 |
| T23 | 本地 `mvn test` / 前端 `build:prod` 脚本与说明 | 工程化、CI 预习 |
| T24 | 独立小业务表 CRUD（可 gen 后手改） | 生成器边界、模块扩展 |

## ★★★★ 全栈毕业项目拆分项（2～5 天，需设计评审）

| ID | 任务 | 训练点 |
| --- | --- | --- |
| T25 | 新增独立 Maven 业务模块并完成前后端 MVP | 模块依赖、ER、API、菜单、迁移 |
| T26 | 为业务模块增加显式状态机与动作 API | 领域规则、非法跳转、稳定错误 |
| T27 | 对批量/流转写操作增加事务、幂等和乐观锁 | 一致性、唯一约束、并发冲突 |
| T28 | 受保护附件上传、鉴权下载与失败补偿 | 文件安全、跨资源一致性 |
| T29 | 站内通知、未读状态与事件去重 | 提交后副作用、接收人、幂等 |
| T30 | 真实自动化测试 + 可复现依赖 + CI 门禁 | JUnit、Testcontainers、前端测试、lockfile |
| T31 | Compose 部署、健康检查、备份与回滚演练 | 制品、配置、观测、发布恢复 |

T25～T29 可以作为池子单项裁剪，但 W8～W10 主线必须按依赖顺序推进。T30/T31 默认导师结对，不把 CI 密钥或部署权限直接交给实习生。

## 结对专用（安全 / 基建）

| ID | 任务 | 说明 |
| --- | --- | --- |
| P01 | 只读验证 SEC-003：未登录访问 swagger / druid | 写现象与生产建议，不急着改主分支 |
| P02 | SEC-004 CORS 改为配置化白名单 | 必须带教设计评审 + Review |
| P03 | 生产关闭 springdoc / 收紧 permitAll 草案 | 对照整改路线 B1，结对改 |
| P04 | 起草 `docs/guides/local-setup.md`（按真实踩坑） | 反哺文档缺口，带教审事实准确性 |
| P05 | 生产配置外置 + 默认密钥/口令启动校验 | SEC-001/002；必须在隔离环境演练轮换 |
| P06 | 生产关闭 Swagger/Druid/generator + CORS 白名单 | SEC-003/004/007；需完整回归矩阵 |
| P07 | 数据库迁移、测试备份恢复和应用/数据库回滚 | 明确环境、恢复点和误操作防护 |

---

## 不推荐作为首个独立任务

- 直接轮换生产 JWT secret / 数据库密码策略落地（SEC-001/002）
- 大范围改造 `SecurityConfig` 而不做回归清单
- 在无人值守环境开启代码生成并执行 DDL（SEC-007）
- 无锁文件策略共识下强行提交全量 `node_modules` 或随意 lockfile 策略
- 在尚未完成自动化测试和单机部署前直接引入微服务、Kubernetes 或消息队列

---

## 与审计 ID 的弱映射（加深周可用）

| 学习向 | 可观摩的 SEC |
| --- | --- |
| 配置与密钥 | SEC-001、002 |
| 暴露面 | SEC-003 |
| 浏览器侧 | SEC-004、005、010 |
| SQL / 任务 | SEC-006、007、008 |
| 文件 | SEC-009 |
| 工程化 | SEC-012、013 |

台账正文见 [docs/audit/03-security.md](../audit/03-security.md)。
