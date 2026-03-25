# 需求文档

## 简介

优化 LTNetwork 框架中的 `ApiClient` 核心组件，解决三个关键架构问题：

1. **请求生命周期管理**：当前每个请求独立执行，`ApiClient` 无法取消、暂停或恢复单个请求。需要引入请求生命周期管理机制，使调用方能够控制进行中的请求。
2. **递归拦截器重试模式**：当前 `sendRequest` 在 401 重试时通过递归调用自身实现，这会导致调用栈增长且逻辑难以追踪。需要替换为基于迭代的重试机制。
3. **NetworkInterceptor 接口设计**：当前 `NetworkInterceptor` 协议将 `adapt`、`shouldRetry`、`abort` 三个职责耦合在同一接口中，导致大多数实现者需要提供空实现。需要参考 Dio 框架的拦截器模式，重新设计为统一的抽象拦截器接口，通过 `onRequest`、`onResponse`、`onError` 三个生命周期方法和 Handler 机制实现链式拦截。

## 术语表

- **ApiClient**：LTNetwork 框架中负责发送 HTTP 请求的核心类，管理 URLSession、环境配置和拦截器链
- **NetworkInterceptor**：网络拦截器协议，定义请求适配、重试判断和中止判断的接口
- **Request**：描述一个 HTTP 请求的协议，包含端点、方法和载荷信息
- **Response**：HTTP 响应的值类型，包含状态码和响应数据
- **RequestBuilder**：根据 `Request` 协议和 `AppEnvironment` 构建 `URLRequest` 的工具类
- **NetworkTask**：代表一个可控制生命周期的网络请求句柄，支持取消操作
- **InterceptorChain**：拦截器链，按注册顺序依次执行拦截器的管道机制
- **InterceptorHandler**：拦截器处理器，拦截器通过调用 handler 的方法来决定请求流程的下一步操作（继续、拒绝、或短路响应）
- **onRequest**：请求发送前的拦截点，可修改请求或短路返回响应
- **onResponse**：响应成功返回后的拦截点，可修改响应或触发错误
- **onError**：请求出错后的拦截点，可处理错误、触发重试或短路返回响应

## 需求

### 需求 1：请求生命周期管理

**用户故事：** 作为一名 iOS 开发者，我希望能够取消正在进行的网络请求，以便在用户离开页面或不再需要结果时释放网络资源。

#### 验收标准

1. WHEN 调用方发起一个网络请求, THE ApiClient SHALL 返回一个 NetworkTask 句柄，该句柄提供取消能力和异步获取结果的能力
2. WHEN 调用方对 NetworkTask 调用取消操作, THE ApiClient SHALL 取消底层的 URLSession 数据任务，并使结果以 CancellationError 完成
3. WHILE 一个 NetworkTask 已被取消, THE ApiClient SHALL 跳过该请求的拦截器链执行和重试逻辑
4. THE ApiClient SHALL 保持现有的 `sendRequest` 异步接口作为便捷方法，内部委托给 NetworkTask 机制
5. WHEN 调用方发起 SSE 流式请求, THE ApiClient SHALL 返回一个可取消的 NetworkTask 句柄，取消时终止底层字节流连接
6. IF NetworkTask 在请求完成后被取消, THEN THE ApiClient SHALL 忽略该取消操作，不产生错误

### 需求 2：基于迭代的重试机制

**用户故事：** 作为一名 iOS 开发者，我希望请求重试通过迭代循环而非递归调用实现，以便重试逻辑更易理解、调试，且不会因深层递归导致栈溢出风险。

#### 验收标准

1. THE ApiClient SHALL 使用迭代循环（while 循环）替代递归调用来实现请求重试
2. THE ApiClient SHALL 定义最大重试次数上限，防止无限重试循环
3. WHEN 拦截器在 `onError` 中调用 handler.retry 触发重试, THE ApiClient SHALL 在同一迭代循环内重新从 onRequest 拦截器链开始执行请求，而非递归调用 sendRequest
4. WHEN 重试次数达到最大上限, THE ApiClient SHALL 抛出最近一次的错误，停止重试
5. WHEN 请求在重试循环中被取消, THE ApiClient SHALL 立即退出循环并抛出 CancellationError
6. THE ApiClient SHALL 在每次重试时重新执行完整的 onRequest 拦截器链，确保使用最新的认证令牌

### 需求 3：抽象拦截器接口设计

**用户故事：** 作为一名 iOS 开发者，我希望网络拦截器采用统一的抽象接口设计（参考 Dio 框架），通过 `onRequest`、`onResponse`、`onError` 三个生命周期拦截点和 Handler 机制实现链式拦截，以便拦截器的职责更清晰、扩展性更强。

#### 验收标准

1. THE NetworkInterceptor 协议 SHALL 定义三个抽象方法：`onRequest`（请求发送前拦截）、`onResponse`（响应成功后拦截）、`onError`（请求出错后拦截）
2. THE `onRequest` 方法 SHALL 接收 URLRequest 和一个 RequestInterceptorHandler，拦截器通过调用 handler 的 `next` 方法传递修改后的请求到下一个拦截器，或调用 `reject` 方法短路拒绝请求
3. THE `onResponse` 方法 SHALL 接收 Response 和一个 ResponseInterceptorHandler，拦截器通过调用 handler 的 `next` 方法传递响应到下一个拦截器，或调用 `reject` 方法将响应转为错误
4. THE `onError` 方法 SHALL 接收 Error、URLRequest 和一个 ErrorInterceptorHandler，拦截器通过调用 handler 的 `next` 方法传递错误到下一个拦截器，或调用 `retry` 方法触发请求重试
5. THE NetworkInterceptor 协议 SHALL 为三个方法提供默认实现，默认行为为直接调用 handler 的 `next` 方法（透传），使拦截器只需覆写关心的方法
6. WHEN 多个拦截器被注册, THE ApiClient SHALL 按注册顺序依次执行拦截器链：onRequest 按正序执行，onResponse 和 onError 按正序执行
7. THE NetworkInterceptor 协议 SHALL 要求遵循 Sendable 协议，确保并发安全
8. WHEN 拦截器在 `onError` 中调用 `retry`, THE ApiClient SHALL 重新从拦截器链的 onRequest 阶段开始执行请求，并受最大重试次数限制

### 需求 4：现有拦截器迁移兼容

**用户故事：** 作为一名 iOS 开发者，我希望现有的 AuthInterceptor、RefreshTokenInterceptor 和 LogoutInterceptor 能够平滑迁移到新的拦截器接口，以便不破坏现有的认证和登出流程。

#### 验收标准

1. WHEN 迁移完成, THE AuthInterceptor SHALL 遵循新的 NetworkInterceptor 协议，仅覆写 `onRequest` 方法，在请求发送前添加 Bearer 认证头，然后调用 handler.next 传递请求
2. WHEN 迁移完成, THE RefreshTokenInterceptor SHALL 遵循新的 NetworkInterceptor 协议，仅覆写 `onError` 方法，在收到 401 错误时刷新令牌并调用 handler.retry 触发重试
3. WHEN 迁移完成, THE LogoutInterceptor SHALL 遵循新的 NetworkInterceptor 协议，仅覆写 `onError` 方法，在令牌刷新失败后清除令牌、发布过期事件，然后调用 handler.next 传递错误
4. THE RefreshTokenInterceptor SHALL 保留现有的 actor 隔离和请求池去重机制，防止并发刷新令牌
5. IF 令牌刷新失败, THEN THE RefreshTokenInterceptor SHALL 调用 handler.next 传递错误，使错误流转到下一个拦截器（LogoutInterceptor）的 onError 方法处理
6. THE ApiClient 的初始化接口 SHALL 接受统一的 `[NetworkInterceptor]` 数组参数，拦截器按注册顺序执行

### 需求 5：错误处理一致性

**用户故事：** 作为一名 iOS 开发者，我希望优化后的 ApiClient 保持与现有代码一致的错误类型和错误处理行为，以便上层业务代码无需修改错误处理逻辑。

#### 验收标准

1. THE ApiClient SHALL 对 HTTP 2xx 响应返回 Response 对象，行为与现有实现一致
2. WHEN HTTP 响应状态码为非 2xx 且非重试场景, THE ApiClient SHALL 抛出 AppNetworkError.httpError，包含状态码和响应体
3. WHEN 网络连接失败, THE ApiClient SHALL 抛出 AppNetworkError.networkError，包含调试描述和 URLError 错误码
4. WHEN 请求被取消, THE ApiClient SHALL 抛出 CancellationError，而非 AppNetworkError
5. IF RequestAdapter 在 onRequest 拦截过程中抛出错误, THEN THE ApiClient SHALL 将该错误直接传播给调用方，不触发重试逻辑
