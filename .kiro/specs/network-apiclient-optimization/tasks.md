# 实施计划：Network ApiClient 优化

## 概述

将 LTNetwork 框架的 `ApiClient` 重构为 Dio 风格拦截器接口 + 迭代重试机制 + NetworkTask 生命周期管理。按自底向上顺序实施：先建立基础类型，再构建链式引擎，最后重构 ApiClient 并迁移现有拦截器。

## 任务

- [x] 1. 创建 InterceptorHandler 类型定义
  - 新建 `core/Network/Source/Interceptor/InterceptorHandler.swift`
  - 实现 `RequestInterceptorHandler`、`ResponseInterceptorHandler`、`ErrorInterceptorHandler` 三个 struct
  - 实现 `RequestInterceptorResult`、`ResponseInterceptorResult`、`ErrorInterceptorResult` 三个 enum
  - 所有类型遵循 `Sendable`
  - _需求: 3.2, 3.3, 3.4, 3.7_

- [x] 2. 重构 NetworkInterceptor 协议
  - [x] 2.1 将 `core/Network/Source/Interceptor/NetworkInterceptor.swift` 中的协议方法从 `adapt`/`shouldRetry`/`abort` 替换为 `onRequest`/`onResponse`/`onError`
    - 三个方法分别接收对应的 Handler 参数并返回对应的 Result 枚举
    - 提供默认实现：透传（调用 handler.next）
    - 协议要求遵循 `Sendable`
    - _需求: 3.1, 3.5, 3.7_

  - [x] 2.2 编写属性测试：默认拦截器透传
    - **Property 5: 默认拦截器透传**
    - **验证: 需求 3.5**

- [x] 3. 创建 InterceptorChain 链式执行引擎
  - [x] 3.1 新建 `core/Network/Source/Interceptor/InterceptorChain.swift`
    - 实现 `executeOnRequest`、`executeOnResponse`、`executeOnError` 三个方法
    - 按拦截器数组正序依次执行，遇到 reject/retry 立即短路返回
    - _需求: 3.6, 3.8_

  - [x] 3.2 编写属性测试：拦截器按注册顺序执行
    - **Property 6: 拦截器按注册顺序执行**
    - **验证: 需求 3.6**

- [x] 4. 创建 NetworkTask 请求句柄
  - [x] 4.1 新建 `core/Network/Source/Model/NetworkTask.swift`
    - 包装 `Task<Response, Error>`，暴露 `value`（async throws）、`cancel()`、`isCancelled` 接口
    - 遵循 `Sendable`
    - _需求: 1.1, 1.2, 1.6_

  - [x] 4.2 编写属性测试：取消操作产生 CancellationError
    - **Property 1: 取消操作产生 CancellationError**
    - **验证: 需求 1.2, 1.3, 2.5, 5.4**

- [x] 5. 检查点 - 确保所有基础组件编译通过
  - 确保所有测试通过，如有疑问请向用户确认。

- [x] 6. 重构 ApiClient 核心逻辑
  - [x] 6.1 重构 `core/Network/Source/ApiClient.swift` 的 `sendRequest` 方法
    - 新增 `InterceptorChain` 属性和 `maxRetryCount` 参数
    - 新增 `request(_:) -> NetworkTask` 方法，返回可控制的 NetworkTask
    - `sendRequest` 保持现有签名，内部委托给 `NetworkTask.value`
    - 实现 `executeWithRetry` 私有方法：while 循环 + onRequest 链 → URLSession → onResponse/onError 链
    - 每次循环开头调用 `Task.checkCancellation()` 检查取消
    - 网络连接失败包装为 `AppNetworkError.networkError`
    - onRequest reject 直接抛出错误，不进入 onError 链
    - 重试次数达到上限时抛出最后一次错误
    - _需求: 1.1, 1.4, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 5.1, 5.2, 5.3, 5.4, 5.5_

  - [x] 6.2 编写属性测试：sendRequest 与 NetworkTask.value 等价
    - **Property 2: sendRequest 与 NetworkTask.value 等价**
    - **验证: 需求 1.4**

  - [x] 6.3 编写属性测试：重试次数受最大上限约束
    - **Property 3: 重试次数受最大上限约束**
    - **验证: 需求 2.2, 2.4**

  - [x] 6.4 编写属性测试：重试时重新执行 onRequest 拦截器链
    - **Property 4: 重试时重新执行 onRequest 拦截器链**
    - **验证: 需求 2.3, 2.6, 3.8**

  - [x] 6.5 编写属性测试：HTTP 状态码决定结果类型
    - **Property 11: HTTP 状态码决定结果类型**
    - **验证: 需求 5.1, 5.2**

  - [x] 6.6 编写属性测试：网络连接失败映射为 networkError
    - **Property 12: 网络连接失败映射为 networkError**
    - **验证: 需求 5.3**

  - [x] 6.7 编写属性测试：onRequest 拒绝绕过重试
    - **Property 13: onRequest 拒绝绕过重试**
    - **验证: 需求 5.5**

- [x] 7. 检查点 - 确保 ApiClient 重构编译通过且测试通过
  - 确保所有测试通过，如有疑问请向用户确认。

- [x] 8. 迁移 AuthInterceptor
  - [x] 8.1 重构 `app/LTApp/LTApp/Source/Service/Interceptor/AuthInterceptor.swift`
    - 移除 `adapt`/`shouldRetry` 方法，仅覆写 `onRequest`
    - 在 onRequest 中添加 Bearer 认证头，调用 handler.next 传递请求
    - 保持 actor 隔离
    - _需求: 4.1_

  - [x] 8.2 编写属性测试：AuthInterceptor 添加 Bearer 认证头
    - **Property 7: AuthInterceptor 添加 Bearer 认证头**
    - **验证: 需求 4.1**

- [x] 9. 迁移 RefreshTokenInterceptor
  - [x] 9.1 重构 `app/LTApp/LTApp/Source/Service/Interceptor/RefreshTokenInterceptor.swift`
    - 移除 `adapt`/`shouldRetry` 方法和 `requestsPool`，仅覆写 `onError`
    - 在 onError 中判断 401 错误：刷新成功返回 handler.retry，刷新失败返回 handler.next(error)
    - 保留 actor 隔离和 `refreshingTask` 并发去重机制
    - _需求: 4.2, 4.4, 4.5_

  - [x] 9.2 编写属性测试：RefreshTokenInterceptor 的 401 处理
    - **Property 8: RefreshTokenInterceptor 的 401 处理**
    - **验证: 需求 4.2, 4.5**

  - [x] 9.3 编写属性测试：并发刷新令牌去重
    - **Property 10: 并发刷新令牌去重**
    - **验证: 需求 4.4**

- [x] 10. 迁移 LogoutInterceptor
  - [x] 10.1 重构 `app/LTApp/LTApp/Source/Service/Interceptor/LogoutInterceptor.swift`
    - 移除 `adapt`/`shouldRetry`/`abort` 方法，仅覆写 `onError`
    - 在 onError 中判断 401 错误：清除令牌、发布过期事件，返回 handler.next(error)
    - _需求: 4.3_

  - [x] 10.2 编写属性测试：LogoutInterceptor 清除令牌并发布过期事件
    - **Property 9: LogoutInterceptor 清除令牌并发布过期事件**
    - **验证: 需求 4.3**

- [x] 11. 更新 SSE 流式请求支持
  - 重构 `ApiClient.sendSSERequest` 方法，使用 `InterceptorChain.executeOnRequest` 执行拦截器链
  - 返回可取消的 NetworkTask 句柄，取消时终止底层字节流连接
  - _需求: 1.5_

- [x] 12. 更新 ApiClient 初始化接口
  - 确保 `ApiClient.init` 接受统一的 `[NetworkInterceptor]` 数组参数
  - 更新所有调用点（如 `AppDataWithAuthorizationService` 等）以适配新的拦截器协议
  - _需求: 4.6_

- [x] 13. 最终检查点 - 确保所有测试通过
  - 确保所有测试通过，如有疑问请向用户确认。

## 备注

- 标记 `*` 的子任务为可选，可跳过以加速 MVP 交付
- 每个任务引用了具体的需求编号，确保可追溯性
- 检查点确保增量验证，避免问题累积
- 属性测试使用 SwiftCheck 库验证通用正确性属性
- 单元测试验证具体示例和边界条件
