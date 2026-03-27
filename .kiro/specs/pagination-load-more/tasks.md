# 实现计划：分页加载更多

## 概述

基于设计文档，按增量步骤实现通用 cursor 分页加载更多机制。先创建通用组件（Paginator、LoadMoreFooter），再集成到 InsightsViewModel 和 ReportHistoryView 中。每个步骤在前一步基础上构建，确保无孤立代码。

## 任务

- [x] 1. 创建 Paginator 泛型分页状态管理器
  - [x] 1.1 创建 `Source/Common/Paginator.swift`，定义 `PaginationState` 和 `LoadMoreState` 枚举，以及 `Paginator<T>` 类
    - 定义 `PaginationState` 枚举（idle、loading、error）
    - 定义 `LoadMoreState` 枚举（idle、loading、noMore、error）
    - 实现 `@MainActor final class Paginator<T: Sendable>: ObservableObject`
    - 实现 `@Published` 属性：`items: [T]`、`state: PaginationState`、`hasMore: Bool`
    - 实现 `private var nextCursor: String?` 和 `fetchPage` 闭包存储
    - 实现 `init(fetchPage:)` 构造方法
    - 实现 `loadFirst()` 方法：设 state 为 loading，清空 items，以 cursor: nil 调用 fetchPage，成功后替换 items 并更新 hasMore/nextCursor，失败时设 state 为 error
    - 实现 `loadMore()` 方法：检查 hasMore 和 state 防护条件，以 nextCursor 调用 fetchPage，成功后追加 items，失败时设 state 为 error 且保留已有 items
    - 实现 `loadMoreState` 计算属性：根据 state、hasMore、items.isEmpty 推导 LoadMoreFooter 显示状态
    - _需求: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9_

  - [ ]* 1.2 为 Paginator 编写属性测试 — Property 1: loadFirst 总是用首页数据替换已有数据
    - **Property 1: loadFirst 总是用首页数据替换已有数据**
    - 生成随机的初始 items 和随机的首页返回数据，调用 `loadFirst()` 后验证 items 被完全替换，hasMore 和 nextCursor 与 PaginationInfo 一致
    - **验证: 需求 1.2, 1.7**

  - [ ]* 1.3 为 Paginator 编写属性测试 — Property 2: loadMore 追加数据并使用正确的 cursor
    - **Property 2: loadMore 追加数据并使用正确的 cursor**
    - 生成随机的已有 items 和随机的下一页数据，调用 `loadMore()` 后验证 items = old + new，且传给 fetchPage 的 cursor 参数等于调用前的 nextCursor
    - **验证: 需求 1.3, 1.6**

  - [ ]* 1.4 为 Paginator 编写属性测试 — Property 3: loadMore 防护条件阻止不必要的请求
    - **Property 3: loadMore 防护条件阻止不必要的请求**
    - 生成随机的 Paginator 状态（hasMore=false 或 state=loading），调用 `loadMore()` 后验证 fetchPage 未被调用且 items 不变
    - **验证: 需求 1.4, 1.5**

  - [ ]* 1.5 为 Paginator 编写属性测试 — Property 4: 错误发生时保留已有数据
    - **Property 4: 错误发生时保留已有数据**
    - 生成随机的已有 items，让 fetchPage 抛出随机错误，验证 items 不变且 state 为 error
    - **验证: 需求 1.8**

- [x] 2. 创建 LoadMoreFooter 通用视图组件
  - [x] 2.1 创建 `Source/Common/LoadMoreFooter.swift`，实现 LoadMoreFooter SwiftUI View
    - 接受 `state: LoadMoreState` 和 `onRetry: () async -> Void` 参数
    - idle 状态：不显示任何内容（EmptyView）
    - loading 状态：显示居中的 ProgressView
    - noMore 状态：显示"没有更多数据"文案
    - error 状态：显示错误提示文案和重试按钮，点击重试调用 onRetry
    - _需求: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

  - [ ]* 2.2 为 LoadMoreFooter 编写单元测试
    - 分别验证 idle、loading、noMore、error 四种状态下的 UI 输出
    - _需求: 3.2, 3.3, 3.4, 3.5_

- [x] 3. 检查点 — 确保通用组件编译通过
  - 确保所有测试通过，如有问题请询问用户。

- [x] 4. 集成 Paginator 到 InsightsViewModel
  - [x] 4.1 修改 `Source/Domain/Insights/InsightsViewModel.swift`，集成 Paginator
    - 新增 `@MainActor @Published var reportsPaginator: Paginator<WeeklyReportSummary>!` 属性
    - 在 `init` 中初始化 reportsPaginator，注入 fetchPage 闭包（调用 `dataService.fetchWeeklyReportsListUseCase.execute`，返回 `(list.reports, list.pagination)`）
    - 修改 `fetchHisotryData()` 方法：改用 `reportsPaginator.loadFirst()`，加载完成后从 `reportsPaginator.items` 分离 unread/read 列表
    - 新增 `loadMoreHistory()` 方法（@MainActor）：调用 `reportsPaginator.loadMore()`，然后从 `reportsPaginator.items` 更新 unreadHisotrys 和 readHisotrys
    - _需求: 2.1, 2.2, 2.6_

  - [ ]* 4.2 为已读/未读分组编写属性测试 — Property 5: 已读/未读分组是完整分区
    - **Property 5: 已读/未读分组是完整分区**
    - 生成随机的 WeeklyReportSummary 列表（随机 readAt 值），验证按 readAt 分组后两组的并集等于原始列表且无交集
    - **验证: 需求 2.6**

- [x] 5. 集成 LoadMoreFooter 到 ReportHistoryView
  - [x] 5.1 修改 `Source/Domain/Insights/ReportHistoryView.swift`，添加加载更多功能
    - 在 `histroyView` 底部添加 `LoadMoreFooter`，传入 `viewModel.reportsPaginator.loadMoreState` 和 `onRetry: { await viewModel.loadMoreHistory() }`
    - 在 `readHisotrys` 的最后一个 `ReportHistoryRow` 上添加 `.onAppear` modifier，当最后一项出现时调用 `viewModel.loadMoreHistory()`
    - _需求: 2.3, 2.4, 2.5, 2.7_

- [x] 6. 最终检查点 — 确保所有测试通过
  - 确保所有测试通过，如有问题请询问用户。

## 备注

- 标记 `*` 的任务为可选任务，可跳过以加快 MVP 进度
- 每个任务引用了具体的需求编号以确保可追溯性
- 检查点确保增量验证
- 属性测试验证通用正确性属性，单元测试验证具体示例和边界情况
