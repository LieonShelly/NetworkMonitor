# Token Refresh 竞态条件 Bugfix 设计

## 概述

当多个并发请求同时收到 HTTP 401 响应时，`RefreshTokenInterceptor` 会为每个请求独立调用 `refreshTokenIfNeeded()`，导致多次刷新 token。本修复方案利用 Swift Concurrency 的 actor 隔离特性，在 `RefreshTokenInterceptor` 中引入一个共享的"刷新任务"（`Task`），使得第一个 401 请求触发刷新操作，后续 401 请求挂起等待同一个刷新任务完成，从而消除竞态条件。

## 术语表

- **Bug_Condition (C)**: 多个并发请求同时收到 401 响应，各自独立触发 token 刷新操作
- **Property (P)**: 同一时刻仅执行一次 token 刷新，其余 401 请求等待该刷新完成后使用新 token 重试
- **Preservation**: 非 401 请求的正常流程、单请求 401 的刷新重试、requestsPool 防重复重试、LogoutInterceptor 登出流程等现有行为不受影响
- **RefreshTokenInterceptor**: `app/LTApp/LTApp/Source/Service/Interceptor/RefreshTokenInterceptor.swift` 中的 actor，负责在 401 时触发 token 刷新
- **ApiClient.sendRequest**: `core/Network/Source/ApiClient.swift` 中的方法，遍历 interceptor 链处理请求和重试
- **refreshingTask**: 新增的 actor 内部属性，类型为 `Task<Void, Error>?`，用于追踪当前正在进行的刷新操作

## Bug 详情

### Bug 条件

当多个并发请求同时收到 401 状态码时，每个请求在 `ApiClient.sendRequest` 的 `case 401` 分支中独立遍历 interceptor 链，各自调用 `RefreshTokenInterceptor.shouldRetry()`。虽然 `RefreshTokenInterceptor` 是 actor（保证串行访问），但每次调用 `shouldRetry` 都会独立执行 `refreshTokenIfNeeded()`，因为 actor 仅保证方法调用的串行化，不会合并多个等待者的刷新请求。

**形式化规约：**
```
FUNCTION isBugCondition(requests)
  INPUT: requests — 一组并发的网络请求及其响应
  OUTPUT: boolean

  LET responses401 = requests.filter(r => r.response.statusCode == 401)
  RETURN responses401.count > 1
         AND each request in responses401 independently calls refreshTokenIfNeeded()
         AND no shared refresh task coordination exists
END FUNCTION
```

### 示例

- **示例 1**: Request1 和 Request2 同时收到 401。Request1 先进入 actor 调用 `refreshTokenIfNeeded()`，刷新成功获得 TokenA。Request2 随后进入 actor，再次调用 `refreshTokenIfNeeded()`，用已被 TokenA 替换的旧 refresh token 发起第二次刷新，可能失败或返回 TokenB 覆盖 TokenA。
- **示例 2**: Request1 触发刷新正在进行中（网络延迟），Request2、Request3 也收到 401，各自排队进入 actor 后又分别发起独立的刷新调用，导致 3 次刷新 API 调用。
- **示例 3**: 第二次刷新因 refresh token 已失效而抛出错误，`shouldRetry` 返回 false，触发 `LogoutInterceptor.abort()`，用户被意外登出。
- **边界情况**: 单个请求收到 401 时，当前逻辑正常工作（仅一次刷新），此行为应保持不变。

## 期望行为

### 保持不变的行为

**不变行为：**
- 请求返回 200-299 成功状态码时，正常返回 Response，不触发任何 interceptor 的 shouldRetry 或 abort
- 请求返回非 401 错误状态码（400、403、500 等）时，抛出 `AppNetworkError.httpError`，不触发 token 刷新
- 单个请求收到 401 且无其他并发请求时，正常触发一次 token 刷新并重试
- 同一请求已在 `requestsPool` 中时，不再重复触发刷新，防止无限重试
- `AuthInterceptor.adapt()` 在每次发送请求前注入最新 accessToken
- 刷新最终失败时，`LogoutInterceptor.abort()` 清除 token 并发布过期事件

**范围：**
所有不涉及"多个并发 401 响应"的输入场景不受本次修复影响，包括：
- 正常成功请求（2xx）
- 非 401 错误请求
- 单个 401 请求的刷新重试
- SSE 流式请求
- 非网络相关的 UI 交互

## 假设的根因分析

基于代码分析，最可能的问题如下：

1. **缺少共享刷新任务协调**: `RefreshTokenInterceptor` 虽然是 actor（保证串行访问），但 `shouldRetry` 每次被调用时都会独立执行 `refreshTokenIfNeeded()`。Actor 的串行化仅意味着第二个调用等待第一个完成后再执行，但不会复用第一个的刷新结果。第一个刷新完成后，第二个调用仍会发起新的刷新请求。

2. **`requestsPool` 仅防止同一请求重试**: `requestsPool` 通过 `URLRequest` 相等性检查防止同一请求被重试两次，但不同请求（Request1 vs Request2）各自独立通过检查，各自触发刷新。

3. **Refresh Token 单次使用语义**: 后端的 refresh token 可能是一次性的（使用后即失效），第一次刷新成功后旧 refresh token 失效，第二次刷新使用旧 token 必然失败。

4. **Token 覆盖风险**: 即使两次刷新都成功，第二次返回的 token 会覆盖第一次的，而已使用第一次 token 重试的请求可能因 token 不匹配而再次失败。

## 正确性属性

Property 1: Bug Condition — 并发 401 请求仅触发一次刷新

_For any_ 一组并发请求，当其中多个请求同时收到 401 响应时，修复后的 `RefreshTokenInterceptor` SHALL 仅执行一次 `refreshTokenIfNeeded()` 调用，所有其他 401 请求 SHALL 等待该刷新操作完成后复用其结果（成功则重试，失败则不重试）。

**Validates: Requirements 2.1, 2.2, 2.3, 2.4**

Property 2: Preservation — 非并发 401 场景行为不变

_For any_ 不涉及多个并发 401 响应的输入（成功请求、非 401 错误、单个 401 请求、SSE 请求等），修复后的代码 SHALL 产生与原始代码完全相同的行为，保持所有现有功能不变。

**Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6**

## 修复实现

### 所需变更

假设根因分析正确：

**文件**: `app/LTApp/LTApp/Source/Service/Interceptor/RefreshTokenInterceptor.swift`

**函数**: `shouldRetry(_:response:)` 和 `refreshTokenIfNeeded()`

**具体变更**:

1. **新增 `refreshingTask` 属性**: 在 actor 中添加 `private var refreshingTask: Task<Void, Error>?` 属性，用于追踪当前正在进行的刷新操作。

2. **改造 `refreshTokenIfNeeded()` 方法**: 
   - 检查 `refreshingTask` 是否已存在且未完成
   - 若已存在，直接 `try await refreshingTask!.value` 等待其完成
   - 若不存在，创建新的 `Task` 执行刷新，赋值给 `refreshingTask`
   - 刷新完成后（无论成功或失败），将 `refreshingTask` 置为 nil

3. **利用 actor 隔离保证线程安全**: 由于 `RefreshTokenInterceptor` 已经是 actor，对 `refreshingTask` 的读写天然串行化，无需额外锁机制。

4. **刷新完成后清理状态**: 在 `refreshingTask` 的 `Task` 闭包中使用 `defer` 或在完成后显式将 `refreshingTask` 置为 nil，确保下一轮 401 可以正常触发新的刷新。

5. **保持 `requestsPool` 逻辑不变**: 现有的 `requestsPool` 防重复重试机制继续保留，与新的共享刷新任务机制互补。

**伪代码：**
```
actor RefreshTokenInterceptor {
    private var refreshingTask: Task<Void, Error>?
    private var requestsPool: [URLRequest] = []

    func shouldRetry(_ request: URLRequest, response: URLResponse?) async throws -> Bool {
        guard response is HTTPURLResponse with statusCode == 401 else { return false }
        guard !requestsPool.contains(request) else { return false }
        
        do {
            try await refreshTokenIfNeeded()
            requestsPool.append(request)
            return true
        } catch {
            return false
        }
    }

    private func refreshTokenIfNeeded() async throws {
        if let existingTask = refreshingTask {
            // 复用正在进行的刷新任务
            return try await existingTask.value
        }
        
        // 创建新的刷新任务
        let task = Task {
            defer { refreshingTask = nil }
            try await service.refreshTokenUseCase.execute()
        }
        refreshingTask = task
        try await task.value
    }
}
```

## 测试策略

### 验证方法

测试策略分两阶段：首先在未修复代码上复现 bug（探索性测试），然后验证修复的正确性和行为保持。

### 探索性 Bug 条件检查

**目标**: 在实施修复前，通过测试复现 bug，确认或否定根因分析。如果否定，需要重新假设。

**测试计划**: 编写测试模拟多个并发请求同时收到 401 响应，观察 `refreshTokenIfNeeded()` 被调用的次数。在未修复代码上运行以观察失败。

**测试用例**:
1. **并发双请求 401 测试**: 模拟 2 个并发请求同时收到 401，验证 `refreshTokenIfNeeded()` 被调用次数（未修复代码上将调用 2 次）
2. **并发多请求 401 测试**: 模拟 5 个并发请求同时收到 401，验证刷新调用次数（未修复代码上将调用 5 次）
3. **刷新进行中新请求测试**: 第一个请求触发刷新（模拟延迟），期间第二个请求也收到 401（未修复代码上将发起第二次刷新）
4. **刷新失败级联测试**: 第一次刷新成功使旧 refresh token 失效，第二次刷新因此失败（未修复代码上将触发意外登出）

**预期反例**:
- `refreshTokenIfNeeded()` 被调用多次而非一次
- 可能原因：actor 串行化不等于请求合并，每次 `shouldRetry` 调用都独立执行刷新

### Fix 检查

**目标**: 验证对于所有满足 bug 条件的输入，修复后的函数产生期望行为。

**伪代码：**
```
FOR ALL requests WHERE isBugCondition(requests) DO
  result := RefreshTokenInterceptor_fixed.shouldRetry(requests)
  ASSERT refreshTokenIfNeeded was called exactly once
  ASSERT all requests received the refreshed token
  ASSERT all requests' shouldRetry returned true (if refresh succeeded)
END FOR
```

### Preservation 检查

**目标**: 验证对于所有不满足 bug 条件的输入，修复后的函数与原始函数产生相同结果。

**伪代码：**
```
FOR ALL input WHERE NOT isBugCondition(input) DO
  ASSERT RefreshTokenInterceptor_original.shouldRetry(input) 
       = RefreshTokenInterceptor_fixed.shouldRetry(input)
END FOR
```

**测试方法**: 推荐使用基于属性的测试（Property-Based Testing）进行 preservation 检查，因为：
- 可自动生成大量测试用例覆盖输入域
- 能捕获手动单元测试可能遗漏的边界情况
- 对非 bug 输入的行为不变性提供强保证

**测试计划**: 先在未修复代码上观察非 bug 输入（成功请求、非 401 错误等）的行为，然后编写基于属性的测试捕获该行为。

**测试用例**:
1. **成功请求保持测试**: 观察 200-299 请求在未修复代码上不触发 shouldRetry，验证修复后行为一致
2. **非 401 错误保持测试**: 观察 400/403/500 等错误在未修复代码上不触发刷新，验证修复后行为一致
3. **单请求 401 保持测试**: 观察单个 401 请求在未修复代码上正常刷新重试，验证修复后行为一致
4. **requestsPool 防重复保持测试**: 观察已重试请求在未修复代码上被 requestsPool 拦截，验证修复后行为一致

### 单元测试

- 测试并发多个 `shouldRetry` 调用时 `refreshTokenIfNeeded()` 仅执行一次
- 测试 `refreshingTask` 在刷新完成后被正确清理为 nil
- 测试刷新失败时所有等待的请求都收到失败结果
- 测试 `requestsPool` 在新机制下仍正常工作
- 测试单个 401 请求的刷新重试流程不受影响

### 基于属性的测试

- 生成随机数量的并发 401 请求，验证刷新操作始终仅执行一次
- 生成随机混合的请求（成功、各种错误码、401），验证非 401 请求的行为完全不变
- 生成随机时序的请求到达顺序，验证无论到达顺序如何，刷新操作都仅执行一次

### 集成测试

- 测试完整的 interceptor 链（AuthInterceptor → RefreshTokenInterceptor → LogoutInterceptor）在并发 401 场景下的协作
- 测试刷新成功后 `AuthInterceptor.adapt()` 注入新 token 的完整流程
- 测试刷新失败后 `LogoutInterceptor.abort()` 正确执行登出的完整流程
