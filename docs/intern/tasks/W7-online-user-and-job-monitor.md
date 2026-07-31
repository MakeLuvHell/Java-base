# 任务书 W7：在线用户管理增强 + 定时任务执行监控面板

> **前置要求：** 已通过 W1～W6（用户管理、公告模块、字典管理等基础能力）。
> **零基础说明：** 本周做两个模块的增量功能。一个是「在线用户」页面的增强，一个是「定时任务」执行日志的统计监控面板。都是已有后端接口基础上的前后端增量开发，不涉及基础设施改造。

| 项 | 内容 |
| --- | --- |
| 难度 | ★★ |
| 建议工期 | **4 个工作日**（第 1 天设计，第 4 天 PR 联调） |
| 基线分支 | `master` |
| 任务池映射 | T13（筛选/导出扩展） + T14（模块文档） |

---

## 0. 大白话：本周你要交付什么？

### 模块 A：在线用户管理增强

在 **监控 → 在线用户** 页面，现在只有「按 IP/用户名筛选 + 单个强退」。你要增加：

| 能力 | 用户能感知到什么 |
| --- | --- |
| 批量强退 | 勾选多个在线用户，一键全部强退 |
| 按部门筛选 | 在筛选栏新增「部门树」下拉，按部门过滤在线用户 |
| 在线统计卡片 | 页面顶部显示当前在线总人数、admin 在线数、最近 1 小时登录人数 |

### 模块 B：定时任务执行监控面板

在 **监控 → 定时任务** 的「调度日志」标签页，现在只有原始日志列表。你要增加：

| 能力 | 用户能感知到什么 |
| --- | --- |
| 执行统计卡片 | 显示总执行次数、成功次数、失败次数、成功率（筛选范围内） |
| 失败原因 Top5 | 展示出现最多的 5 条失败消息 |
| 平均耗时 Top5 | 展示执行最慢的 5 个任务 |
| 最近 7 天趋势图 | 用柱状图展示近 7 天的成功/失败数量分布 |

### 本周明确不要做

| 不要做 | 为什么 |
| --- | --- |
| 大改 `SecurityConfig` / JWT 密钥逻辑 | 与本任务无关，风险高 |
| 新建独立业务表 | 保持在现有模块内 |
| 前端改样式 / 换主题 | 与功能实现无关 |
| 引入 ECharts 以外的第三方图表库 | 用 ECharts 或 Element UI 内置组件即可 |
| 把密码提交到 Git | **红线** |

---

## 1. 范围（必须遵守）

### 1.1 允许改的地方

| 层 | 可能路径 |
| --- | --- |
| 后端 Controller | `ruoyi-admin/.../controller/monitor/SysUserOnlineController.java` |
| 后端 Controller | `ruoyi-quartz/.../controller/SysJobLogController.java` |
| 后端 Service | `ISysUserOnlineService`、`ISysJobLogService` 及实现 |
| 后端 Domain | `SysUserOnline.java`、`SysJobLog.java` |
| 后端 Mapper XML | `SysJobLogMapper.xml`（新增统计查询） |
| 前端 | `ruoyi-ui/src/views/monitor/online/index.vue` |
| 前端 | `ruoyi-ui/src/views/monitor/job/log.vue` |
| 前端 API | `ruoyi-ui/src/api/monitor/online.js`、`ruoyi-ui/src/api/monitor/jobLog.js` |

### 1.2 分支创建

```bash
git checkout master
git pull
git checkout -b feature/<你的名字>-online-user-job-monitor
```

---

## 2. 模块 A：在线用户管理增强

### 2.1 批量强退

- 在线用户列表增加「多选框」（已有 `el-table-column type="selection"` 的用法可参照其他页面）
- 工具栏增加「批量强退」按钮（勾选 0 个时禁用）
- 后端新增 `DELETE /monitor/online/batch/{tokenIds}`，接收多个 token 批量删除 Redis 中的 session

**推荐实现：**
```java
@PreAuthorize("@ss.hasPermi('monitor:online:forceLogout')")
@Log(title = "在线用户", businessType = BusinessType.FORCE)
@DeleteMapping("/batch/{tokenIds}")
public AjaxResult batchForceLogout(@PathVariable String[] tokenIds) {
    for (String tokenId : tokenIds) {
        redisCache.deleteObject(CacheConstants.LOGIN_TOKEN_KEY + tokenId);
    }
    return success();
}
```

### 2.2 按部门筛选

- 前端筛选栏增加部门选择器（参照用户管理页面的 `DeptTree` 组件用法）
- 后端 `list` 接口增加 `deptName` 参数（已有 `ipaddr` + `userName` 两个筛选条件）
- 在遍历 Redis token 列表时，增加部门名称匹配过滤

### 2.3 在线统计卡片

- 后端新增 `GET /monitor/online/stats`，返回：
```json
{
  "totalOnline": 15,
  "adminOnline": 2,
  "recentHourLogin": 8
}
```
- 前端页面顶部用 `el-row` + `el-col` + `el-card` 展示三个统计数字
- 筛选条件变化时，卡片数据同步更新

---

## 3. 模块 B：定时任务执行监控面板

### 3.1 执行统计接口

后端新增 `GET /monitor/jobLog/stats`，接收与列表页相同的筛选参数，返回聚合结果：

```json
{
  "totalCount": 150,
  "successCount": 142,
  "failCount": 8,
  "successRate": 94.67,
  "topFailures": [
    { "jobMessage": "java.lang.NullPointerException", "count": 3 },
    { "jobMessage": "Connection timeout", "count": 2 },
    ...
  ],
  "topSlowJobs": [
    { "jobName": "ryTask.ryParams", "avgCost": 5200 },
    ...
  ],
  "dailyTrend": [
    { "date": "2026-07-25", "success": 20, "fail": 1 },
    { "date": "2026-07-26", "success": 22, "fail": 0 },
    ...
  ]
}
```

### 3.2 统计查询 SQL

在 `SysJobLogMapper.xml` 中新增：

```xml
<!-- 基本统计 -->
<select id="selectJobLogStats" resultType="map">
    select
        count(*) as totalCount,
        sum(case when status = '0' then 1 else 0 end) as successCount,
        sum(case when status != '0' then 1 else 0 end) as failCount
    from sys_job_log
    <where>
        ... (与 list 相同的筛选条件)
    </where>
</select>

<!-- 失败原因 Top5 -->
<select id="selectTopFailures" resultType="map">
    select job_message as jobMessage, count(*) as cnt
    from sys_job_log
    where status != '0'
    group by job_message
    order by cnt desc
    limit 5
</select>

<!-- 平均耗时 Top5 — 注意 sys_job_log 是否有 cost 字段，没有则用 createTime 估算 -->
```

> **提示：** 先查 `sys_job_log` 表结构确认字段。如果 `sys_job_log` 没有「执行耗时」字段，需要在 `SysJobLog` 中新增 `cost_time` 字段（bigint，毫秒），并在 `AbstractQuartzJob.after()` 中写入。

### 3.3 前端展示

在 `log.vue` 页面顶部增加统计区域：

- 第一行：四个统计卡片（总次数 / 成功 / 失败 / 成功率）
- 第二行：左侧「失败原因 Top5」表格 + 右侧「最近 7 天趋势」柱状图

**图表选型：**
- 如果项目已有 ECharts 依赖（检查 `package.json`），直接用 `v-charts` 或 ECharts 原生组件
- 如果没有，用 Element UI 的 `el-card` + `el-progress` 组合展示（成功率用进度条，Top5 用表格）

---

## 4. 验收标准

### 模块 A（在线用户增强）

1. 本地能启动后端 + 前端
2. 在线用户列表支持多选 + 批量强退
3. 按部门名称筛选在线用户
4. 页面顶部统计卡片数字正确
5. 无 `monitor:online:forceLogout` 权限的用户批量强退接口返回 **403**

### 模块 B（定时任务监控）

6. 调度日志页面顶部显示统计卡片
7. 筛选条件变化时统计数据和图表同步更新
8. 失败原因 Top5 展示正确
9. 最近 7 天趋势图数据正确
10. 无 `monitor:job:list` 权限的用户统计接口返回 **403**

### 通用

11. PR 描述包含：改动摘要 + 自测步骤 + 截图
12. 后端所有新接口有 `@PreAuthorize` + `@Log` 注解

---

## 5. 技术笔记（必交）

写以下内容到 `docs/intern/notes/W7-notes.md`：

1. **在线用户**是如何从 Redis 中提取的（Token key 规律 + 遍历逻辑）
2. **批量强退**的权限控制（为什么不能只做前端按钮隐藏）
3. **定时任务执行日志**的写入链路（`AbstractQuartzJob` → `before/after` → `SysJobLogMapper`）
4. **聚合查询 SQL** 的写法（CASE WHEN 条件聚合 + GROUP BY + LIMIT）

---

## 6. 推荐任务拆分

### 第 1 天（设计日）
- 读 `SysUserOnlineController` + `SysJobLogController` + 对应前端代码
- 画页面草图（统计卡片放哪、图表用哪种）
- 确认 `sys_job_log` 表结构（有没有 cost_time 字段）
- 完成接口设计文档

### 第 2 天
- 模块 A 后端：批量强退接口 + 统计接口 + 部门筛选
- 模块 B 后端：聚合统计 SQL + 统计接口

### 第 3 天
- 模块 A 前端：多选 + 批量强退按钮 + 部门筛选 + 统计卡片
- 模块 B 前端：统计卡片 + 失败原因表格 + 趋势图

### 第 4 天
- 联调 + 回归测试 + 权限 403 验证 + 技术笔记 + PR

---

## 7. 参考实现

| 参考什么 | 在哪看 |
| --- | --- |
| 多选 + 批量操作 | 用户管理页面 `ruoyi-ui/src/views/system/user/index.vue` |
| 部门树筛选组件 | `ruoyi-ui/src/components/DeptTree.vue` |
| 导出功能 | `SysPostController.export` + 前端 `handleExport` |
| Redis 删除 session | `SysUserOnlineController.forceLogout` |
| 操作日志列表筛选 | `ruoyi-ui/src/views/monitor/operlog/index.vue` |
| 统计卡片布局 | `ruoyi-ui/src/views/dashboard/`（首页 Dashboard） |

---