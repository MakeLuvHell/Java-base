# 学习路径（4 周标准 / 2 周加速）

## 总目标

| 项 | 标准 |
| --- | --- |
| 能力 | 能独立完成「一个小业务模块」前后端闭环，并讲清登录 / 菜单权限 / 方法权限 / 数据权限的区别 |
| 产出 | 可合并的小功能 PR + 15 分钟 Demo + 简短技术笔记 |
| 环境 | 本地或内网；遵守 [06-mentor-guide.md](./06-mentor-guide.md) 红线 |

---

## 4 周标准版

### 第 1 周：跑通 + 看懂主链路

| 天 | 内容 | 交付 |
| --- | --- | --- |
| D1 | 装环境、导入 SQL、本地配置 | [05-environment-checklist.md](./05-environment-checklist.md) |
| D2 | 启双端；走通用户 / 角色 / 菜单 / 字典 | 操作记录或截图说明 |
| D3 | 跟登录：Controller → LoginService → TokenService → Redis | 一页时序说明 |
| D4 | 跟「用户列表」：前端 API → `@PreAuthorize` → Service → Mapper | 路径清单（文件 + 方法） |
| D5 | Swagger 带 Token 调试；热身小改（文案/字典） | 小 PR 或现场演示 |

**任务书：** [tasks/W1-login-and-user-list.md](./tasks/W1-login-and-user-list.md)

**本周不要做：** 大改 `SecurityConfig`、上生产、独立改 JWT 密钥策略。

---

### 第 2 周：垂直切片（真正动手）

**推荐主线：** 通知公告小增强（置顶 / 筛选等）。

**任务书：** [tasks/W2-notice-enhancement.md](./tasks/W2-notice-enhancement.md)

备选：用代码生成器生成一版 CRUD 后**手改**规范（仅本地库；注意 SEC-007，勿在共享生产库乱用 gen）。

| 节奏 | 说明 |
| --- | --- |
| 每日 | 10 分钟站会：昨天 / 卡点 / 今天 |
| 周中 | Code Review：分层、权限注解、SQL、前端是否只藏按钮 |

---

### 第 3 周：加深 + 轻量质量

按方向选一条主线（可与带教人确认）：

| 方向 | 示例 | 参考文档 |
| --- | --- | --- |
| 前端 | 列表查询/重置/导出；`v-hasPermi` 与路由 | [02-frontend-ui.md](../audit/02-frontend-ui.md) |
| 后端权限 | 新接口权限字符；`@DataScope` 本部门可见 | [01-architecture.md](../audit/01-architecture.md) |
| 工程 | 本地构建脚本；理解 CI 概念 | [ci-cd-pipeline.md](../guides/ci-cd-pipeline.md) |
| 安全观摩（结对） | 只读验证 swagger/druid 匿名可访问；写生产收敛笔记 | [03-security.md](../audit/03-security.md) |

可选：补 1 个单元测试或「无权限 403」集成测试骨架（对齐 SEC-013）。

---

### 第 4 周：收尾与展示

| 交付 | 说明 |
| --- | --- |
| Demo 15 分钟 | 环境、业务功能、有/无权限账号对比 |
| 技术笔记 | 登录链路 + 自己模块接口/表结构 |
| PR 合入 | 经 Review 后合入 `master` |
| 加分 | 起草 `local-setup` 踩坑、README 导航、小测试 |

---

## 2 周加速版

| 周 | 内容 |
| --- | --- |
| W1 | 环境 + [02-reading-list.md](./02-reading-list.md) 前 4 项 + W1 任务书 |
| W2 | W2 公告增强 + Demo + 一次 403 权限演示 |

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
