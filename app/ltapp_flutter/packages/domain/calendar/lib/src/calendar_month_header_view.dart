import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lt_uicomponent/uicomponent.dart';
import 'calendar_controller.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class CalendarMonthHeaderView extends ConsumerStatefulWidget {
  final Function(int pageIndex) onMonthSelected;

  const CalendarMonthHeaderView({super.key, required this.onMonthSelected});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _CalendarMonthHeaderView();
  }
}

class _CalendarMonthHeaderView extends ConsumerState<CalendarMonthHeaderView> {
  late AutoScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, 0),
      axis: Axis.horizontal,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentFocusedMonth(animate: false);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollToIndex(int index, {bool animate = true}) async {
    if (animate) {
      await _scrollController.scrollToIndex(
        index,
        preferPosition: AutoScrollPosition.middle,
        duration: const Duration(milliseconds: 300),
      );
    } else {
      await _scrollController.scrollToIndex(
        index,
        preferPosition: AutoScrollPosition.middle,
      );
    }
  }

  void _scrollToCurrentFocusedMonth({bool animate = true}) {
    final focusedMonth = ref.read(calendarControllerProvider).focusedMonth;
    final monthList = ref.read(calendarControllerProvider).monthList;
    final index = monthList.indexWhere(
      (month) =>
          month.month.month == focusedMonth.month &&
          month.month.year == focusedMonth.year,
    );
    final targetIndex = index;
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
    final monthList = ref.read(calendarControllerProvider).monthList;
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
          Widget monthWidget;
          switch (monthList[index].style) {
            case CalendarMonthItemStyle.normal:
              monthWidget = GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  widget.onMonthSelected(index);
                },
                child: _buildNormalMonthItem(itemDate, isSelected),
              );
            case CalendarMonthItemStyle.showYear:
              monthWidget = _buildYearMonthItem(itemDate);
          }
          return AutoScrollTag(
            key: ValueKey(index),
            controller: _scrollController,
            index: index,
            child: monthWidget,
          );
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
