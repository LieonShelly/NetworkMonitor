import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ltapp_flutter/src/core/theme/app_style.dart';
import 'package:ltapp_flutter/src/features/calendar/calendar_controller.dart';

class CalendarMonthHeaderView extends ConsumerStatefulWidget {
  final Function(int pageIndex) onMonthSelected;

  const CalendarMonthHeaderView({super.key, required this.onMonthSelected});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _CalendarMonthHeaderView();
  }
}

class _CalendarMonthHeaderView extends ConsumerState<CalendarMonthHeaderView> {
  late ScrollController _scrollController;
  final double _itemWidth = 70;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentFocusedMonth(animate: false);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToIndex(int idnex, {bool animate = true}) {
    if (!_scrollController.hasClients) return;
    final screenWidth = MediaQuery.of(context).size.width;
    final targetOffset =
        (idnex * _itemWidth) - (screenWidth / 2) + (_itemWidth / 2);
    if (animate) {
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _scrollController.jumpTo(targetOffset);
    }
  }

  void _scrollToCurrentFocusedMonth({bool animate = true}) {
    final focusedMonth = ref.watch(calendarControllerProvider).focusedMonth;
    final now = DateTime.now();
    final monthDiff =
        (focusedMonth.year - now.year) * 12 + (focusedMonth.month - now.month);
    final targetIndex = monthDiff;
    _scrollToIndex(targetIndex, animate: animate);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      calendarControllerProvider.select((value) => value.focusedMonth),
      (previous, next) {
        if (previous?.month != next.month || previous?.year != next.year) {
          _scrollToCurrentFocusedMonth(animate: true);
        }
      },
    );
    final focusedMonth = ref.watch(
      calendarControllerProvider.select((value) => value.focusedMonth),
    );
    final monthList = ref.watch(
      calendarControllerProvider.select((value) => value.monthList),
    );
    return SizedBox(
      height: 42,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: monthList.length,
        itemBuilder: (context, index) {
          final itemDate = monthList[index].month;
          final isSelected =
              itemDate.year == focusedMonth.year &&
              itemDate.month == focusedMonth.month;
          switch (monthList[index].style) {
            case CalendarMonthItemStyle.normal:
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  widget.onMonthSelected(index);
                },
                child: _buildNormalMonthItem(itemDate, isSelected),
              );
            case CalendarMonthItemStyle.showYear:
              return _buildYearMonthItem(itemDate);
          }
        },
      ),
    );
  }

  Widget _buildNormalMonthItem(DateTime date, [bool isSelected = true]) {
    final text = Padding(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
      child: Text(
        DateFormat('MMM').format(date),
        textAlign: TextAlign.center,
        style: AppTextStyle.feltTipSeniorRegular(
          fontSize: 20,
          color: isSelected ? Color(0xffffffff) : Color(0xff000000),
        ),
      ),
    );
    final selectedDecoration = BoxDecoration(
      color: Color(0xff000000),
      borderRadius: BorderRadius.circular(12),
    );
    final unSelctedDecoration = BoxDecoration(
      border: Border.all(color: Color(0xff000000), width: 1),
      borderRadius: BorderRadius.circular(12),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Container(
        alignment: Alignment.center,
        decoration: isSelected ? selectedDecoration : unSelctedDecoration,
        child: text,
      ),
    );
  }

  Widget _buildYearMonthItem(DateTime date) {
    final year = date.year;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Text(
        '$year',
        style: AppTextStyle.feltTipSeniorRegular(
          fontSize: 20,
          color: Color(0xff000000),
        ),
      ),
    );
  }
}
