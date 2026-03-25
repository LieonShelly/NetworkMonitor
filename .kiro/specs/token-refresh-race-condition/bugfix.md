# Bugfix 需求文档

## 简介

在 `ApiClient` 的 `sendRequest` 方法中存在 token 刷新竞态条件（Race Condition）。当多个并发请求同时收到 HTTP 401 响应时，`RefreshTokenInterceptor` 会为每个请求独立触发 `refreshTokenIfNeeded()`，导致多次调用刷新 token 接口。由于刷新 token 接口存在异步延迟，后续的刷新请求可能使用已被前一次刷新操作失效的 refresh token，从而引发级联认证失败，最终导致用户被意外登出。

## Bug 分析

### 当前行为（缺陷）

1.1 WHEN 多个并发请求（如 Request1、Request2）同时收到 401 状态码 THEN 系统为每个请求分别独立调用 `refreshTokenIfNeeded()`，导致刷新 token 接口被调用多次

1.2 WHEN 第一次刷新 token 请求成功返回并更新了 token，而第二次刷新请求仍在使用旧的 refresh token THEN 系统第二次刷新请求可能因 refresh token 已失效而失败，导致该请求的 `shouldRetry` 返回 false，进而触发 `abort` 流程

1.3 WHEN 第二次刷新 token 请求返回了新的 token 对，覆盖了第一次刷新获得的有效 token THEN 系统中已使用第一次 token 重试的请求可能因 token 被覆盖而再次失效

1.4 WHEN 刷新 token 正在进行中，其他新发出的请求也收到 401 THEN 系统不会等待正在进行的刷新操作完成，而是再次发起新的刷新请求

### 期望行为（正确）

2.1 WHEN 多个并发请求同时收到 401 状态码 THEN 系统 SHALL 仅触发一次刷新 token 操作，其余请求应等待该刷新操作完成后再使用新 token 重试

2.2 WHEN 第一个 401 请求触发了刷新 token 操作，且刷新成功 THEN 系统 SHALL 使所有等待中的请求使用新获取的 token 进行重试

2.3 WHEN 刷新 token 操作失败 THEN 系统 SHALL 使所有等待中的请求收到刷新失败的结果，不再重试，并按原有逻辑继续执行后续 interceptor（如 LogoutInterceptor 的 abort 流程）

2.4 WHEN 刷新 token 正在进行中，其他新请求也收到 401 THEN 系统 SHALL 让这些新请求等待当前正在进行的刷新操作完成，而不是发起新的刷新请求

### 不变行为（回归预防）

3.1 WHEN 请求返回 200-299 成功状态码 THEN 系统 SHALL CONTINUE TO 正常返回 Response 数据，不触发任何 interceptor 的 shouldRetry 或 abort 逻辑

3.2 WHEN 请求返回非 401 的错误状态码（如 400、403、500 等） THEN 系统 SHALL CONTINUE TO 抛出 `AppNetworkError.httpError` 错误，不触发 token 刷新流程

3.3 WHEN 单个请求收到 401 且没有其他并发请求 THEN 系统 SHALL CONTINUE TO 正常触发一次 token 刷新并重试该请求

3.4 WHEN 同一个请求已经重试过一次（已在 requestsPool 中） THEN 系统 SHALL CONTINUE TO 不再为该请求重复触发刷新，防止无限重试循环

3.5 WHEN AuthInterceptor 为请求添加 Bearer token header THEN 系统 SHALL CONTINUE TO 在每次发送请求前通过 `adapt` 方法注入最新的 accessToken

3.6 WHEN 刷新 token 最终失败且 LogoutInterceptor 的 abort 被触发 THEN 系统 SHALL CONTINUE TO 清除 token 并发布 token 过期事件，执行登出流程
