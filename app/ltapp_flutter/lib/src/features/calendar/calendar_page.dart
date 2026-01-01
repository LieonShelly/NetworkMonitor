import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ltapp_flutter/src/core/theme/app_style.dart';
import 'package:ltapp_flutter/src/core/theme/icon_name.dart';
import 'package:ltapp_flutter/src/core/ui_component/svg_asset.dart';
import 'package:ltapp_flutter/src/features/calendar/calendar_month_view.dart';
import 'package:ltapp_flutter/src/features/calendar/calendar_state_provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _CalendarPageState();
  }
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _seletecDay;
  static const int _initPage = 10000;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initPage);
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
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildCustomTableCalendar(),
              const SizedBox(height: 20),
              _buildFooterStats(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final Widget column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 0,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              DateFormat('MMMM').format(_focusedDay),
              style: AppTextStyle.feltTipSeniorRegular(
                fontSize: 36,
                color: Color(0xff000000),
              ),
            ),
            SvgAsset(IconName.downArrowFill, width: 24, height: 24),

            Spacer(),
            Text(
              DateFormat('dd').format(_focusedDay),
              style: AppTextStyle.feltTipSeniorRegular(
                fontSize: 18,
                color: Color(0xff000000),
              ),
            ),
          ],
        ),

        Text(
          DateFormat('yyyy').format(_focusedDay),
          style: TextStyle(
            fontSize: 24,
            color: Color(0xFF000000),
            fontFamily: 'FeltTipSeniorRegular',
          ),
        ),
      ],
    );
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: column,
    );
  }

  Widget _buildCustomTableCalendar() {
    final calendarState = ref.watch(calendarStateProviderProvider);
    return LayoutBuilder(
      builder: (context, constrains) {
        final width = constrains.maxWidth;
        final hp = 0;
        final itemWith = (width - hp * 6) / 7;
        final gridH = itemWith * 6 + (hp * 5);
        final totalH = gridH + 20 + 10 + 20;
        return SizedBox(
          height: totalH,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              final monthDifference = index - _initPage;
              final now = DateTime.now();
              final newMonth = DateTime(now.year, now.month + monthDifference);
              ref
                  .read(calendarStateProviderProvider.notifier)
                  .onPageChanged(newMonth);
            },
            itemBuilder: (context, index) {
              final monthDifference = index - _initPage;
              final now = DateTime.now();
              final monthDate = DateTime(now.year, now.month + monthDifference);
              return CalendarMonthView(
                month: monthDate,
                selectedDate: calendarState.selectedDate,
                onDateTap: (date) {
                  ref
                      .read(calendarStateProviderProvider.notifier)
                      .setdDate(date);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFooterStats() {
    return Column(
      children: [
        Text(
          '9 icons created this month',
          style: AppTextStyle.poppins(color: Color(0xff000000), fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          '20 more days to go!',
          style: AppTextStyle.poppins(color: Color(0xff000000), fontSize: 16),
        ),
      ],
    );
  }
}
