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
| `Editor` | 富文本（Quill） | `dangerouslyPasteHTML` 灌入 HTML（`Editor/index.vue:112,141`），输出 `innerHTML`；公告等业务 `v-html` 展示 |
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
| `$--color-primary` | `#1890ff` | Element 编译期主色 / `:export.theme` | `element-variables.scss:7` | 编译进 Element 主题 |
| runtime `settings.theme` | `#409EFF`（默认可被 localStorage 覆盖） | 运行时主题色 / CSS 变量源 | `store/modules/settings.js:9`；`ThemePicker` `ORIGINAL_THEME` | 与编译主色**不一致** |
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

**观察：**

1. **双主色源：** SCSS 编译主色为 `#1890ff`（`element-variables.scss:7`），运行时默认与 ThemePicker 基准为 `#409EFF`（`settings.js` store:9；`ThemePicker/index.vue:4,11`）。未改主题时，Element 编译色与 `--current-color`/动态换肤基准可能不一致。
2. 侧栏中性色在 `variables.scss` 独立维护；辅助色板（`$blue` 等）与工具类 `.text-success` 等（`ruoyi.scss`）又形成第三套状态色，易漂移。
3. ThemePicker 通过替换 `/styles/theme-chalk/index.css` 色簇实现运行时换肤（`ThemePicker/index.vue:64-79`），预置色含 `#409EFF`、`#1890ff` 等。

## 字体、尺寸、间距与层级

| 项 | 值/行为 | 证据 |
| --- | --- | --- |
| 侧栏宽 | 200px；折叠 54px | `variables.scss:24`；`sidebar.scss:203-204` |
| Navbar 高 | 50px，背景 `#fff` | `Navbar.vue` 样式段 |
| TagsView 高 | 34px | `TagsView/index.vue` |
| AppMain 高 | 无 tags：`calc(100vh-50px)`；有 tags：`calc(100vh-84px)` | `AppMain.vue` |
| 菜单项高 | 44px 行高 | `sidebar.scss:77-78` |
| 布局高度 | `100%` / `100vh` 壳层 | `layout/index.vue:71-90` |
| 按钮字重 | `$--button-font-weight: 400` | `element-variables.scss:13` |
| 内容区 | `app-container` 等工具类 | `ruoyi.scss` |
| 层级 | 侧栏 z-index 约 1001；遮罩 opacity 0.3 | `sidebar.scss`；`layout/index.vue` |

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
| JS `WIDTH = 992` → `mobile` | `layout/mixin/ResizeHandler.js:4` |
| `max-width: 991px` AppMain | `AppMain.vue:93`、`108` |
| `max-width: 768px` 分页简化 | `ruoyi.scss:147` |
| `max-width: 550px` 仪表盘 | `dashboard/PanelGroup.vue:163` |
| `max-width: 1024px` | `index_v1.vue:93` |
| 移动侧栏抽屉 | `layout/index.vue` `device==='mobile'` |

**观察：** JS 以 992 切换 mobile，CSS 多处以 991/768/550/1024 分段，断点不统一；CRUD 业务页几乎无自有 `@media`。小屏表格仍可能横向滚动。

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

1. 编译主色 `#1890ff` 与运行时默认 `#409EFF` 双源，是配色维护的首要不一致点。
2. 侧栏中性色、Element 状态色、`.text-*` 工具类三套并存。
3. 布局尺寸令牌有限（侧栏/顶栏/页签高度可测），间距/字号未文档化。
4. 主题能力偏“侧栏皮肤 + ThemePicker 主色”，无 `prefers-color-scheme` 全站 dark mode。
5. CRUD 页面模式高度一致（用户管理为样板：树 + 表 + 对话框）。
6. 登录页默认填充演示账号（`login.vue` 中 username/password 初始值），与壳层色板分离。

## 维护建议

1. 统一编译主色与 runtime/`ThemePicker` 默认（二选一或构建时同源注入）。
2. 将主色、中性色、状态色、侧栏色收敛到单一 token 源。
3. 恢复 `:focus-visible`；为 Hamburger、Tags 按钮等可点击 `div`/`span` 补 `role`/`tabindex`/可访问名。
4. Editor 出站消毒 + 公告 `v-html` 白名单；避免 `dangerouslyPasteHTML` 直灌不可信内容。
5. 统一 992/991 等断点；CRUD 列表补小屏策略。
6. 生产构建移除或清空登录页演示账号默认值。
