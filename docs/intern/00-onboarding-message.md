# 开营消息（可直接转发）

复制下方正文发给实习生；按实际周期改日期与联系方式。

---

## 正文

你好，欢迎加入本项目（RuoYi-Vue / Java-base）实习。

### 本周目标

本地跑通前后端，并讲清**登录**与**权限**主链路。

### 必读（按顺序）

1. 仓库根目录 `README.md`（产品概览）
2. `CONTEXT.md`（术语与模块边界）
3. `docs/audit/01-architecture.md`（架构与运行链路）
4. `docs/guides/api-docs-swagger.md`（Swagger 使用）
5. 带教手册总览：`docs/intern/README.md`
6. 环境清单：`docs/intern/05-environment-checklist.md`
7. 本周任务书：`docs/intern/tasks/W1-login-and-user-list.md`

### 环境要求（摘要）

- JDK 17、Maven、MySQL、Redis
- 导入仓库 `sql/` 下初始化脚本
- 配置仅用**本地**数据源/Redis，**不要**把真实密码提交到 Git
- 默认分支：`master`；个人分支：`feature/<你的名字>-onboarding`

### 本周五交付

1. 环境 checklist（`05-environment-checklist.md` 勾选完成）
2. 登录时序说明一页（可手绘/Markdown，基于架构文档自己重述）
3. 用 Swagger 带 Token 调通至少一个登录后接口（如用户列表）

### 协作约定

- 阻塞超过 **1 小时**必须提问：写清「现象 / 已查文件 / 完整报错」
- 每天同步约 10 分钟（时间另约）
- 禁止：提交密钥、把服务暴露公网、在共享库上随意用代码生成器建表

有问题先看 `docs/intern/` 与 `docs/audit/`，仍不清再问我。

---

## 带教人备注

- 第 1 天尽量结对装环境，避免卡在 MySQL/Redis 配置。
- 不要第一周就安排 SEC-001～003 的正式修复，除非结对。
