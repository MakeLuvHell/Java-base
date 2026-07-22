# 任务下达模板

每条任务建议 **≤ 2 人日**；超过则拆成子任务。复制以下模板填写后发给实习生，或落到 `docs/intern/tasks/`。

---

```markdown
## 任务：<短标题>

### 背景
<为什么做；和业务/学习目标的关系>

### 范围
- **只改：** <模块 / 目录 / 表>
- **不要动：** <例如 Security 默认密钥策略、生产 springdoc 总开关、无关模块>
- **分支：** `feature/<name>-<topic>`
- **基线分支：** `master`

### 参考
- 文档：`CONTEXT.md` §…；`docs/audit/01-architecture.md` §…
- 对照实现：`ruoyi-admin/.../controller/system/SysNoticeController.java` 等
- 任务书（若有）：`docs/intern/tasks/....md`

### 功能说明
1. ...
2. ...

### 验收标准
1. [ ] 本地可按「复现步骤」跑通
2. [ ] 有权限用户可完成操作
3. [ ] 无对应权限字符时接口返回 **403**（不能仅前端隐藏）
4. [ ] 无密钥 / 口令进入 Git diff
5. [ ] PR 描述含：改动摘要、自测步骤、截图或接口示例（可选）

### 复现 / 自测步骤
1. ...
2. ...

### 权限与数据
- 权限字符：`<module>:<biz>:<action>`（新建需菜单/SQL 或说明如何配置）
- 测试账号：超管 / 业务角色 / 无权限（由带教人提供或实习生自建）

### 截止
- 日期：YYYY-MM-DD
- 中间检查：YYYY-MM-DD（可选）

### 风险与约束
- 禁止提交真实密码、Token secret
- 禁止将本机服务无防护暴露公网
- 代码生成器仅限本地库；共享环境先请示
```

---

## 填写示例（摘要）

| 字段 | 示例 |
| --- | --- |
| 短标题 | 公告列表支持按置顶排序 |
| 只改 | notice 领域前后端与菜单（若需） |
| 不要动 | `TokenService` 密钥逻辑、Druid 配置 |
| 验收 | 置顶公告排前；无 `system:notice:edit` 不可改置顶 |

完整示例见 [tasks/W2-notice-enhancement.md](./tasks/W2-notice-enhancement.md)。
