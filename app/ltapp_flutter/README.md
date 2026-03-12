# Flutter Super App

一个基于 Flutter，采用 Monorepo + 分层架构设计。

## 项目架构

### 整体结构

```
ltapp_flutter/
├── apps/                          # 应用层
│   ├── lt_app/                    # 主应用
│   └── algorithm_app/             # 算法学习模块
│
└── packages/                      # 共享包（按职责分层）
    ├── core/                      # 核心基础设施层
    ├── domain/                    # 功能模块层（Presentation Layer）
    ├── service/                   # 数据服务层（Business Logic + Data Layer）
    └── utls/                      # 工具层
```

### 技术栈

- **状态管理**: Riverpod (flutter_riverpod + riverpod_annotation)
- **路由管理**: GoRouter
- **网络请求**: Dio
- **数据序列化**: Freezed + JSON Serializable
- **本地存储**: Flutter Secure Storage
- **图片加载**: Cached Network Image
- **代码生成**: Build Runner

---

## 分层架构详解

### 1. Apps 层

**lt_app** - 主应用入口
- 应用启动和初始化
- 全局路由配置（GoRouter）
- 依赖注入容器（ProviderScope）
- 聚合各个功能模块

**algorithm_app** - 算法学习
- 独立的算法实现代码
- 包含排序算法（快排、归并等）

### 2. Packages 层

#### Core 层（基础设施）

```
packages/core/
├── lt_uicomponent/        # UI 组件库
│   ├── theme/             # 主题配置（AppStyle、Theme）
│   ├── 通用组件           # TabBar、KeepAlivePage
│   └── image_processor/   # 图片处理
│
├── network/               # 网络层
│   ├── api_client.dart    # API 客户端接口
│   ├── http_api_client.dart  # Dio 实现
│   ├── auth_interceptor.dart # 认证拦截器
│   ├── refresh_token_interceptor.dart  # Token 刷新
│   └── app_exception.dart # 统一异常处理
│
└── storage/               # 本地存储
    └── secure_token_storage.dart
```

#### Domain 层（功能模块 - Presentation Layer）

```
packages/domain/
├── feature_core/          # 核心 UI 组件
├── calendar/              # 日历模块
├── thread/                # Thread 问题列表
├── today_question/        # 今日问题
├── add_answer/            # 添加答案
├── answer_detail/         # 答案详情
├── copilot/               # AI 助手
├── user/                  # 用户中心
└── wallet/                # 钱包功能
```

每个功能模块包含：
- **Page**: UI 页面
- **Controller**: 状态管理（使用 Riverpod）
- **State**: 不可变状态类（使用 Freezed）

#### Service 层（业务逻辑 + 数据访问）

```
packages/service/
├── lt_reflection_service/     # 反思服务
│   ├── dto/                   # 数据传输对象
│   │   ├── calendar_reflection_model.dart
│   │   └── answer_submitted_param.dart
│   │
│   ├── repository/            # 数据仓储
│   │   ├── reflection_repository_type.dart  # 接口定义
│   │   └── reflection_repository.dart       # 实现
│   │
│   ├── usecase/               # 业务用例
│   │   ├── fetch_thread_questions_usecase.dart
│   │   ├── fetch_today_question_usecase.dart
│   │   └── submit_answer_usecase.dart
│   │
│   └── providers/             # Provider 导出
│
└── chain_service/             # 区块链服务
```

#### Utils 层（工具）

```
packages/utls/
├── date_utl/              # 日期工具
└── lt_annotation/         # 自定义注解
```

---

## 数据流向

```
用户操作
    ↓
UI (Widget)
    ↓
Controller (Riverpod)
    ↓ ref.read(useCaseProvider)
UseCase (Business Logic)
    ↓ repository.fetchXXX()
Repository (Data Access)
    ↓ apiClient.get/post()
ApiClient (Network)
    ↓ HTTP Request
Backend API
```

### 状态更新流程

```dart
// 1. Controller 发起请求
final useCase = ref.read(fetchThreadQuestionsUseCaseProvider);
final list = await useCase.execute();

// 2. 更新状态
state = state.copyWith(questions: AsyncValue.data(list));

// 3. UI 自动响应（通过 ref.watch）
ref.watch(threadPageControllerProvider).questions.when(
  loading: () => CircularProgressIndicator(),
  data: (list) => ListView(...),
  error: (e, s) => ErrorWidget(e),
)
```

---

## 与标准 Clean Architecture 的对比

### 标准 Clean Architecture 分层

```
┌─────────────────────────────────────┐
│   Presentation Layer                │  ← UI + Controllers
│   (Widgets, Pages, ViewModels)     │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│   Domain Layer                      │  ← 纯业务逻辑（纯 Dart）
│   (Entities, UseCases, Interfaces)  │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│   Data Layer                        │  ← 数据访问
│   (Repositories, DTOs, DataSources) │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│   Framework Layer                   │  ← 框架和工具
│   (Network, Storage, Platform)      │
└─────────────────────────────────────┘
```

### 本项目的实际分层

```
┌─────────────────────────────────────┐
│   Presentation Layer                │
│   packages/domain/*                 │  ← 包含 Page + Controller
│   (依赖 Flutter 框架)               │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│   Business Logic + Data Layer       │
│   packages/service/*                │  ← UseCase + Repository + DTO
│   (纯 Dart + 少量框架依赖)          │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│   Infrastructure Layer              │
│   packages/core/*                   │  ← Network, Storage, UI Components
└─────────────────────────────────────┘
```

### 主要差异

| 方面 | 标准 Clean Architecture | 本项目实现 |
|------|------------------------|-----------|
| **Domain 层** | 纯 Dart，不依赖框架 | `packages/domain` 实际是 Presentation 层，依赖 Flutter |
| **UseCase 位置** | 在 Domain 层 | 在 Service 层 |
| **Entity** | 独立的业务实体 | 使用 DTO 作为实体 |
| **Repository 接口** | 定义在 Domain 层 | 定义在 Service 层 |
| **命名** | Presentation/Domain/Data | Domain/Service/Core（命名有误导性）|

### 符合 Clean Architecture 的部分

✅ **分层清晰**：职责明确，依赖方向正确（上层依赖下层）

✅ **UseCase 模式**：封装业务逻辑
```dart
class FetchThreadQuestionsUseCase {
  final ReflectionRepositoryType _repository;
  Future<List<QuestionModel>> execute() => _repository.fetchThreadQuestions();
}
```

✅ **Repository 模式**：隔离数据源
```dart
class ReflectionRepository implements ReflectionRepositoryType {
  final ApiClientType _apiClient;
  Future<List<QuestionModel>> fetchThreadQuestions() async {
    final response = await _apiClient.get('/api/thread-view');
    return (response['data'] as List).map((e) => QuestionModel.fromJson(e)).toList();
  }
}
```

✅ **接口抽象**：使用接口定义契约，便于测试
- `ApiClientType`
- `ReflectionRepositoryType`
- `FetchThreadQuestionsUseCaseType`

✅ **依赖注入**：使用 Riverpod 管理依赖

### 偏离标准的部分

⚠️ **Domain 层混入 Presentation 逻辑**
- `packages/domain` 包含 UI 页面和 Controller
- 依赖 Flutter 框架（`flutter_riverpod`、`lt_uicomponent`）
- 更准确的命名应该是 `packages/features`

⚠️ **缺少纯业务逻辑层**
- 没有独立的 Entity 层（纯业务实体）
- UseCase 在 Service 层而非 Domain 层
- DTO 直接被当作 Entity 使用

⚠️ **Service 层职责过重**
- 同时承担 Domain 层和 Data 层的职责
- 包含 UseCase（业务逻辑）+ Repository（数据访问）+ DTO（数据模型）

---

## 架构评价

### 优点

1. **清晰的模块化**：Monorepo 结构，功能模块独立
2. **依赖方向正确**：上层依赖下层，符合依赖倒置原则
3. **易于维护**：职责明确，代码组织清晰
4. **类型安全**：使用 Freezed 和 JSON Serializable
5. **现代化技术栈**：Riverpod + GoRouter + Dio
6. **接口抽象**：核心组件都有接口定义

### 可改进的地方

1. **命名准确性**：`packages/domain` 应改名为 `packages/features`
2. **分层更清晰**：可以将 UseCase 和 Repository 分离
3. **纯业务逻辑层**：考虑添加独立的 Entity 层
4. **测试覆盖**：建议添加单元测试和集成测试

### 适用场景

这个架构适合：
- ✅ 中大型 Flutter 应用
- ✅ 需要清晰分层和模块化的项目
- ✅ 团队协作开发
- ✅ 快速迭代的业务需求

**结论**：本项目采用的是 **实用主义的分层架构**，借鉴了 Clean Architecture 的核心思想（分层、依赖倒置、接口抽象），但做了适合 Flutter 开发的调整。虽然不是严格的 Clean Architecture，但对于实际项目来说是一个很好的平衡点。

---

## 开发指南

### 代码生成

```bash
# 生成所有代码
flutter pub run build_runner build --delete-conflicting-outputs

# 监听模式
flutter pub run build_runner watch --delete-conflicting-outputs
```

### 添加新功能模块

1. 在 `packages/domain/` 创建新的功能包
2. 添加 Page、Controller、State
3. 在 `packages/service/` 添加对应的 UseCase 和 Repository
4. 在 `apps/lt_app/lib/src/app_router.dart` 注册路由

### 依赖管理

参考 `docs/shared-dependencies.md` 了解标准依赖版本。

---

## 相关文档

- [项目架构详解](.kiro/specs/flutter-advanced-learning-plan/project-architecture.md)
- [路由架构解耦](.kiro/specs/flutter-advanced-learning-plan/lessons/router-architecture-decoupling.md)
- [共享依赖管理](docs/shared-dependencies.md)
