import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:date_utl/date_utl.dart';
import 'calendar_item_view.dart';
import 'package:lt_reflection_service/reflection_service.dart';

class CalendarMonthView extends StatelessWidget {
  final DateTime month;
  final Function(DateTime) onDateTap;
  final double childAspectRatio;
  final double cellHeight;
  final Map<String, CalendarDayItem>? dataMap;

  const CalendarMonthView({
    super.key,
    required this.month,
    required this.onDateTap,
    required this.cellHeight,
    required this.childAspectRatio,
    this.dataMap,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtl.getDaysInMonth(month.year, month.month);
    final firstDayOffset = DateUtl.getFirstDayOffset(month.year, month.month);
    final int totalSlots = daysInMonth + firstDayOffset;
    final int rowCount = (totalSlots / 7).ceil();
    final int totalCells = rowCount * 7;
    final double childAspectRatio = this.childAspectRatio;
    final canvas = CustomPaint(
      painter: DashedGridPainter(
        color: Colors.black.withOpacity(0.1),
        dashWidth: 3,
        dashSpace: 3,
        rows: rowCount,
        rowHeight: cellHeight,
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: totalCells,
        itemBuilder: (context, index) {
          if (index < firstDayOffset || index >= firstDayOffset + daysInMonth) {
            return const SizedBox();
          }
          final day = index - firstDayOffset + 1;
          final currentDate = DateTime(month.year, month.month, day);
          final key = DateFormat('yyyy-MM-dd').format(currentDate);
          final item = dataMap?[key];
          return _buildDayCell(currentDate, item, () => onDateTap(currentDate));
        },
      ),
    );
    return SizedBox(height: rowCount * cellHeight, child: canvas);
  }

  Widget _buildDayCell(
    DateTime day,
    CalendarDayItem? item,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: CalendarItemView(date: day, item: item),
    );
  }
}

class DashedGridPainter extends CustomPainter {
  final Color color;
  final double strokedWith;
  final double dashWidth;
  final double dashSpace;
  final int rows;
  final double rowHeight;

  DashedGridPainter({
    this.color = const Color(0xffe0e0e0),
    this.strokedWith = 1.0,
    this.dashWidth = 4.0,
    this.dashSpace = 4.0,
    required this.rows,
    required this.rowHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokedWith
      ..style = PaintingStyle.stroke;

    final cellWidth = size.width / 7;
    final cellHeight = rowHeight;

    for (int i = 1; i < 7; i++) {
      final x = i * cellWidth;
      _drawDashedline(canvas, paint, Offset(x, 0), Offset(x, size.height));
    }

    for (int i = 1; i < rows; i++) {
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
  bool shouldRepaint(covariant DashedGridPainter oldDelegate) {
    return oldDelegate.rows != rows || oldDelegate.color != color;
  }
}
