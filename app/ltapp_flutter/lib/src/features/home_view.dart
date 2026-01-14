import 'package:flutter/material.dart';
import 'package:ltapp_flutter/src/core/ui_component/app_tabbar.dart';
import 'package:ltapp_flutter/src/features/today_question/today_question_banner_view.dart';

class HomeView extends StatelessWidget {
  final Widget child;

  const HomeView({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    const tabarH = 70.0;
    const tabbarTop = 20.0;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(child: child),
            Positioned(
              left: 0,
              right: 0,
              bottom: tabarH + tabbarTop,
              child: TodayQuestionBannerView(),
            ),
            Positioned(left: 0, right: 0, bottom: 0, child: AppTabbar()),
          ],
        ),
      ),
    );
  }
}
