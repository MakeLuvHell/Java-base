# 任务书 W6：字典管理（新增 + 增删改查）

> **前置要求：** 已通过 W1～W5（环境能登录、用户管理基础功能）。
> **零基础说明：** 字典是 Ruoyi 框架中非常重要的**配置驱动**模块。它让系统支持动态下拉框和可扩展配置。实习生需要完成字典类型的**新增 + 字典数据的增删改查**，并理解字典如何被业务页面使用。

| 项 | 内容 |
| --- | --- |
| 阶段 | 第 6 周 |
| 难度 | ★★ |
| 建议工期 | **4 个工作日**（第 1 天设计，第 4 天 PR 联调） |
| 分支 | `feature` |
| 基线分支 | `master` |
| 任务池映射 | T01 + T13 + T14 |

---

## 0. 大白话：为什么要学字典？

字典就是**让系统变得可配置**的工具。

以后新增一个下拉选项（如「公告类型」），**不需要改前端代码**，只需要在字典里新增一行数据即可。

**本任务目标：**
- 让实习生真正理解字典的核心概念
- 能新增字典类型和字典数据
- 能查看字典下拉框在业务页面是如何使用的

---

## 1. 功能说明

### 1.1 字典类型管理（sys_dict_type）
- 新增、修改、删除字典类型
- 字典类型编码必须唯一（如：`sys_notice_type`、`sys_user_status`）
- 备注信息（可选）

### 1.2 字典数据管理（sys_dict_data）
- 在字典类型下新增/编辑/删除字典数据
- 字段包括：字典码、字典名、字典值、排序、状态、颜色
- 支持树形展示（可选）

### 1.3 业务页面使用字典
- 在**用户管理**页面新增一个「状态」下拉框，使用字典数据
- 在**角色管理**页面新增一个「角色类型」下拉框，使用字典数据

---

## 2. 范围（必须遵守）

### 2.1 只改的地方
| 层 | 可能路径 |
| --- | --- |
| 后端 Controller | `ruoyi-system/.../controller/system/DictTypeController.java`、`DictDataController.java` |
| 后端 Service | `ISysDictTypeService`、`SysDictTypeServiceImpl.java`、`ISysDictDataService`、`SysDictDataServiceImpl.java` |
| 后端 Mapper | `SysDictTypeMapper.java`、`SysDictDataMapper.java` + `*.xml` |
| 后端 Domain | `SysDictType.java`、`SysDictData.java` |
| 前端 | `ruoyi-ui/src/views/system/dict/` 目录下所有 `.vue` 文件 |
| 前端 API | `ruoyi-ui/src/api/system/dict.js` |
| 菜单权限 | `sys_menu` 表 |

### 2.2 不要做
- 大范围重构
- 改 `SecurityConfig` 或 JWT 相关逻辑
- 新建独立业务表

---

## 3. 推荐默认实现

| 项 | 默认值 |
| --- | --- |
| 字典类型编码规则 | 唯一字符串（如 `sys_notice_type`） |
| 字典数据字段 | 字典码、字典名、字典值、排序（数字）、状态 |
| 前端下拉框组件 | `el-select` 或 `el-cascader` |
| 字典值存储格式 | 通常存储在 `dict_value` 字段 |
| 字典缓存 | 可选开启 Redis 缓存（可选） |

---

## 4. 验收标准
1. 本地能启动后端 + 前端
2. 管理员能**新增字典类型**并保存
3. 能为字典类型**新增、修改、删除字典数据**
4. 在**用户管理**页面能正常显示使用字典的数据下拉框
5. 无对应权限的用户无法操作字典相关接口
6. 字典数据能正常显示在下拉框中
7. PR 描述包含：改动摘要 + 自测步骤 + 截图

---

## 5. 技术笔记（必交）

实习生需要写以下内容：
1. 字典的核心概念（为什么用字典？）
2. `sys_dict_type` 和 `sys_dict_data` 两张表的字段说明
3. 字典在**用户管理**页面是如何使用的（截图 + 代码片段）
4. 字典的查询优化思路（缓存到 Redis）
5. 字典类型编码命名规范

---

## 6. 推荐任务拆分（第 1 天设计 → 第 4 天 PR）

### 第 1 天（设计日）
- 完成功能描述 + 接口设计 + 前后端接口文档
- 画流程图 + 组件设计
- 理解字典在业务页面是如何被使用的

### 第 2～3 天
- 后端实现（字典类型 + 字典数据 CRUD）
- 前端实现（字典类型列表 + 字典数据列表 + 下拉框使用）

### 第 4 天
- 联调 + 回归测试 + 写技术笔记 + PR

---

## 7. 参考实现（对照学习）

- 字典类型列表：`ruoyi-system/system-dict-type/index.vue`
- 字典数据列表：`ruoyi-system/system-dict-data/index.vue`
- 业务页面使用字典：`ruoyi-ui/src/views/system/user/index.vue`
- 导出功能：`SysPostController.export`

---