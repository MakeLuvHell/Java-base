# 安全与质量整改路线

## 排序原则

1. 严重度优先：P0 → P1 → P2 → P3（本轮无 P0）。
2. 同级内按：默认可利用面 / 凭据暴露 → 远程运维面 → 注入与 XSS → 供应链与工程化。
3. 先改配置与暴露面（低代码风险），再改代码防御；最后补测试与扫描流水线。
4. 风险 ID 与 [03-security.md](./03-security.md) 保持一致。

## 立即处置（P0）

本轮审计**未确认 P0** 项。若生产已公网暴露且仍使用仓库默认数据库/Druid/JWT 密钥，应**按 P0 应急**处理 SEC-001/002/003（轮换密钥、下线控制台、限制网络），即使台账标为条件性风险。

## 优先整改（P1）

| 顺序 | ID | 动作 | 影响文件/配置 | 兼容性 | 回归验证 |
| --- | --- | --- | --- | --- | --- |
| 1 | SEC-001 | 轮换 `token.secret`，改为环境变量/密钥管理；拒绝默认值启动 | `application.yml`；部署清单；可选 `TokenService` 启动校验 | 所有现有 JWT 失效，用户需重新登录 | 用旧 secret 签发令牌应失败；新登录成功 |
| 2 | SEC-002 | 替换数据源与 Druid 控制台凭据；限制 `allow`；生产关闭或内网化 Druid | `application-druid.yml`；密钥注入 | 需同步更新运维连接信息 | 旧口令无法登录库/控制台；外网访问 `/druid/*` 失败 |
| 3 | SEC-003 | 生产关闭 springdoc UI；`/druid/**`、swagger 不再 permitAll 或仅管理网段 | `SecurityConfig.java`；`application.yml` springdoc；反代规则 | 文档地址变更或不可外网访问 | 未认证访问 swagger/druid 为 401/404 |
| 4 | SEC-007 | 生产禁用代码生成模块或移除依赖；收紧 `tool:gen*` 权限；禁公网 | `ruoyi-admin/pom.xml` 可选排除；菜单权限 SQL；网关 | 开发环境保留 generator | 无权限 403；生产无 gen 路由 |

## 计划整改（P2）

| 顺序 | ID | 动作 | 影响文件 | 兼容性 | 回归验证 |
| --- | --- | --- | --- | --- | --- |
| 5 | SEC-004 | CORS 改为显式 Origin 列表 | `ResourcesConfig.java`；配置项 | 非列表来源前端需加入白名单 | 非信任 Origin 预检失败 |
| 6 | SEC-009 | 敏感附件改为鉴权下载；评估 `/profile/**` permitAll 范围 | `SecurityConfig`；`CommonController`；前端资源 URL | 旧直链可能失效 | 未登录访问上传 URL 失败；登录后成功 |
| 7 | SEC-010 | 公告等富文本服务端消毒；收紧 XSS excludes；审查 `v-html` | `application.yml` xss；notice 服务；前端 DetailView/Editor | 部分合法 HTML 标签可能被剥除 | XSS 样本不执行；正常公告可显示 |
| 8 | SEC-008 | 复核任务白名单包；任务变更双人审计；禁止危险 bean | `Constants.JOB_*`；`SysJobController`；运维制度 | 自定义任务包需加入白名单 | 非法 invokeTarget 被拒 |
| 9 | SEC-006 | 审计所有 `${}`；防止用户输入进入 dataScope；长期改结构化条件 | Mapper XML；`DataScopeAspect` | 需回归数据权限范围 | 各角色数据范围用例 |
| 10 | SEC-012 | CI：JDK17 `mvn package`、OWASP Dependency-Check、锁定前端依赖策略与 audit | CI 配置；不强制提交业务代码 | 构建时间增加 | CI 绿；报告归档 |

## 持续改进（P3）

| 顺序 | ID | 动作 | 影响 | 验证 |
| --- | --- | --- | --- | --- |
| 11 | SEC-005 | 文档化 Token 存储决策；若改 Cookie 则补 CSRF | 前端 auth、SecurityConfig | 存储方案评审记录 |
| 12 | SEC-011 | 生产日志级别与脱敏 | `application.yml` / logback | 生产无 debug 包 |
| 13 | SEC-013 | 补充登录、权限、数据权限、上传集成测试 | `src/test` | CI 测试段 |
| 14 | UI | `:focus-visible`、token 收敛、真暗色可选 | `ruoyi-ui` 样式 | 键盘走查、视觉回归 |

## 跨项依赖

```text
SEC-001/002 凭据轮换 ──┬─► SEC-003 暴露面收敛（先关入口再改凭据也可并行）
                       └─► 会话与连接全部重建

SEC-003 关闭 swagger/druid ──► 运维改为受控通道，避免“关了却仍依赖公网文档”

SEC-007 禁用 generator ──► 与菜单权限、部署模块裁剪一起做

SEC-004 CORS 收紧 ──► 需先盘点所有合法前端 Origin

SEC-009 鉴权下载 ──► 影响已分享的 /profile 直链，需迁移通知

SEC-012 供应链 ──► 不阻塞 P1 配置项，但应在首个修复批次后立即建立
```

## 回归验证矩阵

| 场景 | 覆盖风险 | 步骤要点 |
| --- | --- | --- |
| 登录成功/失败/锁定 | 认证基线 | 验证码错误、密码错误达阈值、成功发令牌 |
| 令牌伪造 | SEC-001 | 默认/错误 secret 签名请求应失败 |
| 方法权限 | 授权基线 | 无 `system:user:list` 等权限返回 403 |
| 数据权限 | SEC-006 | 非管理员仅见范围内数据 |
| 上传下载 | SEC-009 | 非法扩展名、`..` 路径、未登录直链 |
| 任务提交 | SEC-008 | rmi/ldap/http/非白名单目标拒绝 |
| 生成器 | SEC-007 | 无权限/生产关闭 |
| 运维端点 | SEC-002/003 | 外网 druid/swagger |
| CORS | SEC-004 | 非信任 Origin |
| XSS 样本 | SEC-010 | 公告/富文本 |

## 建议实施批次

| 批次 | 目标 | 包含 ID | 建议窗口 |
| --- | --- | --- | --- |
| B0 应急 | 生产若已暴露默认凭据/控制台 | SEC-001、002、003 | 立即 |
| B1 | 配置与暴露面硬化 | SEC-001、002、003、007 | 1 周内 |
| B2 | 浏览器与文件面 | SEC-004、009、010 | 1–2 周 |
| B3 | 任务/SQL 纵深与供应链 | SEC-008、006、012 | 2–4 周 |
| B4 | 工程化与体验 | SEC-005、011、013、UI | 持续 |

每批次结束后更新 [03-security.md](./03-security.md) 中对应项状态，并在 [README.md](./README.md) 验证记录追加命令与结果。
