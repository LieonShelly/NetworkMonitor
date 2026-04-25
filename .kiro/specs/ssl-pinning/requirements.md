# 需求文档：SSL Pinning（公钥证书固定）

## 简介

为 LTNetwork 网络层添加 SSL Pinning（公钥证书固定）功能，防止中间人攻击（MITM）。该功能通过在每次 API 请求时校验服务器公钥的 SHA-256 哈希值是否与本地预置的哈希值一致来保障通信安全。SSL Pinning 的校验逻辑由 App 层注入，LTNetwork 模块仅定义协议接口，不包含具体实现。该功能仅在 release 环境中启用。

## 术语表

- **SSL_Pinning_Validator**: SSL 公钥证书固定校验器的协议抽象，定义在 LTNetwork 模块中，由 App 层提供具体实现
- **ApiClient**: LTNetwork 模块中的网络请求客户端，负责发送 HTTP 请求并执行拦截器链
- **AppEnvironment**: LTNetwork 模块中定义的应用环境枚举，包含 `dev`、`stagging`、`release` 三种环境
- **Public_Key_Hash**: 服务器证书公钥经 SHA-256 算法计算后的 Base64 编码字符串
- **URLAuthenticationChallenge**: iOS 系统在 TLS 握手阶段发出的身份验证质询，包含服务器证书信息
- **CryptoKit**: Apple 原生加密框架，用于执行 SHA-256 哈希计算
- **App_Layer**: 应用层（`app/LTApp/`），负责注入 SSL Pinning 的具体实现逻辑

## 需求

### 需求 1：SSL Pinning 协议定义

**用户故事：** 作为开发者，我希望 LTNetwork 模块提供一个 SSL Pinning 校验协议，以便 App 层可以注入具体的校验实现，保持网络模块的解耦。

#### 验收标准

1. THE SSL_Pinning_Validator 协议 SHALL 定义一个 `isDisabled` 布尔属性，用于表示 SSL Pinning 是否被禁用
2. THE SSL_Pinning_Validator 协议 SHALL 定义一个 `pinnedPublicKeyHashes` 属性，返回 Public_Key_Hash 字符串数组
3. THE SSL_Pinning_Validator 协议 SHALL 定义一个接受 URLAuthenticationChallenge 和 AppEnvironment 参数的校验方法，返回校验结果
4. THE SSL_Pinning_Validator 协议 SHALL 遵循 Sendable 协议，以支持 Swift 并发安全
5. THE SSL_Pinning_Validator 协议 SHALL 定义在 LTNetwork 模块中，作为公开（public）协议供 App 层实现

### 需求 2：ApiClient 集成 SSL Pinning

**用户故事：** 作为开发者，我希望 ApiClient 在每次 API 请求时自动执行 SSL Pinning 校验，以确保所有网络通信的安全性。

#### 验收标准

1. THE ApiClient SHALL 接受一个可选的 SSL_Pinning_Validator 实例作为构造参数
2. WHEN ApiClient 持有 SSL_Pinning_Validator 实例且 `isDisabled` 为 false 时，THE ApiClient SHALL 通过 URLSessionDelegate 在 TLS 握手阶段执行公钥校验
3. WHEN SSL_Pinning_Validator 的 `isDisabled` 属性为 true 时，THE ApiClient SHALL 跳过 SSL Pinning 校验，使用系统默认的证书验证
4. THE ApiClient SHALL 仅调用 SSL_Pinning_Validator 协议方法，不包含任何具体的 SSL Pinning 校验逻辑
5. WHEN SSL_Pinning_Validator 未被注入（为 nil）时，THE ApiClient SHALL 使用系统默认的证书验证行为

### 需求 3：公钥哈希校验实现

**用户故事：** 作为开发者，我希望 App 层提供 SSL Pinning 的具体校验实现，使用 CryptoKit 对服务器公钥进行 SHA-256 哈希比对，以防止中间人攻击。

#### 验收标准

1. WHEN 收到 URLAuthenticationChallenge 时，THE App_Layer 的校验实现 SHALL 从服务器证书链中提取公钥数据
2. WHEN 提取到公钥数据后，THE App_Layer 的校验实现 SHALL 使用 CryptoKit 的 SHA256 算法计算公钥的哈希值
3. WHEN 计算出公钥哈希后，THE App_Layer 的校验实现 SHALL 将该哈希值与 `pinnedPublicKeyHashes` 数组中的值逐一比对
4. WHEN 公钥哈希与 `pinnedPublicKeyHashes` 中的任意一个值匹配时，THE App_Layer 的校验实现 SHALL 返回校验通过的结果
5. WHEN 公钥哈希与 `pinnedPublicKeyHashes` 中的所有值均不匹配时，THE App_Layer 的校验实现 SHALL 返回校验失败的结果
6. IF 无法从服务器证书中提取公钥数据，THEN THE App_Layer 的校验实现 SHALL 返回校验失败的结果

### 需求 4：环境感知的启用控制

**用户故事：** 作为开发者，我希望 SSL Pinning 仅在 release 环境中启用，在 dev 和 stagging 环境中禁用，以便开发和测试阶段可以使用代理工具调试网络请求。

#### 验收标准

1. WHILE AppEnvironment 为 `release` 时，THE App_Layer 的校验实现 SHALL 将 `isDisabled` 设置为 false，启用 SSL Pinning 校验
2. WHILE AppEnvironment 为 `dev` 时，THE App_Layer 的校验实现 SHALL 将 `isDisabled` 设置为 true，禁用 SSL Pinning 校验
3. WHILE AppEnvironment 为 `stagging` 时，THE App_Layer 的校验实现 SHALL 将 `isDisabled` 设置为 true，禁用 SSL Pinning 校验

### 需求 5：依赖注入与组装

**用户故事：** 作为开发者，我希望 SSL Pinning 的实现通过 AppCoordinator 注入到 ApiClient 中，遵循现有的依赖注入模式，保持架构一致性。

#### 验收标准

1. THE AppCoordinator SHALL 创建 App_Layer 的 SSL Pinning 校验实现实例，并传入当前的 AppEnvironment
2. THE AppCoordinator SHALL 将 SSL Pinning 校验实现实例注入到所有 ApiClient 实例的构造过程中
3. THE AppCoordinator SHALL 确保带拦截器的 ApiClient 和不带拦截器的 ApiClient 均接收相同的 SSL Pinning 校验实例

### 需求 6：SSL Pinning 校验失败处理

**用户故事：** 作为开发者，我希望 SSL Pinning 校验失败时网络请求被明确拒绝，并产生可识别的错误，以便上层代码能够正确处理安全异常。

#### 验收标准

1. WHEN SSL Pinning 校验失败时，THE ApiClient SHALL 取消当前的 TLS 连接
2. WHEN SSL Pinning 校验失败时，THE ApiClient SHALL 抛出一个可识别的网络错误，使调用方能够区分 SSL Pinning 失败与其他网络错误
3. IF URLAuthenticationChallenge 的认证方法不是 `NSURLAuthenticationMethodServerTrust`，THEN THE App_Layer 的校验实现 SHALL 拒绝该质询
