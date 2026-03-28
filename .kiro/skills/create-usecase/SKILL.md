---
name: create-usecase
description: 当我要求新增 API 请求、创建 UseCase 或对接新接口时触发。用于标准化生成 Swift 项目中的 DTO、Domain Model、Request、Repository 和 UseCase 代码。
---

# 角色与目标
你是一个资深的 iOS 架构师，负责在当前项目中按照标准的 Clean Architecture 流程，自动化生成网络请求和业务逻辑层（UseCase）的模板代码。请严格遵循以下步骤和代码规范，**不要随意省略步骤或更改文件路径规范**。
 
## 输入

用户会提供：
1. API 端点信息（通常已记录在 `app/LTApp/API/api.md` 中）
2. 所属的业务模块名称（如 Report、Reflection、User 等）

## 创建流程

### Step 1: 确认 API 信息

从 `app/LTApp/API/api.md` 中读取对应 API 的详细信息，确认：
- HTTP Method (GET/POST/PUT/DELETE)
- Endpoint path
- Request parameters（query params 或 body）
- Response 数据结构

### Step 2: 创建 DTO（如需要）

路径：`app/LTApp/LTApp/Source/Service/DTO/{ResponseName}DTO.swift`

模板：
```swift
//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct {Name}DTO: Decodable {
    // 字段与 API 响应 JSON 对应
    // 使用 CodingKeys 处理 snake_case -> camelCase 映射

    enum CodingKeys: String, CodingKey {
        // case fieldName = "field_name"
    }
}

extension {Name}DTO {
    func toDomain() -> {Name} {
        // 转换为 Domain Model
    }
}
```

规则：
- DTO 后缀 `DTO`，放在 `Source/Service/DTO/` 目录
- 实现 `Decodable`
- 提供 `toDomain()` 方法转换为 Domain Model
- snake_case 字段用 `CodingKeys` 映射
- 日期字符串在 `toDomain()` 中用 `AppDateFormatter` 转换

### Step 3: 创建 Domain Model（如需要）

路径：`app/LTApp/LTApp/Source/Service/{Module}/Model/{Name}.swift`

模板：
```swift
//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct {Name}: Sendable {
    // Domain 字段，使用 Swift 原生类型
    // 日期用 Date，不用 String
}
```

规则：
- 不带 DTO 后缀
- 遵循 `Sendable`
- 放在对应模块的 `Model/` 目录

### Step 4: 添加 Request case

路径：`app/LTApp/LTApp/Source/Service/{Module}/Request/{Module}Request.swift`

在已有的 Request enum 中添加新的 case：

```swift
case {requestName}({parameters})
```

并在 `endPoint`、`method`、`payload` 的 switch 中添加对应分支。

规则：
- GET 请求参数用 `.urlEncoding([(...)])` 或 `.empty`
- POST 请求 body 用 `.json(body:urlParameter:)`
- 可选参数在 payload 中做 nil 检查

### Step 5: 添加 Repository 方法

路径：`app/LTApp/LTApp/Source/Service/{Module}/Repository/{Module}Repository.swift`

1. 在 `{Module}RepositoryType` protocol 中添加方法声明
2. 在 `{Module}Repository` class 中添加实现

Repository 方法模板：
```swift
public func {methodName}({params}) async throws -> {DomainModel} {
    let request = {Module}Request.{caseName}({args})
    let response = try await apiClient.sendRequest(request)
    let dto: UniversalResponse<{Name}DTO> = try response.parseJson()
    return dto.data.toDomain()
}
```

### Step 6: 创建 UseCase

路径：`app/LTApp/LTApp/Source/Service/{Module}/UseCase/{UseCaseName}UseCase.swift`

模板：
```swift
//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public protocol {UseCaseName}UseCaseType: Sendable {
    func execute({params}) async throws -> {ReturnType}
}

public class {UseCaseName}UseCase: {UseCaseName}UseCaseType, @unchecked Sendable {
    private let repository: any {Module}RepositoryType

    public init(repository: any {Module}RepositoryType) {
        self.repository = repository
    }

    public func execute({params}) async throws -> {ReturnType} {
        try await repository.{repositoryMethod}({args})
    }
}
```

命名规则：
- Fetch 类：`Fetch{Entity}UseCase`
- 创建类：`Create{Entity}UseCase`
- 更新类：`Update{Entity}UseCase`
- 删除类：`Delete{Entity}UseCase`
- 其他动作：`{Action}{Entity}UseCase`

### Step 7: 注入到 AppDataWithAuthorizationService

路径：`app/LTApp/LTApp/Source/Service/AppDataWithAuthorizationService.swift`

1. 在 `AppDataWithAuthorizationServiceful` protocol 中添加属性声明：
```swift
var {useCasePropertyName}: any {UseCaseName}UseCaseType { get }
```

2. 在 `AppDataWithAuthorizationService` class 中添加 lazy 属性：
```swift
public lazy var {useCasePropertyName}: any {UseCaseName}UseCaseType = {
    return {UseCaseName}UseCase(repository: {module}Repository)
}()
```

属性命名：使用 camelCase，如 `fetchWeeklyReportUseCase`

## 检查清单

创建完成后确认：
- [ ] DTO 文件已创建，包含 `Decodable` 和 `toDomain()`
- [ ] Domain Model 已创建，遵循 `Sendable`
- [ ] Request enum 已添加新 case 及所有 switch 分支
- [ ] Repository protocol 和 implementation 已更新
- [ ] UseCase protocol（`{Name}UseCaseType`）和 class 已创建
- [ ] `AppDataWithAuthorizationService` protocol 和 class 已注入
- [ ] 所有文件头部包含版权注释
