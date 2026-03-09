import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:feature_core/feature_core.dart';
import 'package:today_question/today_question.dart';

class HomeView extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const HomeView({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    const tabarH = 70.0;
    const tabbarTop = 20.0;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(child: navigationShell),
            Positioned(
              left: 0,
              right: 0,
              bottom: tabarH + tabbarTop,
              child: TodayQuestionBannerView(),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AppTabbar(navigationShell: navigationShell),
            ),
          ],
        ),
      ),
    );
  }
}
