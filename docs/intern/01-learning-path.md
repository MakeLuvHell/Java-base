# 学习路径（4 周基础 / 进阶延伸 / 全栈毕业项目）

## 总目标

| 项 | 标准 |
| --- | --- |
| 基础能力 | 能独立完成「一个小业务模块」前后端闭环，并讲清登录 / 菜单权限 / 方法权限 / 数据权限的区别 |
| 全栈能力 | 能设计并持续演进一个业务领域，处理事务、并发、文件、通知、测试、部署与回滚 |
| 产出 | 可合并的功能 PR + 自动化验证 + 可执行迁移/回滚 + Demo 与技术笔记 |
| 环境 | 本地或内网；遵守 [06-mentor-guide.md](./06-mentor-guide.md) 红线 |

---

## 零基础开场（第 0 步，约 1～2 小时）

在装环境前或同时阅读：

1. [07-zero-basics.md](./07-zero-basics.md) — 前后端、Token、三层权限大白话  
2. [08-local-setup-step-by-step.md](./08-local-setup-step-by-step.md) + [05-environment-checklist.md](./05-environment-checklist.md)  
3. 登录成功后对照 [09-module-map.md](./09-module-map.md) 扫一遍侧边栏（先建立地图，不必背）

**本机默认（仅学习）：** 后端 `8080`；前端常见 `http://localhost`；管理员 `admin` / `admin123`；库名建议 `ry-vue`。

---

## 4 周标准版

### 第 1 周：跑通 + 看懂主链路

| 天 | 内容 | 交付 |
| --- | --- | --- |
| D1 | 读零基础文档；装工具链；导入 SQL；改本地配置 | [05-environment-checklist.md](./05-environment-checklist.md) A～D |
| D2 | 启双端；`admin` 登录；走通用户 / 角色 / 菜单 / 字典 / 公告菜单 | checklist E～F；能进用户管理 |
| D3 | 跟登录：Controller → LoginService → TokenService → Redis；写 4 问说明 | 登录说明 Markdown |
| D4 | 跟「用户列表」：Network → 前端 API → `@PreAuthorize` → Service → Mapper | 路径清单（含权限字符） |
| D5 | Swagger 带 Token 调试；总复习口头题；可选热身小改 | Swagger 记录；现场可演示 |

**任务书（开营即发，本周唯一）：** [tasks/W1-login-and-user-list.md](./tasks/W1-login-and-user-list.md)

**本周不要做：** 大改 `SecurityConfig`、上生产、独立改 JWT 密钥策略、提前大改公告模块。

---

### 第 2 周：垂直切片（真正动手）

**推荐主线：** 通知公告 **置顶**（默认只做 P0；筛选/过期为加分）。

**任务书（仅 W1 通过后发）：** [tasks/W2-notice-enhancement.md](./tasks/W2-notice-enhancement.md)

| 天 | 内容 |
| --- | --- |
| D1 | 读懂现有公告 CRUD；交设计（字段/SQL/排序/权限）；等导师 OK |
| D2 | 本地 `ALTER TABLE` + Domain + Mapper XML |
| D3 | Controller 权限核对 + 后端自测（含 403） |
| D4 | 前端列表列 + 表单 |
| D5 | 联调、PR、Demo |

**推荐默认：** 字段 `sys_notice.is_top` char(1) 默认 `'0'`；`ORDER BY is_top DESC, notice_id DESC`；复用 `system:notice:edit`；**不要**动 `isRead` / 已读模块。

备选：用代码生成器生成一版 CRUD 后**手改**规范（仅本地库；注意 SEC-007，勿在共享生产库乱用 gen）。

| 节奏 | 说明 |
| --- | --- |
| 每日 | 10 分钟站会：昨天 / 卡点 / 今天 |
| 周中 | Code Review：分层、权限注解、SQL 排序、前端是否只藏按钮 |

---

### 第 3 周：同模块加深（筛选 / 导出 / 日志 / 文档）

**推荐主线（默认）：** 仍在**通知公告**上增量，不换业务域。

**任务书（仅 W2 通过后发）：** [tasks/W3-notice-deepen.md](./tasks/W3-notice-deepen.md)

| 天 | 内容 |
| --- | --- |
| D1 | 回归置顶；读岗位导出样板；操作日志初探；交设计 |
| D2 | 按置顶筛选（前后端 + Mapper `#{}`） |
| D3 | 导出后端 + `@Excel` + `@PreAuthorize`/`@Log` |
| D4 | 菜单按钮 SQL `system:notice:export` + 前端导出按钮 + 403 |
| D5 | 操作日志成文 + 模块 README + PR |

| 训练点 | 对应任务池 |
| --- | --- |
| 查询条件扩展 | T13 |
| 导出 + 新权限字符 | T13 + T11 的权限部分 |
| 操作日志 | T12 |
| 模块说明 | T14 |

**可选支线（导师裁剪，勿与 P0 并行过多）：** 安全只读观摩 P01、CI 概念阅读、极简测试骨架。  
**本周默认不做：** `@DataScope` 改造、换新业务表大 CRUD（可第 4 周加餐或结对）。

---

### 第 4 周：收尾与展示

**任务书：** [tasks/W4-demo-and-wrapup.md](./tasks/W4-demo-and-wrapup.md)

| 交付 | 说明 |
| --- | --- |
| Demo 15 分钟 | 环境、登录、公告置顶/筛选/导出、有/无权限对比 |
| 技术笔记 | 登录链路 + 公告模块接口/表结构/权限 |
| PR 合入 | 经 Review 后合入 `master` |
| 加分 | 踩坑反哺 docs、安全只读笔记、DataScope 观摩、小测试 |

---

## W5～W7：进阶延伸（可按实习周期裁剪）

| 周 | 任务 | 能力增量 | 下达注意 |
| --- | --- | --- | --- |
| W5 | [用户导入增强与批量授权](./tasks/W5-user-batch-import-role-dept.md) | 两阶段导入、批量写、事务、数据范围 | 先区分现有导入与新增增强 |
| W6 | [字典缓存一致性与业务接入](./tasks/W6-dict-management.md) | cache-aside、提交后失效、业务字典 | 不重做仓库现成 CRUD |
| W7 | [在线会话与调度统计](./tasks/W7-online-user-and-job-monitor.md) | Redis 会话口径、聚合 SQL、fixture、图表 | 两个模块分别设计和验收 |

W5～W7 不是“标准 4 周必须做完”的内容。实习周期较短时，优先选择一个与个人短板最匹配的任务，不要为了周数牺牲 Review 和回归。

---

## W8～W12：全栈毕业项目（工单中心）

这一阶段只在 W1～W7 的核心能力已稳定后解锁。W8～W10 围绕同一领域持续演进，不能替换成五个互不关联的 CRUD。

| 周 | 任务 | 主要交付 | 关键评审点 |
| --- | --- | --- | --- |
| W8 | [工单中心 MVP](./tasks/W8-ticket-center-mvp.md) | 独立模块、表/字典/菜单、前后端 CRUD、DataScope | 模块依赖、创建人防伪造、迁移/回滚 |
| W9 | [工单流转与协作](./tasks/W9-ticket-workflow-collaboration.md) | 状态机、分派/领取/评论、时间线 | 事务、幂等、乐观锁、规则唯一来源 |
| W10 | [附件、通知与审计](./tasks/W10-ticket-attachments-notifications-audit.md) | 鉴权附件、未读通知、提交后副作用 | 文件补偿、通知去重、越权下载 |
| W11 | [自动化测试与 CI](./tasks/W11-testing-and-ci.md) | 后端/前端测试、lockfile、CI 门禁 | 真实断言、隔离数据、故意破坏验证 |
| W12 | [部署与生产就绪](./tasks/W12-deployment-production-readiness.md) | Compose、配置、安全、观测、备份与回滚 | 干净环境复现、暴露面、恢复演练 |

### 全栈阶段统一完成定义

每周除任务书自身验收外，还必须满足：

1. 第 1 天先交 ER/API/权限/异常或部署设计，导师确认后编码。
2. 数据库变更具有版本化正向脚本和回滚/恢复说明。
3. 有权限、无权限、越权和异常路径都有真实验证。
4. 前端具备 loading、empty、error、submitting 等完整状态。
5. 从 W11 起，关键行为必须由自动化测试和 CI 保护。
6. PR 只包含本周范围，不提前混入下一周能力。

---

## 2 周加速版

| 周 | 内容 |
| --- | --- |
| W1 | 环境 + [02-reading-list.md](./02-reading-list.md) 前 4 项 + W1 任务书 |
| W2 | W2 置顶 + 精简 Demo + 一次 403；W3/W4 内容压缩为「筛选或导出二选一 + 短笔记」 |

## 主线一览

```text
标准 4 周：
W1 跟读登录/用户列表
 → W2 公告置顶（写库+排序+403）
 → W3 公告筛选+导出+日志+模块文档
 → W4 Demo + 技术笔记 + 合入

进阶延伸（W4 后继续）：
 → W5 用户导入增强 + 批量分配部门/角色
 → W6 字典旧 key 修复 + 用户性别字典接入
 → W7 在线会话增强 + 调度日志统计

全栈毕业项目（前置通过后）：
 → W8 工单 MVP
 → W9 状态流转/协作/并发
 → W10 附件/通知/审计
 → W11 测试与 CI
 → W12 部署/观测/回滚
```

---

## 阶段与文档映射

```text
入门     → 07 零基础 + 09 模块地图 + CONTEXT + 01-architecture + Swagger
动手     → 对照 system/notice 现有实现做垂直切片（W2）
加深     → 同模块筛选/导出/日志（W3）；02-frontend-ui / 03-security / CI（选读）
收口     → 笔记 + Demo（W4）；可选回馈 docs/guides
进阶     → 用户批量操作（W5）、缓存一致性与字典接入（W6）、在线会话+调度统计（W7）
全栈     → 工单领域连续迭代（W8～W10）→ 测试/CI（W11）→ 部署/回滚（W12）
```

全栈阶段从 [W1～W12 任务书导航](./tasks/README.md)进入；工程约束依次参考[数据库迁移](../guides/database-migrations.md)、[测试策略](../guides/testing-strategy.md)、[CI/CD](../guides/ci-cd-pipeline.md)、[发布与回滚](../guides/deployment-and-rollback.md)和[可观测性与运维](../guides/observability-and-operations.md)。

## 成功标准（带教人打分参考）

1. 能否讲清一次已认证请求的鉴权路径（URL → 方法权限 → 业务）
2. 新接口是否默认考虑 `@PreAuthorize` 与菜单权限字符
3. PR 是否小、可回滚、含自测说明
4. 是否主动查 `CONTEXT` / audit，而不是只抄页面
5. 进入全栈阶段后，能否处理事务、并发、失败补偿和自动化测试
6. 能否在干净环境完成构建、迁移、部署、观测与回滚
