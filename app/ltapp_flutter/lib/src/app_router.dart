import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ltapp_flutter/src/features/add_answer/add_answer_page.dart';
import 'package:ltapp_flutter/src/features/answer_detail/answer_detail_page.dart';
import 'package:ltapp_flutter/src/features/calendar/calendar_page.dart';
import 'package:ltapp_flutter/src/features/home_view.dart';
import 'package:ltapp_flutter/src/service/dto/calendar_reflection_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

class AppRoutePath {
  static const calendar = "/calendar";
  static const thread = "/thread";
  static const insights = "/insights";
  static const user = "/user";
  static const answerDetail = "/answer_detail";
  static const addAnswer = "/add_answer";
}

// 私有 key 用于获取 context
final _rootNavigatorKey = GlobalKey<NavigatorState>();
@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutePath.calendar,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeView(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePath.calendar,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CalendarPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePath.thread,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: Scaffold(body: Center(child: Text("Thread page"))),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePath.insights,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: Scaffold(body: Center(child: Text("insights page"))),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePath.user,
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
        path: AppRoutePath.answerDetail,
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

      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutePath.addAnswer,
        pageBuilder: (context, state) {
          final questions = state.extra as List<QuestionModel>;
          final page = AddAnswerPage(key: state.pageKey, questions: questions);
          return MaterialPage(key: state.pageKey, child: page);
        },
      ),
    ],
  );
}
