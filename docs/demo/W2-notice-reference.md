# W2 参考答案：通知公告置顶

> 导师设计评审 + 验收对照用。  
> 任务书：[docs/intern/tasks/W2-notice-enhancement.md](../intern/tasks/W2-notice-enhancement.md)

---

## 1. 设计说明「标准 OK 稿」（可与实习生方案等价）

```markdown
## W2 设计（参考）

1. 置顶字段：表 sys_notice，字段名 is_top，类型 char(1)，默认值 '0'
2. 需要执行 SQL：是
   ALTER TABLE sys_notice ADD COLUMN is_top char(1) DEFAULT '0' COMMENT '是否置顶（0否 1是）';
3. 列表排序：SysNoticeMapper.xml 列表查询
   ORDER BY is_top DESC, notice_id DESC
4. 权限字符：复用 system:notice:edit / system:notice:add，不新建
5. 前端：列表列显示 是/否 或 Tag；表单 el-switch，绑定 isTop
6. 自测账号：admin；无权限用户由导师预置或自建角色去掉 notice 修改权
7. 不做：SysNoticeRead / isRead、过期、筛选（P1）
8. 风险：仅本地库；保留 @PreAuthorize；不提交密码
```

### 设计评审时快速打回条件

| 方案 | 处理 |
| --- | --- |
| 用 `isRead` 当置顶 | 打回：已读 ≠ 置顶 |
| 只在前端 `array.sort` | 打回：要求 SQL order by |
| 去掉 `@PreAuthorize` | 打回 |
| 新建权限字但未写菜单 SQL | 要求补全或改回复用 edit |
| 改 TokenService / SecurityConfig | 打回，超出范围 |

---

## 2. 现有公告接口速查（读代码对照）

类：`SysNoticeController`，`@RequestMapping("/system/notice")`

| 能力 | 方法 | 权限字符（当前代码） |
| --- | --- | --- |
| 列表 | `GET /list` | `system:notice:list` |
| 新增 | `POST /` | `system:notice:add` |
| 修改 | `PUT /` | `system:notice:edit` |
| 删除 | `DELETE /{noticeIds}` | `system:notice:remove` |
| 其它 | `listTop` / `markRead` 等 | 本任务 **默认不改** 已读相关 |

列表排序改造点：当前 XML 常见 `order by notice_id desc` → 改为置顶优先。

**实体注意：** `SysNotice` 已有 `isRead`（是否已读，非表字段语义上的「置顶」）。置顶应新增 `isTop` ↔ `is_top`。

---

## 3. 实现检查清单（Review 用）

### 数据库

- [ ] `is_top` 存在，默认 `'0'`  
- [ ] PR 中有可重复 SQL  

### 后端

- [ ] `SysNotice` 增加 `isTop` getter/setter，未滥用 `isRead`  
- [ ] `SysNoticeMapper.xml`：resultMap/select/insert/update 均含 `is_top`  
- [ ] list 查询 `ORDER BY is_top DESC, notice_id DESC`（或等价：置顶在前）  
- [ ] Controller 上 `@PreAuthorize` 仍在  
- [ ] 未改 `TokenService` / 全局 `SecurityConfig`  

### 前端

- [ ] 列表有置顶展示  
- [ ] 表单可编辑并提交 `isTop`  
- [ ] 刷新后顺序正确  

### 安全

- [ ] 无 `system:notice:edit` 时修改接口 **403**  
- [ ] diff 无密码  

---

## 4. 自测步骤期望结果（验收 Demo）

| 步骤 | 期望 |
| --- | --- |
| 建 A 不置顶、B 置顶 | 列表 B 在 A 前 |
| 把 A 改为置顶 | A 进入置顶组；同为置顶时按 notice_id 规则 |
| 无权限用户 UI | 编辑入口隐藏或不可用 |
| 无权限用户直调 PUT `/system/notice` | **403** |
| 删除/按标题查 | 仍可用 |

### 403 怎么快速验（导师）

1. 用无权限账号登录，从 Network 复制其 Token；或 Swagger 换该 Token。  
2. 调用修改公告接口带 body。  
3. 期望 403，而不是 200。

---

## 5. 参考 SQL / 字段映射

```sql
ALTER TABLE sys_notice
  ADD COLUMN is_top char(1) DEFAULT '0' COMMENT '是否置顶（0否 1是）';

-- 验收查询
SELECT notice_id, notice_title, is_top, status
FROM sys_notice
ORDER BY is_top DESC, notice_id DESC;
```

| DB | Java | JSON 常见 |
| --- | --- | --- |
| `is_top` | `isTop` | `isTop` |

与现有字段对照学习：`notice_title` ↔ `noticeTitle`，`status` ↔ `status`。

---

## 6. 常见错解与导师提示

| 实习生现象 | 原因 | 提示话术 |
| --- | --- | --- |
| 列表没有新列 | XML select 未加列 / 前端未加 column | 「先查库 SELECT is_top，再查接口 JSON 有没有 isTop」 |
| 保存后还是 0 | insert/update 动态 SQL 漏字段 | 「对照 status 在 XML 里出现的所有位置」 |
| 第一页顺序对、翻页乱 | 只在前端 sort | 「order by 必须在 Mapper」 |
| 403 测不过 | 测试账号其实有 edit 权 | 「角色菜单里把通知公告修改按钮权限去掉」 |
| 编译/JSON 怪 | `isTop` 与 boolean `isRead` 混用 | 「置顶用新字段，别动 isRead」 |

---

## 7. PR 描述合格样例（导师眼中的「像那么回事」）

```markdown
## 做了什么
- sys_notice 增加 is_top；列表置顶优先；管理端可编辑

## 表结构变更
ALTER TABLE sys_notice ADD COLUMN is_top char(1) DEFAULT '0' COMMENT '是否置顶（0否 1是）';

## 权限字符
- 复用 system:notice:add / system:notice:edit

## 自测结果
- [x] 管理员置顶与排序
- [x] 无权限 403
- [x] 回归增删改查
- [x] 未改 JWT/SecurityConfig/已读模块
```

---

## 8. 范围外（第 3 周再议，W2 不要求）

- 按置顶筛选（P1）  
- 过期时间  
- 已读/未读改造  
- XSS 富文本加固（可只读 SEC-010 笔记）  
- 单测骨架  
