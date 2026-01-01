import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ltapp_flutter/src/core/date_utl.dart';
import 'package:ltapp_flutter/src/core/theme/app_style.dart';

class CalendarMonthView extends StatelessWidget {
  final DateTime month;
  final DateTime selectedDate;
  final Function(DateTime) onDateTap;

  const CalendarMonthView({
    super.key,
    required this.month,
    required this.selectedDate,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtl.getDaysInMonth(month.year, month.month);
    final firstDayOffset = DateUtl.getFirstDayOffset(month.year, month.month);
    const totalCells = 42;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildWeekDaysHeader(),
        const SizedBox(height: 10),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            childAspectRatio: 1.0,
          ),
          itemCount: totalCells,
          itemBuilder: (context, index) {
            if (index < firstDayOffset ||
                index >= firstDayOffset + daysInMonth) {
              return const SizedBox();
            }
            final day = index - firstDayOffset + 1;
            final currentDate = DateTime(month.year, month.month, day);
            final isSelected = DateUtl.isSmameDaty(currentDate, DateTime.now());
            final isToday = DateUtils.isSameDay(currentDate, DateTime.now());
            return _buildDayCell(
              day,
              isSelected,
              isToday,
              () => onDateTap(currentDate),
            );
          },
        ),
      ],
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

  Widget _buildDayCell(
    int day,
    bool isSelected,
    bool isToday,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.red,
        child: Center(
          child: Text(
            '$day',
            style: AppTextStyle.feltTipSeniorRegular(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
