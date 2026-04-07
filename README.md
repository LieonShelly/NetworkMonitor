# The Little Things

一款 iOS 日记/反思应用。用户每天回答引导性问题（"反思"），应用会基于 AI 生成每周洞察报告，包含结构化摘要、分析概览和个性化图标。

## 产品概述

### 核心功能

- **每日反思**：每天推送一道引导性问题（Question of the Day），用户撰写回答后生成专属图标
- **问题线程（Threads）**：按分类浏览问题，支持置顶收藏，查看历史回答和图标时间线
- **问题库（Question Library）**：按分类探索更多问题
- **日历视图**：按日期回顾过往反思记录
- **AI 周报（Insights）**：每周自动生成洞察报告，包含：
  - 周度摘要（Summary）
  - 精华片段（Gem）：场景、证据、洞察
  - 分析概览（Analytical Overview）：多维度主题分析
- **周报历史**：分页浏览历史周报，支持已读/未读筛选
- **引导式入门（Onboarding）**：动画引导 → 选择分类 → 回答第一个问题
- **Apple 登录**：通过 Sign in with Apple 进行身份认证
- **推送通知**：提醒用户每日反思

### 用户流程

```
Apple 登录 → Splash 动画引导 → 选择分类 → 回答第一个问题 → 进入主页
主页包含：Threads（问题线程）| Calendar（日历）| Insights（周报）| User（个人）
```

---

## 技术文档

### 技术栈

| 项目 | 说明 |
|---|---|
| 平台 | iOS 18+ |
| 语言 | Swift 6+ |
| UI 框架 | SwiftUI |
| 响应式 | Combine |
| 并发 | Swift Concurrency（async/await, Actor） |
| 动画 | Lottie 4.5.1 |
| 构建工具 | XcodeGen（项目生成）、Fastlane（CI/CD） |
| 包管理 | Swift Package Manager |
| 认证 | Sign in with Apple（AuthenticationServices） |
| 存储 | KeyChain + UserDefaults |

### 项目结构

```
├── app/LTApp/LTApp/
│   ├── Source/
│   │   ├── App/                # 应用入口、AppDelegate、功能配置、Feature Toggle
│   │   ├── Common/             # 通用组件（Paginator, LoadMoreFooter, FixedHeader）
│   │   ├── Domain/             # 功能模块（每个功能包含 View + ViewModel）
│   │   │   ├── Coordinator/    # 导航协调器（AppCoordinator, HomeCoordinator, PreHomeCoordinator）
│   │   │   ├── Calendar/       # 日历视图
│   │   │   ├── Detail/         # 反思详情、摘要
│   │   │   ├── Home/           # 主页
│   │   │   ├── Insights/       # AI 周报
│   │   │   ├── Notification/   # 通知
│   │   │   ├── Onboarding/     # 引导流程
│   │   │   ├── QuestionLib/    # 问题库
│   │   │   ├── SignIn/         # Apple 登录
│   │   │   ├── Splash/         # 启动动画
│   │   │   ├── Submit/         # 每日回答提交
│   │   │   ├── Thread/         # 问题线程
│   │   │   └── User/           # 用户
│   │   ├── Extensions/         # Swift 类型扩展
│   │   └── Service/            # 数据层
│   │       ├── Auth/           # 认证
│   │       ├── DTO/            # 数据传输对象
│   │       ├── Icon/           # 图标
│   │       ├── Interceptor/    # 网络拦截器（Auth, RefreshToken, Logout）
│   │       ├── Reflection/     # 反思
│   │       ├── Report/         # 周报（Model/ Repository/ Request/ UseCase
│   │       └── User/           # 用户
│   ├── Resource/               # Assets.xcassets、图片资源
│   └── API/                    # API 文档（api.md）
│
├── core/                       # 可复用框架模块
│   ├── Network/                # LTNetwork — HTTP 客户端、拦截器链、请求/响
│   ├── Common/                 # LTCommon — Feature Toggle、依赖注入
│
├── certs/                      # 签名证书和描述文件
└── fastlane/                   # Fastlane 配置、XcodeGen 项目设置
```

### 架构模式

#### MVVM + Coordinator

- 每个功能模块在 `Domain/` 下包含 `View/`（SwiftUI 视图）和 `ViewModel/`（业务逻辑）
- ViewModel 为 `ObservableObject` 类，通过 `@StateObject` 或 `@EnvironmentObject` 注入
- 三个 Coordinator 管理导航：
  - `AppCoordinator`：根导航，管理 preHome / home 切换
  - `PreHomeCoordinator`：登录前流程（登录 → Splash → Onboarding → 首次回答）
  - `HomeCoordinator`：主页内导航

#### Clean Architecture 服务层

每个服务领域（如 `Report/`）遵循以下结构：

```
Service/{Domain}/
├── Model/        # 领域模型（纯 Swift 结构体）
├── DTO/          # Decodable API 响应类型，包含 toDomain() 映射方法
├── Request/      # API 请求定义，遵循 Request 协议（枚举实现）
├── Repository/   # 协议 + 实现，调用 ApiClient 并将 DTO 映射为领域模型
└── UseCase/      # 协议 + 实现，单一职责的业务操作
```

#### 依赖注入

- `AppCoordinator` 在启动时构建完整依赖图
- `AppDataWithAuthorizationService` 作为服务定位器，通过 lazy 属性暴露所有 UseCase
- UseCase 通过协议类型属性访问（如 `any FetchWeeklyReportsListUseCaseType`）

#### 网络层

- `ApiClient` 处理请求执行，支持拦截器链和重试逻辑（最大重试 2 次）
- 拦截器链：`AuthInterceptor`（附加 Token）→ `RefreshTokenInterceptor`（刷新过期 Token）→ `LogoutInterceptor`（处理强制登出）
- 请求为枚举类型，遵循 `Request` 协议，定义 `endPoint`、`method`、`payload`
- API 响应统一包装在 `UniversalResponse<T>` 中
- 支持 SSE 流式请求（`sendSSERequest`）

#### Feature Toggle

- 通过 `LTAppFeatureConfig` 枚举定义功能开关
- 支持三个阶段：`underDevelopment` → `internal` → `release`
- 通过 `InjectionValues` 依赖注入系统全局访问

### 后端 API

- 基础 URL：`https://things.dvacode.tech`
- 认证方式：Bearer Token（Authorization header）
- API 文档：`app/LTApp/API/api.md`
- 所有路径以 `/api` 开头

### 常用命令

```bash
# 生成 Xcode 项目（通过 XcodeGen）
bundle exec fastlane generate_project

# 构建并上传到 TestFlight
bundle exec fastlane internal_test

# 运行 Network 模块测试（SPM）
cd core/Network && swift test
```

### Core 模块说明

| 模块 | 产物名称 | 用途 |
|---|---|---|
| Network | LTNetwork | HTTP 客户端、拦截器、请求/响应管道（SPM + XcodeGen 双构建） |
| Common | LTCommon | Feature Toggle、依赖注入容器 |
| Persistence | Persistence | KeyChain 和 UserDefaults 存储抽象 |
| UIComponent | UIComponent | 共享 UI 组件（按钮、文字样式、圆角、Lottie 动画、颜色系统） |
