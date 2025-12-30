import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ltapp_flutter/src/features/home_view.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 假设你已经创建了这些页面的简单占位符
// import 'features/calendar/presentation/calendar_page.dart';
// import 'features/thread/presentation/thread_page.dart';
// ...

part 'app_router.g.dart';

// 私有 key 用于获取 context
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/calendar', // 默认进入日历页
    routes: [
      // ShellRoute: 保持底部导航栏在页面切换时不消失
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return HomeView(child: child);
        },
        routes: [
          GoRoute(
            path: '/calendar',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: Scaffold(
                body: Center(child: Text("Calendar Page")),
              ), // 临时占位
            ),
          ),
          GoRoute(
            path: '/thread',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: Scaffold(body: Center(child: Text("Thread Page"))), // 临时占位
            ),
          ),
          GoRoute(
            path: '/insights',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: Scaffold(
                body: Center(child: Text("Insights Page")),
              ), // 临时占位
            ),
          ),
          GoRoute(
            path: '/user',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: Scaffold(body: Center(child: Text("User Page"))), // 临时占位
            ),
          ),
        ],
      ),
    ],
  );
}
