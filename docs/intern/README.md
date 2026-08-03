# 实习生带教手册

面向：

- **带教人**：安排节奏、下达任务、验收与 Code Review  
- **实习生（含零基础）**：按阶段熟悉本仓库（RuoYi-Vue / Java-base）并完成可验收交付  

> **默认分支：** `master`  
> **安全红线：** 本地/内网开发；禁止提交真实密钥与数据库口令；禁止将默认 Druid/Swagger/JWT 配置暴露到公网。  
> **文档状态：** W1 主要跟读当前实现；W2～W12 是逐周规划任务，不表示目标功能已经合入。开始每周任务前从[知识库首页](../README.md)核对当前基线。
> **相关入口：** [知识库首页](../README.md)、[代码库审计](../audit/README.md)、[工程指南](../guides/README.md)、[任务书索引](./tasks/README.md)

---

## 零基础请从这里开始（按顺序）

```text
1. 07-zero-basics.md          ← 大白话：前后端、Token、权限
2. 00-onboarding-message.md   ← 开营消息（导师会转发；也可自己对照）
3. 08-local-setup-step-by-step.md + 05-environment-checklist.md  ← 装环境并打勾
4. 09-module-map.md           ← 登录后扫菜单：每个模块干什么、和哪周任务有关
5. tasks/W1-login-and-user-list.md  ← 第 1 周
6. （W1 通过后）tasks/W2-notice-enhancement.md  ← 第 2 周 置顶
7. （W2 通过后）tasks/W3-notice-deepen.md       ← 第 3 周 筛选/导出/日志/文档
8. （收口）tasks/W4-demo-and-wrapup.md          ← 第 4 周 Demo + 笔记
```

**口诀：** 第 1 周跟链路，第 2 周置顶闭环，第 3 周同模块加深，第 4 周 Demo 收口。W5～W7 是进阶延伸，W8～W12 是通过前置验收后才解锁的全栈毕业项目。
安全整改（SEC-001 等）作教材与结对项，**不作为**实习生第一个独立任务。

### 本机默认速查

| 项 | 常见值（仅限本机学习） |
| --- | --- |
| 后端 | `http://localhost:8080` |
| 前端 | `http://localhost`（以 `npm run dev` 为准） |
| 管理员 | `admin` / `admin123`（导入本仓 SQL 后常见默认） |
| 库名建议 | `ry-vue` |
| 个人分支 | `feature/<名字>-onboarding` 或 `feature/<名字>-notice-enhance` |

---

## 文档导航

| 文档 | 读者 | 内容 |
| --- | --- | --- |
| [00-onboarding-message.md](./00-onboarding-message.md) | 带教人 → 转发 | 开营第一封消息（可直接复制） |
| [01-learning-path.md](./01-learning-path.md) | 双方 | 4 周基础、进阶延伸与全栈毕业项目（含 2 周加速版） |
| [02-reading-list.md](./02-reading-list.md) | 实习生 | 必读顺序与口头验收题 |
| [03-task-template.md](./03-task-template.md) | 带教人 | 任务下达模板 |
| [04-task-pool.md](./04-task-pool.md) | 带教人 | 按难度分级的任务池 |
| [05-environment-checklist.md](./05-environment-checklist.md) | 实习生 | 本地环境勾选清单 |
| [06-mentor-guide.md](./06-mentor-guide.md) | 带教人 | 节奏、红线、Code Review 要点 |
| [07-zero-basics.md](./07-zero-basics.md) | 实习生（零基础必读） | 概念大白话 |
| [08-local-setup-step-by-step.md](./08-local-setup-step-by-step.md) | 实习生 | 逐步装环境 |
| [09-module-map.md](./09-module-map.md) | 实习生 / 带教带读 | **系统模块地图**：菜单功能、代码位置、与 W1～W12 对应 |
| [tasks/README.md](./tasks/README.md) | 双方 | W1～W12 状态、解锁条件、配套指南与具体任务书 |

## 推荐任务书（循序渐进主线）

| 任务 | 阶段 | 说明 | 何时发 |
| --- | --- | --- | --- |
| [W1-login-and-user-list.md](./tasks/W1-login-and-user-list.md) | 第 1 周 | 跑通环境 + 登录链路 + 用户列表跟读 | **开营即发** |
| [W2-notice-enhancement.md](./tasks/W2-notice-enhancement.md) | 第 2 周 | 通知公告**置顶** | **仅 W1 通过后** |
| [W3-notice-deepen.md](./tasks/W3-notice-deepen.md) | 第 3 周 | 同模块：筛选 + 导出 + 操作日志 + 模块说明 | **仅 W2 通过后** |
| [W4-demo-and-wrapup.md](./tasks/W4-demo-and-wrapup.md) | 第 4 周 | Demo 15 分钟 + 技术笔记 + 合入收口 | **W3 通过后（或 W2 后加速收口）** |

### 进阶延伸（按能力解锁）

| 任务 | 说明 | 解锁条件 |
| --- | --- | --- |
| [W5-user-batch-import-role-dept.md](./tasks/W5-user-batch-import-role-dept.md) | 用户导入结构化结果 + 原子批量部门/角色 | W4 通过；带教先确认契约与事务边界 |
| [W6-dict-management.md](./tasks/W6-dict-management.md) | 字典旧 key 一致性修复 + 用户性别筛选 | W5 通过；不重做现成字典 CRUD |
| [W7-online-user-and-job-monitor.md](./tasks/W7-online-user-and-job-monitor.md) | 在线会话增强 + 可复现调度统计 | W6 通过；按两个模块分别验收 |

### 全栈毕业项目（连续领域，不可跳周）

| 任务 | 说明 | 核心能力 |
| --- | --- | --- |
| [W8-ticket-center-mvp.md](./tasks/W8-ticket-center-mvp.md) | 工单中心 MVP | 独立 Maven 模块、数据建模、CRUD、DataScope、迁移/回滚 |
| [W9-ticket-workflow-collaboration.md](./tasks/W9-ticket-workflow-collaboration.md) | 工单流转与协作 | 状态机、事务、幂等、乐观锁、时间线 |
| [W10-ticket-attachments-notifications-audit.md](./tasks/W10-ticket-attachments-notifications-audit.md) | 附件、通知与审计 | 鉴权文件、提交后副作用、通知去重、一致性补偿 |
| [W11-testing-and-ci.md](./tasks/W11-testing-and-ci.md) | 自动化测试与 CI | 测试分层、Testcontainers、前端测试、可复现构建 |
| [W12-deployment-production-readiness.md](./tasks/W12-deployment-production-readiness.md) | 部署与生产就绪 | 容器化、配置安全、可观测性、升级/备份/回滚 |

W8～W10 必须在同一工单领域连续演进；W11～W12 建议导师结对。不要把后续周任务一次性全部发给零基础实习生。加餐/结对仍从 [04-task-pool.md](./04-task-pool.md) 选题；完整任务书模板见 [03-task-template.md](./03-task-template.md)。

---

## 带教人 5 分钟开营检查

- [ ] 已发 [00-onboarding-message.md](./00-onboarding-message.md)（改好日期与仓库地址）  
- [ ] 只附了 W1，没有同时甩 W2 全文任务  
- [ ] 本机或开发机可演示登录 + 用户管理  
- [ ] 已约每日 10 分钟站会  
- [ ] 已说明：`admin`/`admin123`、分支命名、红线、>1 小时必问  
- [ ] （为第 2 周）准备无 `system:notice:edit` 的测试账号思路  
