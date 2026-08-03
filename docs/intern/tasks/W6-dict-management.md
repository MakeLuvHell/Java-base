# 任务书 W6：字典缓存一致性与业务接入

> **前置要求：** 已通过 W1～W5，能说明 Controller、Service、Mapper、Redis 缓存和 Vue 字典 mixin 的职责。
> **任务性质：** 仓库已经完整实现字典类型/字典数据 CRUD、前端管理页和 Redis 缓存。本周不重复造 CRUD，而是修复一个可复现的一致性缺陷，再把现有字典真实接入业务查询。

| 项 | 内容 |
| --- | --- |
| 阶段 | 第 6 周延伸任务 |
| 难度 | ★★★ |
| 建议工期 | **4～5 个工作日** |
| 基线分支 | `master` |
| 任务池映射 | T01 + T14；缓存一致性专项 |
| 必须评审 | 缓存失效时机、事务提交/回滚行为、业务字段选择 |

---

## 0. 先核对现状

在写代码前逐项验证：

| 已有能力 | 真实位置 |
| --- | --- |
| 字典类型 CRUD / 刷新缓存 | `ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysDictTypeController.java` |
| 字典数据 CRUD | `ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysDictDataController.java` |
| 类型更新与缓存加载 | `ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysDictTypeServiceImpl.java` |
| 数据增删改与缓存刷新 | `ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysDictDataServiceImpl.java` |
| 缓存工具 | `ruoyi-common/src/main/java/com/ruoyi/common/utils/DictUtils.java` |
| 前端管理页 | `ruoyi-ui/src/views/system/dict/index.vue`、`data.vue` |
| 前端 API | `ruoyi-ui/src/api/system/dict/type.js`、`data.js` |
| 业务接入样例 | `ruoyi-ui/src/views/system/user/index.vue` 的 `dicts`、`dict.type` |

当前 `updateDictType` 会把数据库中的字典类型和字典数据改成新编码，并写入新 Redis key，但没有删除旧 key。若旧 key 已被访问并缓存，重命名后仍可能读到过期数据。

提交设计前必须用 Redis key 或接口响应复现一次，写清：旧编码、旧 key、新编码、预期与实际结果。

---

## 1. 本周交付

### W6A：修复字典类型重命名的缓存一致性

目标行为：

1. 重命名前读取旧编码，让旧 key 确实进入缓存。
2. 在一个数据库事务内更新 `sys_dict_type.dict_type` 和对应 `sys_dict_data.dict_type`。
3. 数据库提交成功后，旧 key 必须删除；新 key 必须删除或写入提交后的完整数据。
4. 数据库事务回滚时，不能提前发布一个数据库中不存在的新缓存状态。
5. 旧编码再次查询不得返回重命名前的过期列表；新编码查询结果与数据库一致。

实现方式由实习生先写方案，导师确认后再编码。可选方案包括提交后失效旧/新 key，或提交后重建新 key；无论采用哪种，都必须解释：

- 为什么不能只调用 `setDictCache(newType, ...)`；
- 缓存操作失败时接口与日志如何表现；
- 管理员“刷新缓存”如何作为恢复手段；
- 并发读在提交前后最多可能看到什么。

不要引入新的缓存框架，也不要用“清空所有 Redis”掩盖单 key 一致性问题。

### W6B：把已有字典接入一个真实业务查询

在 **系统管理 → 用户管理** 增加“用户性别”筛选和列表展示：

- 使用现有字典 `sys_user_sex`，不新建 `role_type` 字段或业务表。
- 查询参数使用现有 `SysUser.sex`；Mapper 只使用 `#{sex}` 参数绑定。
- 前端筛选项使用 `dict.type.sys_user_sex`，列表值使用 `dict-tag` 或仓库等价组件。
- 清空筛选后恢复全部用户；非法值不能导致 SQL 错误或绕过其他查询条件。
- `system:user:list` 权限和现有用户列表数据范围必须保持不变。

这个切片用于证明“字典不是只会在字典管理页做 CRUD”，而是贯穿数据库字段、查询对象、Mapper、API 和 Vue 展示。

---

## 2. 修改范围

| 层 | 真实路径 / 建议位置 |
| --- | --- |
| 字典 Service | `ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysDictTypeServiceImpl.java` |
| 缓存工具 | 优先复用 `ruoyi-common/src/main/java/com/ruoyi/common/utils/DictUtils.java`；只在缺少通用能力时小改 |
| 用户查询 | `SysUser.java`、`SysUserMapper.java`、`SysUserMapper.xml` |
| 用户 Controller | 现有 `ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysUserController.java` 通常无需新增接口 |
| 用户前端 | `ruoyi-ui/src/views/system/user/index.vue` |
| 字典前端 | 仅用于复现和回归，不重写现有 CRUD 页面 |

本任务不新增数据库列、不实现树形字典、不增加“角色类型”，也不修改 JWT、Security 或全局 Redis 配置。

---

## 3. 缓存与事务契约

| 场景 | 必须满足 |
| --- | --- |
| 只修改字典名称/备注，编码不变 | 当前编码的缓存最终与数据库一致 |
| `old_type` 重命名为 `new_type` | 旧 key 不再返回数据，新 key 返回完整且排序正确的数据 |
| 新编码已存在 | 唯一性校验阻止修改，数据库和缓存均不变 |
| 更新字典数据时数据库失败 | 不把未提交数据写入缓存 |
| 数据库成功、缓存清理失败 | 不回滚已提交数据库；记录可定位的错误，并可通过“刷新缓存”恢复 |
| 连续重命名两次 | 不遗留任一个历史 key |

禁止把 Redis 与 MySQL 描述成一个天然原子事务。技术笔记中要明确这是跨资源一致性问题，并说明本任务采用的最终一致策略。

---

## 4. 验收矩阵

### 缓存一致性

- [ ] 先访问旧编码并确认 Redis 中存在旧 key，再执行重命名
- [ ] 数据库类型表、数据表、新 key、旧 key四处结果一致
- [ ] 不点“刷新缓存”也能通过正常读请求得到新数据
- [ ] 重命名到重复编码时请求失败，旧数据和旧缓存仍可用
- [ ] 人为制造事务回滚，证明新 key 没有泄漏未提交数据
- [ ] 人为制造缓存清理失败，日志包含字典 ID、旧编码、新编码且不含敏感配置

### 业务接入

- [ ] 用户页性别筛选来自 `sys_user_sex`，不是前端硬编码选项
- [ ] 男、女、未知、清空筛选四种结果与数据库一致
- [ ] 列表显示字典标签；未知历史值有可理解的兜底，不使页面空白
- [ ] 无 `system:user:list` 权限直调仍为 403
- [ ] 数据范围受限账号筛选后不会看到范围外用户

### 回归

- [ ] 字典类型和字典数据的新增、修改、删除、导出、刷新缓存仍可用
- [ ] 用户新增/编辑中的性别字典仍可用
- [ ] Redis 不可用时的现象、恢复步骤和未验证风险已记录

---

## 5. 推荐拆分

1. **第 1 天：** 画出读缓存、查库、回填、类型重命名时序；提交缺陷复现证据和修复方案。
2. **第 2～3 天：** 实现 W6A，覆盖提交成功、唯一性失败和事务回滚。
3. **第 4 天：** 完成用户性别筛选与标签展示，联调权限和数据范围。
4. **第 5 天：** 回归、Review 修正、整理笔记和 PR 证据。

---

## 6. 必交证据

- 修复前/修复后的 Redis key 与接口响应对比
- 缓存时序图，标出数据库事务提交点
- 用户性别筛选的 Network 请求、Mapper 条件和页面结果
- 完整验收矩阵；至少一条失败路径和一条回滚路径
- `docs/intern/notes/W6-notes.md`：解释 cache-aside、旧 key 缺陷、跨资源为何不能声称强一致

不得只提交“点页面正常”的截图，也不得把手工点击“刷新缓存”作为修复本身。
