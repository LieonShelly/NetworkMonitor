# 项目工程架构文档

## 1. 架构概览

这是一个基于 **Clean Architecture** 和 **Feature-First** 组织方式的 Flutter 应用，采用现代化的状态管理和依赖注入方案。

### 核心技术栈
- **状态管理**: Riverpod (flutter_riverpod + riverpod_annotation)
- **路由管理**: GoRouter
- **网络请求**: Dio
- **数据序列化**: Freezed + JSON Serializable
- **本地存储**: Flutter Secure Storage
- **图片加载**: Cached Network Image
- **代码生成**: Build Runner

### 架构分层

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│    (UI + State Management)              │
│  - Pages, Widgets, Controllers          │
└─────────────────────────────────────────┘
              ↓ ↑
┌─────────────────────────────────────────┐
│         Business Logic Layer            │
│         (Use Cases)                     │
│  - 业务逻辑封装                          │
└─────────────────────────────────────────┘
              ↓ ↑
┌─────────────────────────────────────────┐
│         Data Layer                      │
│    (Repository + DTO)                   │
│  - 数据获取和转换                        │
└─────────────────────────────────────────┘
              ↓ ↑
┌─────────────────────────────────────────┐
│         Core Layer                      │
│  (Network, Storage, Theme, Utils)       │
│  - 基础设施和工具                        │
└─────────────────────────────────────────┘
```

---

## 2. 目录结构详解

### 2.1 整体结构

```
lib/
├── main.dart                    # 应用入口
├── examples/                    # 示例代码（学习用）
└── src/
    ├── app_router.dart          # 全局路由配置
    ├── core/                    # 核心基础设施层
    ├── features/                # 功能模块层（按业务划分）
    ├── service/                 # 数据服务层
    └── shared/                  # 共享资源（目前为空）
```

### 2.2 Core Layer（核心层）

**职责**: 提供应用的基础设施和通用工具，不依赖业务逻辑

```
core/
├── network/                     # 网络层
│   ├── api_client.dart          # API客户端接口定义
│   ├── http_api_client.dart     # Dio实现的HTTP客户端
│   ├── network_provider.dart    # 网络服务Provider
│   ├── network_config.dart      # 网络配置
│   ├── app_exception.dart       # 统一异常处理
│   ├── auth_interceptor.dart    # 认证拦截器
│   ├── refresh_token_interceptor.dart  # Token刷新拦截器
│   └── token_storage.dart       # Token存储接口
│
├── storage/                     # 本地存储
│   ├── secure_token_storage.dart    # 安全存储实现
│   └── mock_token_storage.dart      # Mock存储（开发用）
│
├── theme/                       # 主题配置
│   ├── app_style.dart           # 应用样式定义
│   ├── icon_name.dart           # 图标名称常量
│   └── theme.dart               # 主题配置
│
├── ui_component/                # 通用UI组件
│   ├── app_tabbar.dart          # 自定义TabBar
│   ├── svg_asset.dart           # SVG资源加载
│   ├── keep_alive_page.dart     # 页面保活组件
│   └── image_cache_key.dart     # 图片缓存Key
│
├── router/                      # 路由基础设施（新增）
├── image_processor/             # 图片处理
└── date_utl.dart                # 日期工具
```

**设计模式**:
- **接口抽象**: `ApiClientType`、`TokenStorage` 定义接口，便于测试和替换实现
- **Provider模式**: 使用Riverpod管理依赖注入
- **拦截器模式**: 网络请求的认证和Token刷新

### 2.3 Service Layer（数据服务层）

**职责**: 封装数据获取逻辑，提供干净的数据接口给上层

```
service/
├── dto/                         # Data Transfer Objects
│   ├── calendar_reflection_model.dart   # 日历反思数据模型
│   ├── answer_submitted_param.dart      # 答案提交参数
│   └── dto_model.dart           # DTO基类
│
├── repository/                  # 仓储层
│   ├── reflection_repository.dart       # 反思数据仓储实现
│   ├── reflection_repository_type.dart  # 仓储接口定义
│   └── repository.dart          # 仓储导出
│
├── usecase/                     # 用例层（业务逻辑）
│   ├── calendar_fetch_reflection_usecase.dart  # 获取日历反思
│   ├── fetch_thread_questions_usecase.dart     # 获取Thread问题
│   ├── fetch_today_question_usecase.dart       # 获取今日问题
│   ├── submit_answer_usecase.dart              # 提交答案
│   └── usecase.dart             # UseCase导出
│
├── providers/                   # Service层Provider
│   └── providers.dart           # 统一导出所有Provider
│
└── chain_service.dart           # 区块链服务
```

**设计模式**:
- **Repository模式**: 抽象数据来源，Repository负责数据获取和转换
- **UseCase模式**: 每个UseCase封装一个具体的业务操作
- **DTO模式**: 使用Freezed生成不可变数据类，类型安全

**数据流**:
```
UI → Controller → UseCase → Repository → ApiClient → Backend
                                ↓
                              DTO转换
```

### 2.4 Features Layer（功能模块层）

**职责**: 按业务功能组织UI和状态管理，每个feature相对独立

```
features/
├── home_view.dart               # 主页容器（StatefulShellRoute）
│
├── calendar/                    # 日历模块
│   ├── calendar_page.dart       # 日历页面
│   ├── calendar_controller.dart # 日历状态管理
│   ├── calendar_content_view.dart
│   ├── calendar_item_view.dart
│   ├── calendar_month_view.dart
│   └── calendar_month_header_view.dart
│
├── thread/                      # Thread模块
│   ├── thread_page.dart         # Thread页面
│   └── thread_page_controller.dart  # Thread状态管理
│
├── copilot/                     # AI助手模块
│   └── chat_page.dart           # 聊天页面
│
├── user/                        # 用户模块
│   └── user_home.dart           # 用户主页
│
├── add_answer/                  # 添加答案模块
│   ├── add_answer_page.dart
│   └── add_answer_controller.dart
│
├── answer_detail/               # 答案详情模块
│   └── answer_detail_page.dart
│
├── today_question/              # 今日问题模块
│   ├── today_question_banner_view.dart
│   └── today_question_banner_controller.dart
│
├── wallet/                      # 钱包模块
│   └── balance_page.dart
│
├── common/                      # 通用组件
│   └── processed_icon_view.dart
│
└── render_spike/                # 渲染实验
    └── custom_circle_wrapper.dart
```

**Feature组织原则**:
- 每个feature包含该功能的所有UI和状态管理代码
- Controller使用Riverpod的`@riverpod`注解生成Provider
- 使用Freezed生成不可变的State类
- 页面通过`ref.watch()`监听状态变化

**典型Feature结构**:
```dart
// State定义（使用Freezed）
@freezed
class ThreadPageState with _$ThreadPageState {
  final AsyncValue<List<QuestionModel>> questions;
  ThreadPageState({required this.questions});
}

// Controller定义（使用Riverpod）
@riverpod
class ThreadPageController extends _$ThreadPageController {
  @override
  ThreadPageState build() {
    _fetchThreadData();
    return ThreadPageState(questions: AsyncValue.loading());
  }
  
  void _fetchThreadData() async {
    final useCase = ref.read(fetchThreadQuestionsUseCaseProvider);
    // 业务逻辑...
  }
}
```

---

## 3. 核心设计模式

### 3.1 状态管理模式（Riverpod）

**Provider类型使用**:
- `Provider`: 不可变的依赖注入（如ApiClient、Repository）
- `@riverpod`: 自动生成Provider，支持自动dispose
- `AsyncValue`: 处理异步状态（loading、data、error）

**示例**:
```dart
// 依赖注入
final apiClientProvider = Provider<ApiClientType>((ref) {
  return HttpApiClient(baseUrl: kBaseUrl);
});

// 状态管理
@riverpod
class ThreadPageController extends _$ThreadPageController {
  @override
  ThreadPageState build() {
    // 初始化逻辑
  }
}

// UI消费
class ThreadPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(threadPageControllerProvider);
    // 根据state渲染UI
  }
}
```

### 3.2 路由管理模式（GoRouter）

**当前实现**:
- 使用`StatefulShellRoute.indexedStack`实现底部导航
- 使用`parentNavigatorKey`控制页面堆栈层级
- 支持自定义页面转场动画

**路由配置**:
```dart
GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutePath.thread,
  routes: [
    StatefulShellRoute.indexedStack(
      // 底部Tab页面
      branches: [...]
    ),
    GoRoute(
      // 全屏页面
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutePath.answerDetail,
      ...
    ),
  ],
)
```

**问题**: 所有路由集中在一个文件，不利于模块化
**解决方案**: 参考 `router-architecture-decoupling.md`

### 3.3 网络请求模式

**分层设计**:
```
Controller → UseCase → Repository → ApiClient → Dio
```

**特点**:
- 使用拦截器处理认证和Token刷新
- 统一异常处理（AppException）
- 支持多个BaseUrl（主API + Chat API）
- 自动绕过localhost代理

**示例**:
```dart
// Repository层
class ReflectionRepository {
  final ApiClientType _apiClient;
  
  Future<List<QuestionModel>> fetchThreadQuestions() async {
    final response = await _apiClient.get('/api/thread-view');
    return (response['data'] as List)
        .map((e) => QuestionModel.fromJson(e))
        .toList();
  }
}

// UseCase层
class FetchThreadQuestionsUseCase {
  final ReflectionRepositoryType _repository;
  
  Future<List<QuestionModel>> execute() {
    return _repository.fetchThreadQuestions();
  }
}

// Controller层
void _fetchThreadData() async {
  final useCase = ref.read(fetchThreadQuestionsUseCaseProvider);
  final list = await useCase.execute();
  state = state.copyWith(questions: AsyncValue.data(list));
}
```

### 3.4 代码生成模式

**使用的生成器**:
- `riverpod_generator`: 生成Provider代码
- `freezed`: 生成不可变数据类和copyWith方法
- `json_serializable`: 生成JSON序列化代码
- `build_runner`: 统一的代码生成工具

**生成命令**:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 4. 依赖关系图

```
┌─────────────────────────────────────────────────────┐
│                   main.dart                         │
│              (ProviderScope + Router)               │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│                  app_router.dart                    │
│              (GoRouter Configuration)               │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│                Features (Pages)                     │
│  calendar | thread | copilot | user | ...          │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│            Controllers (State Management)           │
│         使用 @riverpod + Freezed State              │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│              UseCases (Business Logic)              │
│         封装具体的业务操作                           │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│            Repository (Data Access)                 │
│         API调用 + DTO转换                           │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│              Core (Infrastructure)                  │
│    ApiClient | Storage | Theme | Utils              │
└─────────────────────────────────────────────────────┘
```

**依赖规则**:
- 上层可以依赖下层，下层不能依赖上层
- 同层之间尽量避免直接依赖
- 通过接口（抽象类）解耦具体实现

---

## 5. 数据流向

### 5.1 数据获取流程

```
用户操作 → UI Event
    ↓
Controller.method()
    ↓
UseCase.execute()
    ↓
Repository.fetchXXX()
    ↓
ApiClient.get/post()
    ↓
Dio HTTP Request
    ↓
Backend API
    ↓
JSON Response
    ↓
DTO.fromJson()
    ↓
Repository返回DTO
    ↓
UseCase返回DTO
    ↓
Controller更新State
    ↓
UI自动重建（ref.watch）
```

### 5.2 状态更新流程

```dart
// 1. 初始状态（Loading）
state = ThreadPageState(questions: AsyncValue.loading());

// 2. 发起请求
final list = await useCase.execute();

// 3. 更新为Data状态
state = state.copyWith(questions: AsyncValue.data(list));

// 4. UI自动响应
state.questions.when(
  loading: () => CircularProgressIndicator(),
  data: (list) => ListView(...),
  error: (e, s) => ErrorWidget(e),
)
```

---

## 6. 项目特点和最佳实践

### 6.1 优点

1. **清晰的分层架构**: 职责明确，易于维护和测试
2. **类型安全**: 使用Freezed和JSON Serializable确保类型安全
3. **依赖注入**: Riverpod提供优雅的依赖管理
4. **代码生成**: 减少样板代码，提高开发效率
5. **异步状态管理**: AsyncValue统一处理loading/data/error状态
6. **接口抽象**: 核心组件都有接口定义，便于测试和替换

### 6.2 可改进的地方

1. **路由耦合**: 所有路由集中在一个文件，建议模块化（已有解决方案）
2. **shared目录未使用**: 可以放置跨feature的共享组件
3. **测试覆盖**: 建议添加单元测试和集成测试
4. **错误处理**: 可以统一错误提示UI组件
5. **日志系统**: logger目录为空，建议添加统一日志方案

### 6.3 适用场景

这个架构适合:
- 中大型Flutter应用
- 需要清晰分层和模块化的项目
- 团队协作开发
- 需要高可测试性的项目

---

## 7. 与iOS开发的对比

| 概念 | iOS (UIKit/SwiftUI) | Flutter (本项目) |
|------|---------------------|------------------|
| 状态管理 | Combine / @State | Riverpod + AsyncValue |
| 依赖注入 | Protocol + Factory | Provider |
| 路由 | UINavigationController | GoRouter |
| 网络层 | URLSession / Alamofire | Dio |
| 数据模型 | Codable | Freezed + JSON Serializable |
| 异步处理 | async/await | async/await (相同) |
| UI组件 | UIViewController / View | StatelessWidget / StatefulWidget |
| 生命周期 | viewDidLoad / onAppear | initState / build |

**相似之处**:
- 都采用MVVM/Clean Architecture思想
- 都使用Repository模式管理数据
- 都有依赖注入和状态管理方案

**不同之处**:
- Flutter的Widget是声明式的，类似SwiftUI
- Riverpod的Provider比iOS的依赖注入更轻量
- Flutter的代码生成更加普遍和强大

---

## 8. 学习建议

基于你的iOS背景，建议重点学习:

1. **Riverpod状态管理**: 理解Provider的生命周期和依赖图
2. **Freezed数据类**: 掌握不可变数据和copyWith模式
3. **GoRouter路由**: 理解声明式路由和导航栈管理
4. **Widget生命周期**: 与iOS ViewController的差异
5. **代码生成工具**: build_runner的使用和原理

参考学习计划中的相关章节进行深入学习。
