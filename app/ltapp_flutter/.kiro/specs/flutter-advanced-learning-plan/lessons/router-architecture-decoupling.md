# Flutter 大型应用路由解耦架构设计

## 🎯 问题分析

### 当前问题
```dart
// ❌ 所有路由集中在一个文件中
GoRouter(
  routes: [
    // 用户模块路由
    GoRoute(path: '/user', ...),
    GoRoute(path: '/user/profile', ...),
    
    // 商城模块路由
    GoRoute(path: '/shop', ...),
    GoRoute(path: '/shop/cart', ...),
    
    // 社交模块路由
    GoRoute(path: '/social', ...),
    GoRoute(path: '/social/chat', ...),
    
    // ... 100+ 个路由
  ],
)
```

**问题：**
1. ❌ 所有模块的路由耦合在一起
2. ❌ 修改一个模块的路由会影响整个文件
3. ❌ 团队协作时容易产生冲突
4. ❌ 无法独立开发和测试模块
5. ❌ 代码难以维护和扩展

---

## ✅ 解决方案

### 方案1：模块化路由配置（推荐）

#### 架构设计

```
lib/
├── main.dart
├── src/
│   ├── app_router.dart              # 主路由配置
│   ├── core/
│   │   └── router/
│   │       ├── route_config.dart    # 路由配置基类
│   │       └── router_registry.dart # 路由注册中心
│   └── features/
│       ├── user/
│       │   ├── user_routes.dart     # 用户模块路由
│       │   └── pages/
│       ├── shop/
│       │   ├── shop_routes.dart     # 商城模块路由
│       │   └── pages/
│       └── social/
│           ├── social_routes.dart   # 社交模块路由
│           └── pages/
```

#### 1. 创建路由配置基类

```dart
// lib/src/core/router/route_config.dart

import 'package:go_router/go_router.dart';

/// 路由配置接口
abstract class RouteConfig {
  /// 模块名称
  String get moduleName;
  
  /// 路由列表
  List<RouteBase> get routes;
  
  /// 初始化路由（可选）
  void initialize() {}
}

/// 路由路径常量基类
abstract class RoutePathConstants {
  const RoutePathConstants();
}
```

#### 2. 创建路由注册中心

```dart
// lib/src/core/router/router_registry.dart

import 'package:go_router/go_router.dart';
import 'route_config.dart';

/// 路由注册中心
class RouterRegistry {
  static final RouterRegistry _instance = RouterRegistry._internal();
  factory RouterRegistry() => _instance;
  RouterRegistry._internal();
  
  final List<RouteConfig> _configs = [];
  
  /// 注册路由配置
  void register(RouteConfig config) {
    _configs.add(config);
    config.initialize();
    print('✅ 注册路由模块: ${config.moduleName}');
  }
  
  /// 批量注册
  void registerAll(List<RouteConfig> configs) {
    for (final config in configs) {
      register(config);
    }
  }
  
  /// 获取所有路由
  List<RouteBase> getAllRoutes() {
    final routes = <RouteBase>[];
    for (final config in _configs) {
      routes.addAll(config.routes);
    }
    return routes;
  }
  
  /// 清空注册（用于测试）
  void clear() {
    _configs.clear();
  }
}
```

#### 3. 各模块定义自己的路由

```dart
// lib/src/features/user/user_routes.dart

import 'package:go_router/go_router.dart';
import '../../core/router/route_config.dart';
import 'pages/user_home.dart';
import 'pages/user_profile.dart';
import 'pages/user_settings.dart';

/// 用户模块路由路径
class UserRoutePaths extends RoutePathConstants {
  static const String home = '/user';
  static const String profile = '/user/profile';
  static const String settings = '/user/settings';
}

/// 用户模块路由配置
class UserRouteConfig implements RouteConfig {
  @override
  String get moduleName => 'User';
  
  @override
  void initialize() {
    // 模块初始化逻辑（如果需要）
    print('初始化用户模块路由');
  }
  
  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: UserRoutePaths.home,
      builder: (context, state) => const UserHomePage(),
      routes: [
        GoRoute(
          path: 'profile',  // 相对路径
          builder: (context, state) => const UserProfilePage(),
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const UserSettingsPage(),
        ),
      ],
    ),
  ];
}
```

```dart
// lib/src/features/shop/shop_routes.dart

import 'package:go_router/go_router.dart';
import '../../core/router/route_config.dart';
import 'pages/shop_home.dart';
import 'pages/product_detail.dart';
import 'pages/cart_page.dart';

/// 商城模块路由路径
class ShopRoutePaths extends RoutePathConstants {
  static const String home = '/shop';
  static const String productDetail = '/shop/product/:id';
  static const String cart = '/shop/cart';
}

/// 商城模块路由配置
class ShopRouteConfig implements RouteConfig {
  @override
  String get moduleName => 'Shop';
  
  @override
  void initialize() {
    print('初始化商城模块路由');
  }
  
  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: ShopRoutePaths.home,
      builder: (context, state) => const ShopHomePage(),
      routes: [
        GoRoute(
          path: 'product/:id',
          builder: (context, state) {
            final productId = state.pathParameters['id']!;
            return ProductDetailPage(productId: productId);
          },
        ),
        GoRoute(
          path: 'cart',
          builder: (context, state) => const CartPage(),
        ),
      ],
    ),
  ];
}
```

```dart
// lib/src/features/social/social_routes.dart

import 'package:go_router/go_router.dart';
import '../../core/router/route_config.dart';
import 'pages/social_home.dart';
import 'pages/chat_page.dart';
import 'pages/friends_page.dart';

/// 社交模块路由路径
class SocialRoutePaths extends RoutePathConstants {
  static const String home = '/social';
  static const String chat = '/social/chat/:userId';
  static const String friends = '/social/friends';
}

/// 社交模块路由配置
class SocialRouteConfig implements RouteConfig {
  @override
  String get moduleName => 'Social';
  
  @override
  void initialize() {
    print('初始化社交模块路由');
  }
  
  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: SocialRoutePaths.home,
      builder: (context, state) => const SocialHomePage(),
      routes: [
        GoRoute(
          path: 'chat/:userId',
          builder: (context, state) {
            final userId = state.pathParameters['userId']!;
            return ChatPage(userId: userId);
          },
        ),
        GoRoute(
          path: 'friends',
          builder: (context, state) => const FriendsPage(),
        ),
      ],
    ),
  ];
}
```

#### 4. 主路由配置

```dart
// lib/src/app_router.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/router/router_registry.dart';
import 'features/user/user_routes.dart';
import 'features/shop/shop_routes.dart';
import 'features/social/social_routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter router(Ref ref) {
  // 创建路由注册中心
  final registry = RouterRegistry();
  
  // 注册所有模块路由
  registry.registerAll([
    UserRouteConfig(),
    ShopRouteConfig(),
    SocialRouteConfig(),
    // 添加更多模块...
  ]);
  
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: UserRoutePaths.home,
    routes: [
      // 主Shell路由（如果有底部导航栏）
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeView(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: registry.getAllRoutes(),
          ),
        ],
      ),
    ],
  );
}
```

---

### 方案2：使用Package分离模块（更彻底的解耦）

#### 项目结构

```
my_super_app/
├── packages/
│   ├── user_module/
│   │   ├── lib/
│   │   │   ├── user_module.dart
│   │   │   ├── src/
│   │   │   │   ├── routes.dart
│   │   │   │   └── pages/
│   │   └── pubspec.yaml
│   ├── shop_module/
│   │   ├── lib/
│   │   │   ├── shop_module.dart
│   │   │   ├── src/
│   │   │   │   ├── routes.dart
│   │   │   │   └── pages/
│   │   └── pubspec.yaml
│   └── social_module/
│       ├── lib/
│       │   ├── social_module.dart
│       │   ├── src/
│       │   │   ├── routes.dart
│       │   │   └── pages/
│       └── pubspec.yaml
└── lib/
    ├── main.dart
    └── app_router.dart
```

#### 1. 创建独立的Package

```yaml
# packages/user_module/pubspec.yaml
name: user_module
description: User module for the super app
version: 1.0.0

dependencies:
  flutter:
    sdk: flutter
  go_router: ^14.0.0
  
  # 共享的core包
  app_core:
    path: ../app_core
```

```dart
// packages/user_module/lib/user_module.dart

library user_module;

export 'src/routes.dart';
export 'src/pages/user_home.dart';
export 'src/pages/user_profile.dart';
```

```dart
// packages/user_module/lib/src/routes.dart

import 'package:go_router/go_router.dart';
import 'package:app_core/app_core.dart';
import 'pages/user_home.dart';
import 'pages/user_profile.dart';

class UserModuleRoutes implements ModuleRoutes {
  @override
  String get moduleName => 'User';
  
  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: '/user',
      builder: (context, state) => const UserHomePage(),
      routes: [
        GoRoute(
          path: 'profile',
          builder: (context, state) => const UserProfilePage(),
        ),
      ],
    ),
  ];
}
```

#### 2. 主应用引用Package

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  go_router: ^14.0.0
  
  # 引用各个模块
  user_module:
    path: packages/user_module
  shop_module:
    path: packages/shop_module
  social_module:
    path: packages/social_module
```

```dart
// lib/app_router.dart

import 'package:user_module/user_module.dart';
import 'package:shop_module/shop_module.dart';
import 'package:social_module/social_module.dart';

@riverpod
GoRouter router(Ref ref) {
  final registry = RouterRegistry();
  
  // 注册各个模块的路由
  registry.registerAll([
    UserModuleRoutes(),
    ShopModuleRoutes(),
    SocialModuleRoutes(),
  ]);
  
  return GoRouter(
    routes: registry.getAllRoutes(),
  );
}
```

---

### 方案3：动态路由注册（插件化架构）

适用于需要动态加载模块的场景。

```dart
// lib/src/core/router/dynamic_router_manager.dart

import 'package:go_router/go_router.dart';
import 'route_config.dart';

class DynamicRouterManager {
  static final DynamicRouterManager _instance = DynamicRouterManager._internal();
  factory DynamicRouterManager() => _instance;
  DynamicRouterManager._internal();
  
  final Map<String, RouteConfig> _modules = {};
  GoRouter? _router;
  
  /// 注册模块
  void registerModule(RouteConfig config) {
    _modules[config.moduleName] = config;
    config.initialize();
    
    // 如果路由已创建，需要重新构建
    if (_router != null) {
      _rebuildRouter();
    }
  }
  
  /// 卸载模块
  void unregisterModule(String moduleName) {
    _modules.remove(moduleName);
    if (_router != null) {
      _rebuildRouter();
    }
  }
  
  /// 获取路由器
  GoRouter getRouter() {
    if (_router == null) {
      _router = _buildRouter();
    }
    return _router!;
  }
  
  /// 构建路由器
  GoRouter _buildRouter() {
    final routes = <RouteBase>[];
    for (final config in _modules.values) {
      routes.addAll(config.routes);
    }
    
    return GoRouter(
      routes: routes,
      initialLocation: '/',
    );
  }
  
  /// 重新构建路由器
  void _rebuildRouter() {
    _router = _buildRouter();
    // 通知应用重新构建
  }
}
```

---

## 🎨 实战案例：重构你的项目

### 步骤1：创建路由基础设施

```dart
// lib/src/core/router/route_config.dart
abstract class RouteConfig {
  String get moduleName;
  List<RouteBase> get routes;
  void initialize() {}
}

// lib/src/core/router/router_registry.dart
class RouterRegistry {
  static final RouterRegistry _instance = RouterRegistry._internal();
  factory RouterRegistry() => _instance;
  RouterRegistry._internal();
  
  final List<RouteConfig> _configs = [];
  
  void register(RouteConfig config) {
    _configs.add(config);
    config.initialize();
  }
  
  void registerAll(List<RouteConfig> configs) {
    configs.forEach(register);
  }
  
  List<RouteBase> getAllRoutes() {
    return _configs.expand((config) => config.routes).toList();
  }
}
```

### 步骤2：重构现有路由

```dart
// lib/src/features/thread/thread_routes.dart
class ThreadRoutePaths {
  static const String home = '/thread';
}

class ThreadRouteConfig implements RouteConfig {
  @override
  String get moduleName => 'Thread';
  
  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: ThreadRoutePaths.home,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: ThreadPage()),
    ),
  ];
}

// lib/src/features/calendar/calendar_routes.dart
class CalendarRoutePaths {
  static const String home = '/calendar';
}

class CalendarRouteConfig implements RouteConfig {
  @override
  String get moduleName => 'Calendar';
  
  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: CalendarRoutePaths.home,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: CalendarPage()),
    ),
  ];
}

// lib/src/features/user/user_routes.dart
class UserRoutePaths {
  static const String home = '/user';
  static const String chat = '/chat';
}

class UserRouteConfig implements RouteConfig {
  final GlobalKey<NavigatorState> rootNavigatorKey;
  
  UserRouteConfig({required this.rootNavigatorKey});
  
  @override
  String get moduleName => 'User';
  
  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: UserRoutePaths.home,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: UserHomePage()),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: UserRoutePaths.chat,
      pageBuilder: (context, state) =>
          MaterialPage(child: ChatPage(key: state.pageKey)),
    ),
  ];
}
```

### 步骤3：更新主路由配置

```dart
// lib/src/app_router.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/router/router_registry.dart';
import 'features/thread/thread_routes.dart';
import 'features/calendar/calendar_routes.dart';
import 'features/user/user_routes.dart';
import 'features/copilot/copilot_routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter router(Ref ref) {
  // 创建路由注册中心
  final registry = RouterRegistry();
  
  // 注册所有模块路由
  registry.registerAll([
    ThreadRouteConfig(),
    CalendarRouteConfig(),
    UserRouteConfig(rootNavigatorKey: _rootNavigatorKey),
    CopilotRouteConfig(),
  ]);
  
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: ThreadRoutePaths.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeView(navigationShell: navigationShell);
        },
        branches: [
          // 从注册中心获取路由
          ...registry.getAllRoutes().map((route) {
            return StatefulShellBranch(routes: [route]);
          }),
        ],
      ),
    ],
  );
}
```

---

## 📊 方案对比

| 特性 | 方案1：模块化配置 | 方案2：Package分离 | 方案3：动态注册 |
|------|------------------|-------------------|----------------|
| **解耦程度** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **实现复杂度** | 简单 | 中等 | 复杂 |
| **独立开发** | 支持 | 完全支持 | 支持 |
| **独立测试** | 支持 | 完全支持 | 支持 |
| **代码复用** | 一般 | 优秀 | 优秀 |
| **动态加载** | 不支持 | 不支持 | 支持 |
| **适用场景** | 中大型应用 | 超大型应用 | 插件化应用 |

---

## 🎯 最佳实践

### 1. 路由命名规范

```dart
// ✅ 推荐：使用模块前缀
class UserRoutePaths {
  static const String home = '/user';
  static const String profile = '/user/profile';
  static const String settings = '/user/settings';
}

class ShopRoutePaths {
  static const String home = '/shop';
  static const String cart = '/shop/cart';
}

// ❌ 不推荐：没有模块前缀
class RoutePaths {
  static const String home = '/home';  // 哪个模块的home？
  static const String profile = '/profile';  // 容易冲突
}
```

### 2. 路由参数传递

```dart
// ✅ 推荐：使用类型安全的参数
class ProductDetailRoute {
  static String path(String productId) => '/shop/product/$productId';
  
  static GoRoute route() {
    return GoRoute(
      path: '/shop/product/:id',
      builder: (context, state) {
        final productId = state.pathParameters['id']!;
        return ProductDetailPage(productId: productId);
      },
    );
  }
}

// 使用
context.go(ProductDetailRoute.path('123'));
```

### 3. 模块间导航

```dart
// lib/src/core/router/navigation_service.dart
class NavigationService {
  static void navigateToUserProfile(BuildContext context, String userId) {
    context.go('/user/profile/$userId');
  }
  
  static void navigateToProductDetail(BuildContext context, String productId) {
    context.go('/shop/product/$productId');
  }
  
  static void navigateToChat(BuildContext context, String chatId) {
    context.go('/social/chat/$chatId');
  }
}

// 使用
NavigationService.navigateToUserProfile(context, '123');
```

### 4. 路由守卫

```dart
// lib/src/core/router/route_guard.dart
class RouteGuard {
  static String? checkAuth(BuildContext context, GoRouterState state) {
    final isLoggedIn = /* 检查登录状态 */;
    
    if (!isLoggedIn) {
      return '/login';  // 重定向到登录页
    }
    
    return null;  // 允许访问
  }
}

// 在路由中使用
GoRoute(
  path: '/user/profile',
  redirect: RouteGuard.checkAuth,
  builder: (context, state) => const UserProfilePage(),
)
```

---

## 🐛 常见问题

### 问题1：模块间如何通信？

**解决方案：使用事件总线或依赖注入**

```dart
// lib/src/core/events/event_bus.dart
class AppEventBus {
  static final EventBus _instance = EventBus();
  static EventBus get instance => _instance;
}

// 模块A发送事件
AppEventBus.instance.fire(UserLoggedInEvent(userId: '123'));

// 模块B监听事件
AppEventBus.instance.on<UserLoggedInEvent>().listen((event) {
  // 处理事件
});
```

### 问题2：如何处理深层嵌套路由？

**解决方案：使用子路由**

```dart
GoRoute(
  path: '/user',
  builder: (context, state) => const UserHomePage(),
  routes: [
    GoRoute(
      path: 'profile',  // 实际路径：/user/profile
      builder: (context, state) => const UserProfilePage(),
      routes: [
        GoRoute(
          path: 'edit',  // 实际路径：/user/profile/edit
          builder: (context, state) => const EditProfilePage(),
        ),
      ],
    ),
  ],
)
```

### 问题3：如何实现路由懒加载？

**解决方案：使用Future builder**

```dart
GoRoute(
  path: '/heavy-page',
  pageBuilder: (context, state) {
    return FutureBuilder(
      future: _loadHeavyModule(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MaterialPage(child: snapshot.data!);
        }
        return MaterialPage(child: LoadingPage());
      },
    );
  },
)
```

---

## 📚 相关资源

- [GoRouter官方文档](https://pub.dev/packages/go_router)
- [Flutter模块化架构](https://flutter.dev/docs/development/packages-and-plugins/developing-packages)
- [大型Flutter应用架构](https://docs.flutter.dev/development/data-and-backend/state-mgmt/options)

---

## ✅ 总结

### 推荐方案选择

1. **中型应用（<50个页面）**：使用方案1（模块化配置）
2. **大型应用（50-200个页面）**：使用方案1或方案2
3. **超大型应用（>200个页面）**：使用方案2（Package分离）
4. **需要插件化**：使用方案3（动态注册）

### 关键要点

1. ✅ 每个模块管理自己的路由
2. ✅ 使用路由注册中心统一管理
3. ✅ 路由路径使用常量定义
4. ✅ 模块间通过事件或服务通信
5. ✅ 保持路由配置的简洁和可维护性

这是资深Flutter工程师必须掌握的架构设计能力！
