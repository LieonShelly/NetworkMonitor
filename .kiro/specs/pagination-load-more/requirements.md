# 需求文档

## 简介

为 App 中的列表页面提供通用的 cursor 分页加载更多机制。首先在 ReportHistoryView（周报历史列表）中实现上拉加载更多功能，同时将分页状态管理抽象为可复用的通用组件，便于 ThreadView 等其他列表页面直接复用。

后端采用统一的 cursor 分页协议：通过 `limit`、`cursor` 参数请求数据，响应中返回 `hasMore` 和 `nextCursor` 字段。

## 术语表

- **Paginator**: 通用分页状态管理器，封装 cursor 分页逻辑（首次加载、加载更多、刷新、状态跟踪），可被任意列表 ViewModel 复用
- **PaginationInfo**: 后端返回的分页元数据，包含 `limit`、`hasMore`、`nextCursor` 字段
- **ReportHistoryView**: 展示周报历史记录的 SwiftUI 列表视图
- **InsightsViewModel**: ReportHistoryView 对应的 ViewModel，负责获取和管理周报历史数据
- **LoadMoreFooter**: 列表底部的上拉加载更多 UI 组件，展示加载状态指示器或"没有更多数据"提示
- **FetchWeeklyReportsListUseCase**: 获取周报列表的用例，execute 方法接收 `limit`、`cursor`、`isRead` 参数，返回包含 `PaginationInfo` 的 `WeeklyReportsList`

## 需求

### 需求 1：通用分页状态管理器

**用户故事：** 作为开发者，我希望有一个通用的分页状态管理器（Paginator），以便在多个列表页面中复用 cursor 分页逻辑，避免重复代码。

#### 验收标准

1. THE Paginator SHALL 维护当前分页状态，包括已加载的数据项列表、是否有更多数据（hasMore）、下一页游标（nextCursor）、以及当前加载状态（idle、loading、error）
2. THE Paginator SHALL 提供 `loadFirst` 方法，调用时清空已有数据并从第一页开始加载（cursor 传 nil）
3. THE Paginator SHALL 提供 `loadMore` 方法，调用时使用上一次 PaginationInfo 返回的 nextCursor 作为参数请求下一页数据
4. WHEN `loadMore` 被调用且 hasMore 为 false 时，THE Paginator SHALL 直接返回而不发起网络请求
5. WHILE Paginator 处于 loading 状态时，THE Paginator SHALL 忽略重复的 `loadMore` 调用，防止并发重复请求
6. WHEN `loadMore` 成功返回数据时，THE Paginator SHALL 将新数据追加到已有数据列表末尾，并更新 hasMore 和 nextCursor
7. WHEN `loadFirst` 成功返回数据时，THE Paginator SHALL 用新数据替换已有数据列表，并更新 hasMore 和 nextCursor
8. IF 网络请求失败，THEN THE Paginator SHALL 将加载状态设置为 error 并保留已加载的数据不变
9. THE Paginator SHALL 接受一个泛型的数据加载闭包作为参数，该闭包接收 cursor（String?）并返回数据项数组和 PaginationInfo，使 Paginator 不依赖具体业务类型

### 需求 2：ReportHistoryView 上拉加载更多

**用户故事：** 作为用户，我希望在周报历史列表底部上拉时能自动加载更多历史数据，以便浏览全部周报记录而无需一次性加载所有数据。

#### 验收标准

1. WHEN ReportHistoryView 首次出现时，THE InsightsViewModel SHALL 通过 Paginator 的 `loadFirst` 方法加载第一页周报历史数据
2. WHEN 用户下拉刷新 ReportHistoryView 时，THE InsightsViewModel SHALL 通过 Paginator 的 `loadFirst` 方法重新加载第一页数据
3. WHEN 用户滚动到列表底部且 hasMore 为 true 时，THE ReportHistoryView SHALL 自动触发 Paginator 的 `loadMore` 方法加载下一页数据
4. WHILE Paginator 正在加载更多数据时，THE LoadMoreFooter SHALL 在列表底部显示加载中指示器（如 ProgressView）
5. WHEN hasMore 为 false 且列表数据不为空时，THE LoadMoreFooter SHALL 显示"没有更多数据"的提示文案
6. WHEN 加载更多数据成功返回时，THE ReportHistoryView SHALL 将新数据按已读/未读分类追加到对应列表中，保持现有的 unread 和 history 分组展示逻辑
7. IF 加载更多数据失败，THEN THE LoadMoreFooter SHALL 显示错误提示并提供重试操作入口

### 需求 3：加载更多 Footer UI 组件

**用户故事：** 作为开发者，我希望有一个通用的加载更多 Footer 视图组件，以便在不同列表中复用统一的加载更多 UI 样式。

#### 验收标准

1. THE LoadMoreFooter SHALL 接受当前分页加载状态（idle、loading、error、noMore）作为输入参数
2. WHEN 加载状态为 loading 时，THE LoadMoreFooter SHALL 显示一个居中的加载指示器
3. WHEN 加载状态为 noMore 时，THE LoadMoreFooter SHALL 显示"没有更多数据"的文案提示
4. WHEN 加载状态为 error 时，THE LoadMoreFooter SHALL 显示错误提示文案和一个可点击的重试按钮
5. WHEN 加载状态为 idle 时，THE LoadMoreFooter SHALL 不显示任何内容（隐藏）
6. THE LoadMoreFooter SHALL 作为独立的 SwiftUI View 组件，可在任意 ScrollView 或 List 的底部使用
