import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ltapp_flutter/src/features/answer_detail/answer_detail_page.dart';
import 'package:ltapp_flutter/src/features/calendar/calendar_page.dart';
import 'package:ltapp_flutter/src/features/home_view.dart';
import 'package:ltapp_flutter/src/service/dto/calendar_reflection_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

// 私有 key 用于获取 context
final _rootNavigatorKey = GlobalKey<NavigatorState>();
@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/calendar',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeView(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CalendarPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/thread',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: Scaffold(body: Center(child: Text("Thread page"))),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/insights',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: Scaffold(body: Center(child: Text("insights page"))),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/user',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: Scaffold(body: Center(child: Text("user page"))),
                ),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/answer_detail',
        pageBuilder: (context, state) {
          final answer = state.extra as AnswerModel;
          return CustomTransitionPage(
            key: state.pageKey,
            child: AnswerDetailPage(answer: answer),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, 1),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          ),
                        ),
                    child: child,
                  );
                },
          );
        },
      ),
    ],
  );
}
