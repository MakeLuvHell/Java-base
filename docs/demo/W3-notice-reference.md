# W3 参考答案：公告加深（导师用）

> 对应任务书：[docs/intern/tasks/W3-notice-deepen.md](../intern/tasks/W3-notice-deepen.md)  
> **勿整包发给实习生。**

---

## 1. 设计 OK 要点

| 项 | 期望 |
| --- | --- |
| 基线 | 明确 is_top 已存在或先合 W2 |
| 筛选 | Mapper `#{}`；参数 `isTop` |
| 导出 | 对照 post；权限 `system:notice:export` |
| 菜单 | F 类型按钮 SQL；menu_id 不冲突 |
| 不做 | DataScope / Security 大改 |

**打回：** 只前端 filter；导出无 PreAuthorize；用 `${}` 拼条件。

---

## 2. 筛选参考

`selectNoticeList` 增加：

```xml
<if test="isTop != null and isTop != ''">
  AND is_top = #{isTop}
</if>
```

前端 `queryParams.isTop` + 下拉；重置清空。  
保留 W2 的 `ORDER BY is_top DESC, notice_id DESC`。

**现有查询（代码基线）：** 已有 `noticeTitle`、`noticeType`、`createBy`；`status` 在 insert/update 有，list 条件以 XML 实际为准——若 list 无 status 条件而 P1 要做，需补 XML。

---

## 3. 导出对照（岗位）

后端模式：

```text
@PreAuthorize system:post:export
@Log EXPORT
@PostMapping /export
ExcelUtil<SysPost> ...
```

公告应平行为 `system:notice:export`、`SysNotice`、`/system/notice/export`。

实体：`@Excel(name = "是否置顶", readConverterExp = "0=否,1=是")` 加在 `isTop` 相关 getter 风格与项目一致。

前端：`v-hasPermi="['system:notice:export']"` + `handleExport` → `this.download('system/notice/export', { ...queryParams }, 'notice.xlsx')`（文件名以项目 download 封装为准）。

---

## 4. 菜单 SQL 评审点

- `parent_id` = 通知公告菜单 id（SQL 初始化常见 **107**，以库为准）  
- `menu_type = 'F'`  
- `perms = 'system:notice:export'`  
- 超管通常全权；测 403 需**无该 perms 的角色**  

---

## 5. 操作日志说明——合格答法

| 问 | 要点 |
| --- | --- |
| 哪里看 | 系统监控 → 操作日志（以菜单为准） |
| 改公告 | 模块「通知公告」，类型 UPDATE/修改 |
| 导出 | 类型 EXPORT |
| 代码 | `SysNoticeController` 方法上 `@Log`；切面 `LogAspect` 收集并落库 |
| 去掉 @Log | 业务接口仍可能 200，但操作日志无记录 |

---

## 6. Review 清单

- [ ] 筛选 SQL 层  
- [ ] 导出权限 + 403  
- [ ] `@Log` 在 export 上  
- [ ] 菜单 SQL 在 PR  
- [ ] 模块 README 含 is_top 与 export  
- [ ] 无密钥、无 `${noticeTitle}` 一类危险写法  

---

## 7. 评分建议（可并入总分）

| 维度 | 分 |
| --- | --- |
| 筛选 | 25 |
| 导出功能 | 25 |
| 导出权限/菜单 | 20 |
| 操作日志说明 | 15 |
| 模块文档 | 10 |
| 红线/PR | 5 |

通过线建议 ≥70，且 403 与 SQL 筛选必须过。
