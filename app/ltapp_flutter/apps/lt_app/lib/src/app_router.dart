import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:add_answer/add_answer.dart';
import 'package:answer_detail/answer_detail.dart';
import 'package:calendar/calendar.dart';
import 'package:copilot/copilot.dart';
import 'home_view.dart';
import 'package:thread/thread.dart';
import 'package:user/user.dart';
import 'package:lt_reflection_service/reflection_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:feature_core/feature_core.dart';
part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutePath.thread,
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
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ThreadPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePath.insights,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ChatPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePath.user,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: UserHomePage()),
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
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutePath.chat,
        pageBuilder: (context, state) {
          final page = ChatPage(key: state.pageKey);
          return MaterialPage(key: state.pageKey, child: page);
        },
      ),
    ],
  );
}
