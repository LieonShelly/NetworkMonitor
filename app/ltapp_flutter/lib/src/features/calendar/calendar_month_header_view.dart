import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ltapp_flutter/src/core/theme/app_style.dart';
import 'package:ltapp_flutter/src/features/calendar/calendar_controller.dart';

class CalendarMonthHeaderView extends ConsumerStatefulWidget {
  final int initPage;
  final Function(int pageIndex) onMonthSelected;

  const CalendarMonthHeaderView({
    super.key,
    required this.initPage,
    required this.onMonthSelected,
  });

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
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focusedMonth = ref.watch(
      calendarControllerProvider.select((value) => value.focusedMonth),
    );
    return SizedBox(
      height: 42,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: 20000,
        itemBuilder: (context, index) {
          final monthDifference = index - widget.initPage;
          final now = DateTime.now();
          final itemDate = DateTime(now.year, now.month + monthDifference);
          final isSelected =
              itemDate.year == focusedMonth.year &&
              itemDate.month == focusedMonth.month;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: _buildMonthItem(itemDate, isSelected),
          );
        },
      ),
    );
  }

  Widget _buildMonthItem(DateTime date, [bool isSelected = true]) {
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
      border: BoxBorder.all(color: Color(0xff000000), width: 1),
      borderRadius: BorderRadius.circular(12),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Container(
        alignment: Alignment.center,
        decoration: isSelected ? selectedDecoration : unSelctedDecoration,
        child: text,
      ),
    );
  }
}
