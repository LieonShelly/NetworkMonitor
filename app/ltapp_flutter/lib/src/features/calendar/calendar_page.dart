import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ltapp_flutter/src/core/date_utl.dart';
import 'package:ltapp_flutter/src/core/theme/app_style.dart';
import 'package:ltapp_flutter/src/core/theme/icon_name.dart';
import 'package:ltapp_flutter/src/core/ui_component/svg_asset.dart';
import 'package:ltapp_flutter/src/features/calendar/calendar_content_view.dart';
import 'package:ltapp_flutter/src/features/calendar/calendar_month_header_view.dart';
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
    final controller = ref.read(calendarControllerProvider.notifier);
    final state = ref.read(calendarControllerProvider);
    final normalMonths = controller.normalMonths;
    int initialIndex = normalMonths.indexWhere(
      (e) =>
          e.month.year == state.focusedMonth.year &&
          e.month.month == state.focusedMonth.month,
    );
    if (initialIndex == -1) initialIndex = 0;
    _pageController = PageController(initialPage: initialIndex);
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
    final calendarController = ref.watch(calendarControllerProvider.notifier);
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
                final now = DateTime.now();
                final normalMonths = calendarController.normalMonths;
                int index = normalMonths.indexWhere(
                  (e) => e.month.year == now.year && e.month.month == now.month,
                );
                if (index != -1) {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
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
            final fullList = ref.read(calendarControllerProvider).monthList;
            final selectedItem = fullList[index];
            if (selectedItem.style == CalendarMonthItemStyle.normal) {
              final normalMonths = calendarController.normalMonths;
              final bodyIndex = normalMonths.indexWhere(
                (e) => e == selectedItem,
              );
              if (bodyIndex != -1) {
                _pageController.animateToPage(
                  bodyIndex,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            }
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
          child: CalendarContentView(
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
