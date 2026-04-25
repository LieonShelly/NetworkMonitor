# 实现计划：SSL Pinning（公钥证书固定）

## 概述

本计划将 SSL Pinning 功能分为 LTNetwork 模块层（协议定义、SessionDelegate、ApiClient 修改、错误类型扩展）和 App 层（具体校验实现、依赖注入）两部分，按增量方式逐步实现并验证。所有代码使用 Swift 编写，测试通过 `cd core/Network && swift test` 运行。

## 任务

- [x] 1. 在 LTNetwork 模块中定义 SSLPinningValidating 协议与 SSLPinningResult 枚举
  - [x] 1.1 创建 `core/Network/Source/Model/SSLPinningValidating.swift` 文件
    - 定义 `SSLPinningResult` 枚举，包含 `.success(URLCredential)`、`.failure`、`.performDefaultHandling` 三个 case，遵循 `Sendable`
    - 定义 `SSLPinningValidating` 协议，遵循 `Sendable`，包含 `isDisabled: Bool`、`pinnedPublicKeyHashes: [String]` 属性和 `validate(challenge:environment:)` 方法
    - 所有类型标记为 `public`
    - _需求: 1.1, 1.2, 1.3, 1.4, 1.5_

- [x] 2. 扩展 AppNetworkError 新增 sslPinningFailed 错误类型
  - [x] 2.1 在 `core/Network/Source/Model/AppNetworkError.swift` 中新增 `sslPinningFailed` case
    - 在 `AppNetworkError` 枚举中添加 `case sslPinningFailed`
    - _需求: 6.2_

- [x] 3. 在 ApiClient 中实现 SessionDelegate 并集成 SSL Pinning
  - [x] 3.1 在 `core/Network/Source/ApiClient.swift` 中创建 `SessionDelegate` 内部类
    - 创建 `final class SessionDelegate: NSObject, URLSessionDelegate, @unchecked Sendable`
    - 持有可选的 `(any SSLPinningValidating)?` 和 `AppEnvironment`
    - 实现 `urlSession(_:didReceive:completionHandler:)` 方法
    - 当 validator 为 nil 或 `isDisabled` 为 true 时，调用 `.performDefaultHandling`
    - 当 validator 启用时，调用 `validate(challenge:environment:)` 并根据结果分发 `.useCredential`、`.cancelAuthenticationChallenge` 或 `.performDefaultHandling`
    - _需求: 2.2, 2.3, 2.5, 6.1_

  - [x] 3.2 修改 `ApiClient` 构造函数，新增可选参数 `sslPinningValidator`
    - 在 `init` 中新增 `sslPinningValidator: (any SSLPinningValidating)? = nil` 参数
    - 创建 `SessionDelegate` 实例并传入 validator 和 environment
    - 将 `URLSession` 的创建改为 `URLSession(configuration:delegate:delegateQueue:)`
    - 保存 `sslPinningValidator` 引用供错误处理使用
    - _需求: 2.1, 2.4, 2.5_

  - [x] 3.3 在 `executeWithRetry` 方法中添加 SSL Pinning 失败的错误转换逻辑
    - 在 `session.data(for:)` 的 catch 块中，当 SSL Pinning 启用且收到 `URLError(.cancelled)` 时，抛出 `AppNetworkError.sslPinningFailed`
    - 同样在 `sendSSERequest` 的错误处理中添加相同的 SSL Pinning 失败识别逻辑
    - _需求: 6.1, 6.2_

- [x] 4. 检查点 - 确保 LTNetwork 模块编译通过
  - 运行 `cd core/Network && swift build` 确保模块编译无误，如有问题请询问用户。

- [ ] 5. 为 LTNetwork 模块编写测试
  - [ ]* 5.1 编写 SessionDelegate 的单元测试
    - 在 `core/Network/Tests/SSLPinningTests.swift` 中创建测试文件
    - 创建 `MockSSLPinningValidator` 测试替身，实现 `SSLPinningValidating` 协议
    - 测试 validator 为 nil 时调用 `.performDefaultHandling`
    - 测试 `isDisabled == true` 时调用 `.performDefaultHandling`
    - 测试校验成功时调用 `.useCredential`
    - 测试校验失败时调用 `.cancelAuthenticationChallenge`
    - _需求: 2.2, 2.3, 2.5_

  - [ ]* 5.2 编写属性测试：哈希成员关系决定校验结果
    - **Property 1: 哈希成员关系决定校验结果**
    - **验证: 需求 3.3, 3.4, 3.5**
    - 在 `core/Network/Tests/SSLPinningTests.swift` 中添加属性测试
    - 随机生成哈希字符串和哈希数组，循环至少 100 次
    - 当哈希在数组中时验证比对返回匹配，不在时返回不匹配
    - 覆盖边界情况：空数组、单元素数组、大量元素数组

  - [ ]* 5.3 编写属性测试：环境决定禁用状态
    - **Property 2: 环境决定禁用状态**
    - **验证: 需求 4.1, 4.2, 4.3**
    - 遍历所有 `AppEnvironment` 值（`.dev`, `.stagging`, `.release`）
    - 验证 `isDisabled` 与 `environment != .release` 一致

- [x] 6. 在 App 层实现 SSLPinningValidator
  - [x] 6.1 创建 `app/LTApp/LTApp/Source/Service/Network/SSLPinningValidator.swift`
    - 定义 `struct SSLPinningValidator: SSLPinningValidating`
    - 根据传入的 `AppEnvironment` 设置 `isDisabled`（仅 `.release` 时为 `false`）
    - 持有 `pinnedPublicKeyHashes` 数组
    - 实现 `validate(challenge:environment:)` 方法：
      - 校验 `authenticationMethod` 是否为 `NSURLAuthenticationMethodServerTrust`
      - 从 `serverTrust` 中提取证书链和公钥数据
      - 使用 CryptoKit SHA256 计算公钥哈希的 Base64 编码
      - 与 `pinnedPublicKeyHashes` 逐一比对，匹配则返回 `.success`，否则返回 `.failure`
      - 无法提取公钥时返回 `.failure`
    - _需求: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 4.1, 4.2, 4.3, 6.3_

- [x] 7. 在 AppCoordinator 中注入 SSLPinningValidator
  - [x] 7.1 修改 `app/LTApp/LTApp/Source/Domain/Coordinator/AppCoordinator.swift`
    - 在 `init(environment:)` 方法中创建 `SSLPinningValidator` 实例，传入当前 environment 和预置的公钥哈希数组
    - 将 `sslPinningValidator` 注入到 `interceptorClient`（不带拦截器的 ApiClient）
    - 将同一个 `sslPinningValidator` 注入到 `apiClient`（带拦截器的 ApiClient）
    - 确保两个 ApiClient 实例共享同一个 validator 实例
    - _需求: 5.1, 5.2, 5.3_

- [x] 8. 检查点 - 确保完整项目编译通过
  - 运行 `cd core/Network && swift test` 确保 LTNetwork 模块测试通过，如有问题请询问用户。

## 备注

- 标记 `*` 的子任务为可选任务，可跳过以加速 MVP 交付
- 每个任务均引用了对应的需求编号，确保可追溯性
- 检查点任务用于增量验证，确保每个阶段的代码正确性
- 属性测试验证设计文档中定义的通用正确性属性
- 单元测试验证具体的示例和边界情况
- 公钥哈希值（`pinnedPublicKeyHashes`）需替换为实际服务器证书的 SHA-256 哈希，可使用占位符 `"YOUR_BASE64_ENCODED_SHA256_HASH_HERE"` 先行开发
