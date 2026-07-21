# 前端结构、UI 与配色

## 前端启动与依赖

| 项 | 证据 |
| --- | --- |
| 工程 | `ruoyi-ui`，`package.json` name=`ruoyi` version=`3.9.2` |
| 框架 | Vue 2 + Vue Router 3 + Vuex + Element UI `2.15.14` + Vue CLI |
| 启动 | `main.js` 引入 Element 主题 SCSS、全局样式、router/store、`permission` 守卫、全局组件（Pagination/Editor/FileUpload 等）（`ruoyi-ui/src/main.js:1-40`） |
| HTTP | `axios` `0.30.3`；请求封装 `utils/request.js` |
| 脚本 | `dev` / `build:prod` / `build:stage`（`package.json` scripts） |

样式加载顺序（`main.js:7-10`）：`element-variables.scss` → `index.scss` → `ruoyi.scss`，再叠加布局与页面局部样式。

## 信息架构与路由

| 概念 | 实现 | 位置 |
| --- | --- | --- |
| 常量路由 | 登录、首页壳、404 等 | `router/index.js` `constantRoutes` |
| 本地动态路由 | 按权限挂载的受限页 | `router/index.js` `dynamicRoutes` |
| 守卫 | Token / 白名单 / 锁屏 / GetInfo+GenerateRoutes | `permission.js:18-66` |
| 白名单 | `/login`、`/register` | `permission.js:12-16` |
| 后端菜单 | `getRouters` → `filterAsyncRouter` | `store/modules/permission.js:33-49` |
| 组件解析 | Layout / ParentView / InnerLink / `loadView` | `permission.js:56-71`、`113-119` |
| 权限指令 | `directive` 插件（按钮级） | `main.js:14` |

业务信息架构由数据库菜单驱动，前端不硬编码完整侧边栏树；系统管理、监控、工具等页面位于 `views/system`、`views/monitor`、`views/tool`。

## 应用框架布局

主壳 `layout/index.vue`：

- 结构：`sidebar` + `main-container`（`navbar` / 可选 `tags-view` / `app-main` / 可选 settings）（`layout/index.vue:2-10`）。
- 主题 CSS 变量：`--current-color`、`--current-color-light`、`--current-color-dark-bg` 绑定 store 主题色（`layout/index.vue:2`）。
- 侧栏宽度令牌：`$base-sidebar-width: 200px`（`variables.scss:24`）；折叠宽约 54px（`sidebar.scss:203-204`）。
- 移动端遮罩：`device==='mobile'` 时 drawer 背景点击关闭（`layout/index.vue:3`）。
- 固定头：`fixedHeader` 默认 true（`settings.js:45-46`）；主区宽度 `calc(100% - sidebar)`（`layout/index.vue:100-105`）。

侧栏主题色来自 SCSS 变量与 `sideTheme`（`Sidebar/index.vue:2-11`；`Logo.vue`）。

## 页面与组件模式

**登录页**（`views/login.vue`）：背景图 + 白色卡片表单；文案色 `#707070` / 占位 `#bfbfbf`；卡片背景 `#ffffff`。

**典型 CRUD**（如 `views/system/user/index.vue`）：

- `app-container` 包裹查询 `el-form` + 工具栏按钮 + `el-table` + `pagination` + `el-dialog` 编辑。
- 权限按钮依赖 `v-hasPermi` 等指令与后端权限串一致。

**全局组件**（`main.js` 注册）：

| 组件 | 用途 | 备注 |
| --- | --- | --- |
| `Pagination` / `RightToolbar` | 列表分页与列工具 | 标准后台模式 |
| `FileUpload` / `ImageUpload` | 上传 | 走通用上传 API |
| `ImagePreview` | 预览 | — |
| `Editor` | 富文本（Quill） | 内容可能含 HTML，出站渲染需注意 XSS |
| `DictTag` / `DictData` | 字典展示 | — |

## 样式加载与覆盖关系

1. **Element 主题变量** `element-variables.scss` 覆盖 `$--color-primary` 等并 `@import` Element chalk 源（`element-variables.scss:7-25`）。
2. **全局** `index.scss`：reset、基础排版，并去除部分默认 focus outline（`index.scss:43-57`）。
3. **业务** `ruoyi.scss`：工具类、表格、移动端断点等。
4. **侧栏** `sidebar.scss`：依赖 `variables.scss` 菜单色与宽度。
5. **组件/页面** scoped 或局部样式覆盖。

`:export` 将 SCSS 变量导出给 JS（侧栏色、主题主色）（`variables.scss:28-39`；`element-variables.scss:29-31`）。

## 色彩系统

### 规范令牌（全局）

| 令牌 | 值 | 用途 | 归属 | 范围 |
| --- | --- | --- | --- | --- |
| `$--color-primary` | `#1890ff` | Element 主色 / 主题导出 | `element-variables.scss:7` | 全局组件主题 |
| `$--color-success` | `#13ce66` | 成功态 | `element-variables.scss:8` | Element |
| `$--color-warning` | `#ffba00` | 警告态 | `element-variables.scss:9` | Element |
| `$--color-danger` | `#ff4949` | 危险态 | `element-variables.scss:10` | Element |
| `$--border-color-light` | `#dfe4ed` | 浅边框 | `element-variables.scss:17` | Element |
| `$--border-color-lighter` | `#e6ebf5` | 更浅边框 | `element-variables.scss:18` | Element |
| `$--table-border` | `1px solid #dfe6ec` | 表格边框 | `element-variables.scss:20` | Element 表 |
| `$base-menu-color` | `#bfcbd9` | 深色侧栏文字 | `variables.scss:12` | 侧栏 |
| `$base-menu-color-active` | `#ffffff` | 侧栏激活文字 | `variables.scss:13` | 侧栏 |
| `$base-menu-background` | `#1a1f2e` | 深色侧栏背景 | `variables.scss:14` | 侧栏 |
| `$base-logo-title-color` | `#ffffff` | 深色 Logo 标题 | `variables.scss:15` | Logo |
| `$base-menu-light-color` | `rgba(0,0,0,.70)` | 浅色侧栏文字 | `variables.scss:17` | 侧栏 light |
| `$base-menu-light-background` | `#ffffff` | 浅色侧栏背景 | `variables.scss:18` | 侧栏 light |
| `$base-logo-light-title-color` | `#001529` | 浅色 Logo 标题 | `variables.scss:19` | Logo light |
| `$base-sub-menu-background` | `#141824` | 深色子菜单背景 | `variables.scss:21` | 侧栏子级 |
| `$base-sub-menu-hover` | `rgba(255,255,255,.06)` | 子菜单悬停 | `variables.scss:22` | 侧栏子级 |

### 辅助色板（variables.scss，偏历史/装饰）

| 名 | 值 | 行 |
| --- | --- | --- |
| `$blue` | `#324157` | 2 |
| `$light-blue` | `#3A71A8` | 3 |
| `$red` | `#C03639` | 4 |
| `$pink` | `#E65D6E` | 5 |
| `$green` / `$panGreen` | `#30B08F` | 6、9 |
| `$tiffany` | `#4AB7BD` | 7 |
| `$yellow` | `#FEC171` | 8 |

### 页面一次性颜色示例

| 值 | 用途 | 位置 |
| --- | --- | --- |
| `#707070` | 登录页文案 | `login.vue` |
| `#bfbfbf` | 登录占位 | `login.vue` |
| `#ffffff` | 登录卡片底 | `login.vue` |

**观察：** 主色以 Element `#1890ff` 为权威；侧栏中性色在 `variables.scss` 独立维护；辅助色板与主色体系并存，部分页面仍可能硬编码。

## 字体、尺寸、间距与层级

| 项 | 值/行为 | 证据 |
| --- | --- | --- |
| 侧栏宽 | 200px；折叠 54px | `variables.scss:24`；`sidebar.scss:203-204` |
| 菜单项高 | 44px 行高 | `sidebar.scss:77-78` |
| 布局高度 | `100%` / `100vh` 壳层 | `layout/index.vue:71-90` |
| 按钮字重 | `$--button-font-weight: 400` | `element-variables.scss:13` |
| 内容区 | `app-container` 等工具类 | `ruoyi.scss` |
| 层级 | 顶栏/页签/侧栏/抽屉由 Element 与布局 class 控制 | layout 组件族 |

完整字号阶梯未集中在单一 design token 文件，多依赖 Element 默认与局部 SCSS。

## 主题能力

| 能力 | 默认 | 实现 |
| --- | --- | --- |
| 侧栏深/浅 | `sideTheme: 'theme-dark'` | `settings.js:10`；Settings 面板切换 `theme-dark`/`theme-light` |
| 主题色 | Element primary，可运行时写入 CSS 变量 | `layout/index.vue:2`；Settings 取色 |
| 导航模式 | `navType: 1` 纯左侧；支持混合/顶部 | `settings.js:21`；Settings `handleNavType` |
| TagsView | 开；样式 card/chrome | `settings.js:26-41` |
| 固定头/Logo | 开 | `settings.js:45-51` |
| 暗色内容区 | **无完整 dark content theme** | 主要是侧栏深浅 + 主题色，不是全局 dark mode |

主题状态在 Vuex `settings` 模块，并可与布局设置面板联动持久化（以 settings store 实现为准）。

## 响应式行为

| 断点/行为 | 位置 |
| --- | --- |
| `max-width: 768px` | `ruoyi.scss:147` |
| `max-width: 991px` AppMain | `AppMain.vue:93`、`108` |
| `max-width: 550px` 仪表盘 | `dashboard/PanelGroup.vue:163` |
| `max-width: 1024px` | `index_v1.vue:93` |
| 移动侧栏抽屉 | `layout/index.vue` `device==='mobile'` |

**观察：** 后台以桌面为先；移动端通过隐藏/抽屉侧栏与部分栅格断点适配，复杂表格页在小屏仍可能横向滚动（实现层面常见，非单独无障碍缺陷结论）。

## 可访问性审计

| 观察 | 证据 | 说明 |
| --- | --- | --- |
| 全局去除 `a`/`div` focus outline | `index.scss:43-57`；`Navbar.vue:197-198` | 键盘焦点可见性被削弱 |
| `aria-*` 使用少 | Settings 图标等零星 `aria-label`/`aria-hidden` | 非系统化 a11y |
| SvgIcon `aria-hidden` | `SvgIcon/index.vue:3` | 装饰图标合理，但需保证旁路文本 |
| `v-html` 渲染 | 公告详情、搜索高亮、代码预览等 | 见 `HeaderNotice/DetailView.vue:45` 等 |
| 可点击非语义节点 | Settings 主题块等 `@click` 在 `div` 上 | `Settings/index.vue:31+` |
| 表单 | 大量 Element `el-form`/`label` | 依赖组件默认，未统一审计每个必填关联 |

**实现观察（非已确认漏洞）：** 焦点轮廓被全局关闭会降低键盘用户可感知性；富文本与 `v-html` 需配合后端消毒与 CSP 策略（交叉见安全文档）。

## UI 一致性观察

1. 主色与状态色在 Element 变量层统一，侧栏中性色单独一套，整体视觉接近 Ant/Element 管理台惯例。
2. 布局尺寸令牌有限（侧栏宽、菜单高），间距/字号未形成完整 design token 文档化体系。
3. 主题能力偏“侧栏皮肤 + 主色”，不是完整亮/暗内容主题。
4. CRUD 页面模式高度一致，利于生成器与二次开发，也导致自定义页面易复制样板而非抽取更高阶模式。
5. 登录页与后台壳层色板略分离（登录硬编码灰色文案）。

## 维护建议

1. 将主色、中性色、状态色、侧栏色收敛到单一 token 源，减少 `variables` 与页面硬编码分叉。
2. 恢复可见的 `:focus-visible` 样式，避免 `outline: none` 一刀切。
3. 为 `v-html` 出口建立白名单消毒约定，并在 UI 组件层标注“可信 HTML only”。
4. 若需真·暗色模式，单独设计内容区 token，而不是仅切换侧栏 `theme-dark`。
5. 响应式以表格/对话框溢出策略为优先补强点（小屏操作路径）。
