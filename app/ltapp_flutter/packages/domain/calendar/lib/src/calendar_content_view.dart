import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lt_uicomponent/uicomponent.dart';
import 'calendar_controller.dart';
import 'calendar_month_view.dart';

class CalendarContentView extends ConsumerWidget {
  final PageController pageController;
  final double itemWidth;
  final double itemHeight;

  const CalendarContentView({
    super.key,
    required this.pageController,
    required this.itemWidth,
    required this.itemHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aspectRatio = itemWidth / itemHeight;
    final spacingH = 20.0;
    final reflectionMap = ref.watch(
      calendarControllerProvider.select((state) => state.reflectionMap.value),
    );
    final monthList = ref.watch(
      calendarControllerProvider.select(
        (state) => state.monthList
            .where((month) => month.style == CalendarMonthItemStyle.normal)
            .toList(),
      ),
    );
    return PageView.builder(
      controller: pageController,
      itemCount: monthList.length,
      onPageChanged: (index) {
        final newMonth = monthList[index].month;
        ref.read(calendarControllerProvider.notifier).onPageChanged(newMonth);
      },
      itemBuilder: (context, index) {
        if (index >= monthList.length) {
          return null;
        }
        final monthDate = monthList[index].month;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CalendarMonthView(
              month: monthDate,
              childAspectRatio: aspectRatio,
              cellHeight: itemHeight,
              dataMap: reflectionMap,
              onDateTap: (date) {},
            ),
            SizedBox(height: spacingH),
            _buildFooterStats(),
          ],
        );
      },
    );
  }

  Widget _buildFooterStats() {
    return Column(
      children: [
        Text(
          '9 icons created this month',
          style: AppTextStyle.feltTipSeniorRegular(
            color: Color(0xff000000),
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '20 more days to go!',
          style: AppTextStyle.feltTipSeniorRegular(
            color: Color(0xff000000),
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
