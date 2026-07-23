# 学习路径（4 周标准 / 2 周加速）

## 总目标

| 项 | 标准 |
| --- | --- |
| 能力 | 能独立完成「一个小业务模块」前后端闭环，并讲清登录 / 菜单权限 / 方法权限 / 数据权限的区别 |
| 产出 | 可合并的小功能 PR + 15 分钟 Demo + 简短技术笔记 |
| 环境 | 本地或内网；遵守 [06-mentor-guide.md](./06-mentor-guide.md) 红线 |

---

## 零基础开场（第 0 步，约 1～2 小时）

在装环境前或同时阅读：

1. [07-zero-basics.md](./07-zero-basics.md) — 前后端、Token、三层权限大白话  
2. [08-local-setup-step-by-step.md](./08-local-setup-step-by-step.md) + [05-environment-checklist.md](./05-environment-checklist.md)

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

## 2 周加速版

| 周 | 内容 |
| --- | --- |
| W1 | 环境 + [02-reading-list.md](./02-reading-list.md) 前 4 项 + W1 任务书 |
| W2 | W2 置顶 + 精简 Demo + 一次 403；W3/W4 内容压缩为「筛选或导出二选一 + 短笔记」 |

## 4 周主线一览

```text
W1 跟读登录/用户列表
 → W2 公告置顶（写库+排序+403）
 → W3 公告筛选+导出+日志+模块文档
 → W4 Demo + 技术笔记 + 合入
```

---

## 阶段与文档映射

```text
入门     → CONTEXT.md + 01-architecture.md + Swagger 指南
动手     → 对照 system/notice 现有实现做垂直切片
加深     → 02-frontend-ui / 03-security / CI 指南（选读）
收口     → 笔记 + Demo；可选回馈 docs/guides
```

## 成功标准（带教人打分参考）

1. 能否讲清一次已认证请求的鉴权路径（URL → 方法权限 → 业务）
2. 新接口是否默认考虑 `@PreAuthorize` 与菜单权限字符
3. PR 是否小、可回滚、含自测说明
4. 是否主动查 `CONTEXT` / audit，而不是只抄页面
