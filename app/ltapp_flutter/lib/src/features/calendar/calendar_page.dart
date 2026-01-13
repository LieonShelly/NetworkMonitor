import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ltapp_flutter/src/core/date_utl.dart';
import 'package:ltapp_flutter/src/core/theme/app_style.dart';
import 'package:ltapp_flutter/src/core/theme/icon_name.dart';
import 'package:ltapp_flutter/src/core/ui_component/svg_asset.dart';
import 'package:ltapp_flutter/src/features/calendar/calendar_month_header_view.dart';
import 'package:ltapp_flutter/src/features/calendar/calendar_month_view.dart';
import 'package:ltapp_flutter/src/features/calendar/calendar_controller.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _CalendarPageState();
  }
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildWeekDaysHeader(),
              const SizedBox(height: 10),
              Expanded(child: _buildCustomTableCalendar()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final calendarState = ref.watch(calendarControllerProvider);
    final Widget column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 0,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              DateFormat('MMMM').format(calendarState.focusedMonth),
              style: AppTextStyle.feltTipSeniorRegular(
                fontSize: 36,
                color: Color(0xff000000),
              ),
            ),
            SvgAsset(IconName.downArrowFill, width: 24, height: 24),

            Spacer(),
            GestureDetector(
              child: Text(
                DateFormat('dd').format(DateTime.now()),
                style: AppTextStyle.feltTipSeniorRegular(
                  fontSize: 18,
                  color: Color(0xff000000),
                ),
              ),
              onTap: () {
                _pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ],
        ),

        Text(
          DateFormat('yyyy').format(calendarState.focusedMonth),
          style: TextStyle(
            fontSize: 24,
            color: Color(0xFF000000),
            fontFamily: 'FeltTipSeniorRegular',
          ),
        ),

        CalendarMonthHeaderView(
          onMonthSelected: (index) {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
      ],
    );
    return Container(
      // padding: EdgeInsets.symmetric(horizontal: 20),
      child: column,
    );
  }

  Widget _buildWeekDaysHeader() {
    const weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var day in weekDays)
          Expanded(
            child: Center(
              child: Text(
                day,
                style: AppTextStyle.feltTipSeniorRegular(
                  fontSize: 14,
                  color: Color(0xff000000),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCustomTableCalendar() {
    final focusedMonth = ref.watch(
      calendarControllerProvider.select((value) => value.focusedMonth),
    );
    return LayoutBuilder(
      builder: (context, constrains) {
        final width = constrains.maxWidth;
        final hp = 0;
        final itemWith = (width - hp * 6) / 7;
        final currentMonth = focusedMonth;
        final int rowCount = DateUtl.getRowCount(
          currentMonth.year,
          currentMonth.month,
        );
        final double cellH = 88.0;
        final gridH = cellH * rowCount;
        final spacingH = 20.0;
        final footerH = 55 * 3;
        final totalH = gridH + spacingH + footerH;
        final content = AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: totalH,
          child: _CalendarContentPageView(
            pageController: _pageController,
            itemWidth: itemWith,
            itemHeight: cellH,
          ),
        );
        final scrollContent = SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: content,
        );
        return RefreshIndicator(
          color: Colors.black,
          backgroundColor: Colors.white,
          onRefresh: () async {
            await ref
                .read(calendarControllerProvider.notifier)
                .refreshCurrentMonth();
          },
          child: scrollContent,
        );
      },
    );
  }
}

class _CalendarContentPageView extends ConsumerWidget {
  final PageController pageController;
  final double itemWidth;
  final double itemHeight;

  const _CalendarContentPageView({
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
        (state) =>
            state.monthList
              ..where((month) => month.style == CalendarMonthItemStyle.normal),
      ),
    );
    return PageView.builder(
      controller: pageController,
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
