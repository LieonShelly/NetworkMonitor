import 'package:flutter/material.dart';
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
        CustomPaint(
          painter: DashedGridPainter(
            color: Colors.black.withOpacity(0.1),
            dashWidth: 3,
            dashSpace: 3,
          ),
          child: GridView.builder(
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
              final isSelected = DateUtl.isSameDaty(
                currentDate,
                DateTime.now(),
              );
              final isToday = DateUtils.isSameDay(currentDate, DateTime.now());
              return _buildDayCell(
                day,
                isSelected,
                isToday,
                () => onDateTap(currentDate),
              );
            },
          ),
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

class DashedGridPainter extends CustomPainter {
  final Color color;
  final double strokedWith;
  final double dashWidth;
  final double dashSpace;

  DashedGridPainter({
    this.color = const Color(0xffe0e0e0),
    this.strokedWith = 1.0,
    this.dashWidth = 4.0,
    this.dashSpace = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokedWith
      ..style = PaintingStyle.stroke;

    final cellWidth = size.width / 7;
    final cellHeight = size.height / 6;

    for (int i = 1; i < 7; i++) {
      final x = i * cellWidth;
      _drawDashedline(canvas, paint, Offset(x, 0), Offset(x, size.height));
    }

    for (int i = 1; i < 6; i++) {
      final y = i * cellHeight;
      _drawDashedline(canvas, paint, Offset(0, y), Offset(size.width, y));
    }
  }

  void _drawDashedline(Canvas canvas, Paint paint, Offset start, Offset end) {
    final bool isVertical = start.dx == end.dx;
    double currentPos = 0;
    final double totalLength = isVertical
        ? (end.dy - start.dy)
        : (end.dx - start.dx);

    while (currentPos < totalLength) {
      final double nextPos = currentPos + dashWidth;
      if (isVertical) {
        canvas.drawLine(
          Offset(start.dx, start.dy + currentPos),
          Offset(
            start.dx,
            start.dy + (nextPos > totalLength ? totalLength : nextPos),
          ),
          paint,
        );
      } else {
        canvas.drawLine(
          Offset((start.dx + currentPos), start.dy),
          Offset(
            start.dx + (nextPos > totalLength ? totalLength : nextPos),
            start.dy,
          ),
          paint,
        );
      }
      currentPos += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
