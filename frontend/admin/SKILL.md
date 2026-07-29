# Skills: Admin Frontend Development

> 本文件定义 Admin 管理后台开发中常用的可复用技能/工作流，供 AI 编码工具调用。

---

## skill: add-crud-page

**描述**: 在 Admin 后台新增一个完整的 CRUD 页面模块（列表页 + Drawer 表单页）。

**前置条件**: Proto 已定义且 generated 层已有对应的类型和 ApiClient service。

### 步骤

```
Step 1: 确认 generated 类型
  检查 src/api/generated/admin/service/v1 中是否存在：
  - xxxservicev1_Xxx 类型定义
  - xxxservicev1_ListXxxResponse 响应类型
  - xxxservicev1_CreateXxxRequest / UpdateXxxRequest / DeleteXxxRequest
  - ApiClient 中已有 xxxService getter

Step 2: 创建 composable
  创建 src/api/composables/xxx.ts
  包含：useListXxxs / fetchListXxxs / useCreateXxx / useUpdateXxx / useDeleteXxx
  包含：xxxStatusList / xxxStatusToColor / xxxStatusToName 等工具函数
  模板见 frontend/admin/AGENTS.md 的 "composables 层模板" 章节

Step 3: 注册导出
  在 src/api/composables/index.ts 中添加 export * from './xxx'

Step 4: 添加 i18n
  zh-CN/enum.json — 枚举翻译（如 status 的 ON/OFF）
  zh-CN/menu.json — 菜单名称
  zh-CN/page.json — 页面文本（列名、按钮文字、表单标签等）
  en-US/ — 同步添加英文翻译

Step 5: 创建路由模块
  创建 src/router/routes/modules/app/xxx.ts
  模板见 AGENTS.md 的 "Step 5: 路由配置" 章节
  路由自动加载（import.meta.glob），无需额外注册

Step 6: 创建列表页
  创建 src/views/app/xxx/index.vue
  包含：搜索表单（formOptions） + 表格（gridOptions） + 操作列 + toolbar-tools
  模板见 AGENTS.md 的 "完整列表页模板" 章节

Step 7: 创建 Drawer 表单页
  创建 src/views/app/xxx/xxx-drawer.vue
  包含：useVbenForm（schema）+ useVbenDrawer（onConfirm/onCancel/onOpenChange）
  模板见 AGENTS.md 的 "Drawer 表单模板" 章节
```

### 关键检查点

- `component` 字段只能用已注册名称（如 `Input`、`Select`、`ApiSelect`，不能用 `AInput`）
- 图标用 `h(LucideXxx)` 渲染，从 `@vben/icons` 导入
- 页面必须用 `<Page auto-content-height>` 包裹
- 删除操作必须用 `<a-popconfirm>` 二次确认
- 消息提示用 `notification` from `ant-design-vue`
- 中英文 i18n 必须同步添加

---

## skill: add-search-filter

**描述**: 为已有列表页添加新的搜索条件。

### 步骤

```
Step 1: 在 formOptions.schema 中添加搜索表单项
  添加 { component: 'Xxx', fieldName: 'xxx', label: $t('page.xxx.xxx'), ... }

Step 2: 添加 i18n key
  在 zh-CN/page.json 和 en-US/page.json 添加对应翻译

Step 3: 确认 proxyConfig.ajax.query 的 formValues 传递
  搜索表单值通过 formValues 自动传入 query 函数，无需手动处理
  特殊情况（如 RangePicker）需手动拆分参数
```

### 常用搜索组件

| 场景 | 使用组件 |
|------|---------|
| 文本搜索 | `Input` |
| 状态下拉 | `Select` + `options: xxxStatusList` |
| 远程下拉 | `ApiSelect` + `api: async () => {...}` |
| 日期范围 | `RangePicker` + `presets` |
| 布尔开关 | `Switch` |

---

## skill: fix-common-issues

**描述**: 常见 Admin 前端开发问题诊断。

### ApiSelect 数据不显示

1. 确认 `api` 函数是 `async` 且正确返回数据
2. 确认 `afterFetch` 将数据转为 `{ label, value }[]` 格式
3. 检查 `immediate` / `alwaysLoad` prop 是否设置

### Drawer 提交后列表不刷新

在 `useVbenDrawer` 的 `onOpenChange` 中添加：
```typescript
onOpenChange(isOpen: boolean) {
  if (!isOpen) gridApi.reload(); // 关闭时刷新
}
```

### 新建 composable 后编译报"模块未找到"

1. 确认 `composables/index.ts` 已 `export * from './xxx'`
2. 确认 `src/api/index.ts` 也导出了

### 图标不显示或报错

1. 确认图标从 `@vben/icons` 导入
2. 在 template 中 `:icon` prop 必须用 `h()` 包裹：`:icon="h(LucideFilePenLine)"`

### 表格列日期显示为时间戳

使用 `formatter: 'formatDateTime'`，不要用 Slot + dayjs。
