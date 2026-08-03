# 任务书 W7：在线会话增强与调度日志统计

> **前置要求：** 已通过 W1～W6；本地已导入 `quartz.sql`，能打开在线用户和调度日志页面。
> **任务性质：** 本周在两个现有监控模块上做真实增量，重点是会话口径、批量危险操作、聚合 SQL、可复现 fixture 和图表生命周期。

| 项 | 内容 |
| --- | --- |
| 阶段 | 第 7 周延伸任务 |
| 难度 | ★★★★ |
| 建议工期 | **6～8 个工作日**；拆成 W7A/W7B/W7C 三个 PR |
| 基线分支 | `master` |
| 任务池映射 | T12 + T14；聚合 SQL 与可视化专项 |
| 必须评审 | 指标口径、批量强退权限、统计筛选范围、fixture 清理 |

---

## 0. 先确认四个事实

1. 在线列表遍历的是 Redis `login_tokens:*`，一条记录代表一个**会话**，不是一个自然人。
2. `LoginUser.loginTime` 会在 token 刷新时更新，不能拿它当“首次登录时间”或“最近一小时登录人数”。
3. 调度失败详情写在 `sys_job_log.exception_info`；`job_message` 只是任务名称和耗时说明。
4. `sys_job_log` 已有 `start_time` / `end_time`，本任务用二者计算耗时，不新增 `cost_time`。

设计文档和页面文案必须使用上述口径，不能继续沿用“在线总人数”“按 `job_message` 统计异常”或“用 `create_time` 估算耗时”的说法。

---

## 1. W7A：在线会话增强

### 1.1 批量强退

在在线用户列表增加多选和批量强退，推荐接口：

```http
DELETE /monitor/online/batch/{tokenIds}
```

- 使用初始化 SQL 已存在的权限 `monitor:online:batchLogout`，不要误用单条权限 `monitor:online:forceLogout`。
- `tokenIds` 去重后限制为 1～100 个；不存在或已退出的 token 按幂等删除处理。
- 前端显示将要强退的会话数并二次确认；0 个选中时按钮禁用。
- 写操作保留 `@Log`；列表、统计等只读接口遵循现有风格，不强加操作日志。
- 无批量权限用户即使能看列表，直调批量接口也必须返回 403。

### 1.2 按部门筛选

`LoginUser` 已有 `deptId`，但 `SysUserOnline` 目前只暴露 `deptName`。本任务为在线会话 DTO 补 `deptId`，列表接口按精确 `deptId` 过滤。

部门选择项由在线模块自己的只读接口返回“当前会话中出现的部门”，例如：

```http
GET /monitor/online/deptOptions
Permission: monitor:online:list
```

返回去重后的 `{deptId, deptName}`。不要依赖需要 `system:user:list` 的用户部门树接口，也不要用部门名称模糊匹配代替稳定 ID。

### 1.3 会话统计

新增 `GET /monitor/online/stats`，使用 `monitor:online:list`，并接受与在线列表一致的 `ipaddr`、`userName`、`deptId`：

```json
{
  "totalSessions": 15,
  "uniqueUsers": 12,
  "adminSessions": 2,
  "departmentCount": 5
}
```

| 指标 | 固定定义 |
| --- | --- |
| `totalSessions` | 筛选后 token 数 |
| `uniqueUsers` | 筛选后去重 `userId` 数 |
| `adminSessions` | `userId=1` 的会话数 |
| `departmentCount` | 筛选后非空 `deptId` 去重数 |

列表和统计必须复用同一套过滤函数，避免页面显示 10 行但卡片统计 12。Redis 中存在空值、过期值或缺少用户对象时跳过并记录可诊断日志，不能让整个接口空指针失败。

---

## 2. W7B：调度日志统计后端

新增 `GET /monitor/jobLog/stats`，权限复用 `monitor:job:list`。统计接口不写 `@Log`。

### 2.1 查询契约

支持 `jobName`、`jobGroup`、`invokeTarget`、`beginTime`、`endTime`：

- 起止日期必须成对出现，含首尾日期。
- 未传日期时默认今天往前 6 天，共 7 个自然日。
- 最大范围 31 天；超出直接返回参数错误，不执行无界聚合。
- 统计区不接受 `status` 参数。成功、失败和失败原因本身已经按状态分组，避免筛选状态后产生自相矛盾的卡片。
- 所有统计 SQL 复用同一个基础筛选片段；`jobName` / `invokeTarget` 模糊查询必须使用 `#{}`。

推荐响应：

```json
{
  "range": { "beginDate": "2026-07-25", "endDate": "2026-07-31" },
  "totalCount": 150,
  "successCount": 142,
  "failureCount": 8,
  "successRate": 94.67,
  "topFailures": [
    { "reason": "java.lang.NullPointerException", "count": 3 }
  ],
  "topSlowJobs": [
    { "jobName": "reportJob", "jobGroup": "DEFAULT", "avgDurationMs": 5200 }
  ],
  "dailyTrend": [
    { "date": "2026-07-25", "successCount": 20, "failureCount": 1 }
  ]
}
```

### 2.2 固定统计口径

| 项 | 规则 |
| --- | --- |
| 成功 / 失败 | `status='0'` 为成功，其余为失败 |
| 成功率 | `successCount / totalCount * 100`，四舍五入 2 位；总数为 0 时返回 `0` |
| 失败原因 Top5 | 只看失败记录；取 `exception_info` 第一行并截断到 200 字符后分组，空值归为“未记录异常” |
| 平均耗时 Top5 | `end_time >= start_time` 且两者非空；按 `job_name + job_group` 分组，使用二者差值计算毫秒平均值 |
| 每日趋势 | 覆盖有效日期范围内每一天；无日志日期由 Service 补 0，按日期升序 |

MySQL 可用 `TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000` 计算毫秒。禁止解析 `job_message` 中的中文耗时字符串，也不要用 `create_time` 代替起止时间。

### 2.3 可复现 fixture

交付仅供本地/测试使用的 `sql/intern/W7-job-log-fixture.sql` 和清理脚本，数据使用唯一前缀 `intern_w7_`，至少包含：

- 连续 7 天的成功和失败记录；
- 相同异常首行、不同堆栈的失败记录；
- 5 个以上任务及可排序的耗时；
- `start_time` / `end_time` 为空和结束早于开始的脏数据；
- 某一天完全没有记录。

fixture 禁止连接或写入共享/生产库；清理语句只能匹配 `intern_w7_` 数据，不得 `TRUNCATE sys_job_log`。

---

## 3. W7C：统计前端

在 `ruoyi-ui/src/views/monitor/job/log.vue` 增加未嵌套的统计区域：

- 四个紧凑统计项：总次数、成功、失败、成功率；
- 失败原因 Top5 表格；
- 平均耗时 Top5 表格；
- 每日成功/失败趋势柱状图，标题显示响应中的有效日期范围。

项目已安装 ECharts，直接使用原生 ECharts，不引入 `v-charts` 或第二套图表库。组件必须：

- 在数据刷新时更新 series，不重复创建实例；
- 监听容器尺寸变化并 `resize`；
- 在组件销毁时解除监听并 `dispose`；
- 对加载中、空数据、403、网络失败分别呈现稳定状态；
- 小屏下表格和图表换行，不能遮住列表或筛选栏。

统计区使用自己的日期范围和任务筛选，点击查询时一次刷新全部统计；下方原日志列表保留原有状态筛选和分页行为。

---

## 4. 修改范围

| 层 | 真实路径 / 建议位置 |
| --- | --- |
| 在线 Controller | `ruoyi-admin/src/main/java/com/ruoyi/web/controller/monitor/SysUserOnlineController.java` |
| 在线 Service / DTO | `ruoyi-system/src/main/java/com/ruoyi/system/service/ISysUserOnlineService.java`、`ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserOnlineServiceImpl.java`、`ruoyi-system/src/main/java/com/ruoyi/system/domain/SysUserOnline.java` |
| 调度 Controller / Service / Mapper | `ruoyi-quartz/src/main/java/com/ruoyi/quartz/` |
| 调度 XML | `ruoyi-quartz/src/main/resources/mapper/quartz/SysJobLogMapper.xml` |
| 在线前端 | `ruoyi-ui/src/views/monitor/online/index.vue`、`src/api/monitor/online.js` |
| 调度前端 | `ruoyi-ui/src/views/monitor/job/log.vue`、`src/api/monitor/jobLog.js` |
| fixture | `sql/intern/` 下本任务专用升级/清理脚本 |

不新增业务表，不修改 `AbstractQuartzJob` 的日志写入格式，不修改 Security/JWT，也不引入新的图表依赖。

---

## 5. 验收矩阵

### 在线会话

- [ ] 同一用户开两个浏览器登录时，`totalSessions=2`、`uniqueUsers=1`
- [ ] 列表、部门选项和统计使用同一个 `deptId` 口径
- [ ] 批量强退 2 个会话后两个 token 均失效；重复请求结果幂等
- [ ] 只有 `monitor:online:list` 的账号能看统计，但批量接口为 403
- [ ] 只有批量权限、没有单条权限及反向组合均按各自权限工作
- [ ] Redis 中加入空/损坏测试值后，合法会话仍能返回且无 500

### 调度统计

- [ ] fixture 下总数、成功、失败、成功率与手工 SQL 一致
- [ ] 失败 Top5 来自 `exception_info`，相同首行能正确聚合
- [ ] 平均耗时来自 `start_time/end_time`，空值和负耗时不参与排名
- [ ] 默认 7 天、指定 1 天、指定 31 天、超过 31 天四种边界符合契约
- [ ] 无数据时所有计数为 0、数组稳定、趋势日期完整补 0
- [ ] 无 `monitor:job:list` 权限直调统计接口返回 403

### 前端与回归

- [ ] 图表重复查询、切换路由和调整窗口后没有重复实例、报错或明显内存泄漏
- [ ] API 失败时保留筛选条件，可重试，不显示上一次数据为本次结果
- [ ] 原在线单条强退、原调度日志列表/详情/删除/清空/导出仍可用
- [ ] fixture 清理后只删除 `intern_w7_` 数据

---

## 6. 推荐拆分与必交证据

1. **W7A（2～3 天）：** 会话 DTO、统一过滤、部门选项、统计、批量强退和权限矩阵。
2. **W7B（3 天）：** 查询契约、共享 SQL 条件、聚合结果、日期补零、fixture。
3. **W7C（1～2 天）：** 原生 ECharts、三种数据区、响应式和错误状态。

每个 PR 必须提交：接口示例、关键 SQL、自测命令、403 证据、空数据或失败路径证据。最终补充 `docs/intern/notes/W7-notes.md`，说明：

- 会话数与人数为什么不同；
- 为什么不能用会刷新变化的 `LoginUser.loginTime` 统计登录人数；
- `exception_info` 与 `job_message` 的职责；
- 日期补零放在 Service 而不是前端临时猜测的原因。
