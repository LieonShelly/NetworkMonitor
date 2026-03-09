import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:feature_core/feature_core.dart';
import 'package:lt_uicomponent/uicomponent.dart';
import 'today_question_banner_controller.dart';

class TodayQuestionBannerView extends ConsumerStatefulWidget {
  const TodayQuestionBannerView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _TodayQuestionBannerViewState();
  }
}

class _TodayQuestionBannerViewState
    extends ConsumerState<TodayQuestionBannerView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant TodayQuestionBannerView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todayQuestions = ref.watch(
      todayQuestionBannerControllerProvider.select(
        (state) => state.todayQuestions.value,
      ),
    );
    final latestQueistion = todayQuestions?.last;
    if (latestQueistion == null) {
      return SizedBox();
    }
    final cross = SvgAsset(IconName.smallCross, width: 20, height: 20);
    final gradient = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF040404), Color(0xFF656565)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final gradientContainer = Stack(
      alignment: Alignment.center,
      children: [
        gradient,
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 2.0),
            child: Container(color: Colors.transparent),
          ),
        ),
        cross,
      ],
    );

    final animatedContent = ScaleTransition(
      scale: _scaleAnimation,
      child: gradientContainer,
    );
    final btn = GestureDetector(
      onTap: () {
        final questions = ref
            .read(todayQuestionBannerControllerProvider)
            .todayQuestions
            .value;
        if (questions != null) {
          context.push(AppRoutePath.addAnswer, extra: questions);
        }
      },
      child: SizedBox(
        width: 50,
        height: 50,
        child: Center(child: animatedContent),
      ),
    );

    final container = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Color(0xffFFFEFD),
        boxShadow: [
          BoxShadow(color: Color(0xffcccccc).withOpacity(0.25), blurRadius: 20),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text(
              "Question of the day",
              style: AppTextStyle.poppins(
                fontSize: 12,
                color: Color(0xff6f6f6f),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text2
                Expanded(
                  child: Text(
                    latestQueistion?.title ?? "",
                    textAlign: TextAlign.left,
                    style: AppTextStyle.vividlyRegular(
                      fontSize: 24,
                      color: Color(0xff000000),
                      height: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                btn,
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: container,
    );
  }
}
