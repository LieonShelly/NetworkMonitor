# 实现计划

- [x] 1. 编写 Bug 条件探索性测试
  - **Property 1: Bug Condition** — 并发 401 请求触发多次 Token 刷新
  - **重要**: 此测试必须在实施修复之前编写并运行
  - **目标**: 通过反例证明 bug 存在——多个并发 401 请求各自独立触发 `refreshTokenIfNeeded()`
  - **Scoped PBT 方法**: 针对确定性 bug，将属性范围限定为具体的失败场景：2 个及以上并发请求同时收到 401
  - 创建 `MockRefreshTokenUseCase`（实现 `RefreshTokenUseCaseType`），内部使用计数器记录 `execute()` 被调用的次数，并通过 `Task.sleep` 模拟网络延迟
  - 创建 `MockAppDataWithoutAuthorizationService`（实现 `AppDataWithoutAuthorizationServicefull`），持有 `MockRefreshTokenUseCase`
  - 创建 `MockTokenProvider`（实现 `TokenProvider`），提供测试用的 accessToken 和 refreshToken
  - 使用真实的 `RefreshTokenInterceptor` actor 实例，注入 mock 依赖
  - 测试场景：使用 `TaskGroup` 并发发起 N 个（N >= 2）`shouldRetry` 调用，每个调用传入不同的 `URLRequest` 和 401 `HTTPURLResponse`
  - 断言：`MockRefreshTokenUseCase.executeCallCount` 应等于 1（期望行为），但在未修复代码上将大于 1
  - 在未修复代码上运行测试——**预期结果：测试失败**（这证明 bug 存在）
  - **不要尝试修复测试或代码**——失败是预期的
  - 记录发现的反例（例如："并发 3 个 401 请求，refreshTokenIfNeeded 被调用了 3 次而非 1 次"）
  - 测试文件路径：`app/LTApp/LTAppTests/RefreshTokenInterceptorTests.swift`
  - _Requirements: 1.1, 1.4, 2.1, 2.4_

- [x] 2. 编写 Preservation 属性测试（在实施修复之前）
  - **Property 2: Preservation** — 非并发 401 场景行为不变
  - **重要**: 遵循观察优先方法论
  - **观察**: 在未修复代码上运行以下场景并记录行为：
    - 单个 401 请求：`shouldRetry` 返回 `true`，`refreshTokenIfNeeded` 被调用 1 次
    - 非 401 响应（200、400、500）：`shouldRetry` 返回 `false`，`refreshTokenIfNeeded` 不被调用
    - 已在 `requestsPool` 中的请求再次收到 401：`shouldRetry` 返回 `false`，不再触发刷新
    - 刷新失败时：`shouldRetry` 返回 `false`
  - 编写属性测试：
    - 属性 2a：对于任意非 401 的 HTTP 状态码（200-399, 402-599），`shouldRetry` 始终返回 `false` 且不触发刷新
    - 属性 2b：对于单个 401 请求（无并发），`shouldRetry` 返回 `true` 且刷新被调用恰好 1 次
    - 属性 2c：对于已在 `requestsPool` 中的请求，即使收到 401，`shouldRetry` 返回 `false`
    - 属性 2d：当刷新操作抛出错误时，`shouldRetry` 返回 `false`
  - 在未修复代码上运行测试——**预期结果：所有测试通过**（确认基线行为）
  - 测试文件路径：`app/LTApp/LTAppTests/RefreshTokenInterceptorTests.swift`（追加到同一文件）
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

- [x] 3. 修复 Token 刷新竞态条件

  - [x] 3.1 实现修复
    - 在 `RefreshTokenInterceptor` actor 中新增 `private var refreshingTask: Task<Void, Error>?` 属性
    - 修改 `refreshTokenIfNeeded()` 方法：
      - 若 `refreshingTask` 已存在，直接 `try await refreshingTask!.value` 等待其完成
      - 若不存在，创建新的 `Task` 执行 `service.refreshTokenUseCase.execute()`，赋值给 `refreshingTask`
      - 使用 `defer { refreshingTask = nil }` 确保刷新完成后清理状态
    - 保持 `shouldRetry` 中的 `requestsPool` 逻辑不变
    - 保持 `adapt` 方法不变
    - 文件：`app/LTApp/LTApp/Source/Service/Interceptor/RefreshTokenInterceptor.swift`
    - _Bug\_Condition: isBugCondition(requests) where requests.filter(401).count > 1 AND 各自独立调用 refreshTokenIfNeeded()_
    - _Expected\_Behavior: 同一时刻仅执行一次 refreshTokenIfNeeded()，其余请求 await 同一个 Task_
    - _Preservation: 非并发 401 场景（单请求 401、非 401 错误、requestsPool 拦截）行为不变_
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 3.4_

  - [x] 3.2 验证 Bug 条件探索性测试现在通过
    - **Property 1: Expected Behavior** — 并发 401 请求仅触发一次 Token 刷新
    - **重要**: 重新运行任务 1 中的同一测试，不要编写新测试
    - 任务 1 的测试编码了期望行为（`executeCallCount == 1`）
    - 当此测试通过时，确认期望行为已满足
    - **预期结果：测试通过**（确认 bug 已修复）
    - _Requirements: 2.1, 2.2, 2.3, 2.4_

  - [x] 3.3 验证 Preservation 测试仍然通过
    - **Property 2: Preservation** — 非并发 401 场景行为不变
    - **重要**: 重新运行任务 2 中的同一测试，不要编写新测试
    - **预期结果：所有测试通过**（确认无回归）
    - 确认修复后所有 preservation 测试仍然通过
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

- [x] 4. 检查点 — 确保所有测试通过
  - 确保所有测试通过，如有问题请询问用户。
