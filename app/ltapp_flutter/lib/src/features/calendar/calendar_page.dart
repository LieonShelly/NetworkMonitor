import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ltapp_flutter/src/core/ui_component/svg_asset.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 0,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              DateFormat('MMMM').format(_focusedDay),
              style: TextStyle(
                fontSize: 36,
                color: Color(0xFF000000),
                fontFamily: 'FeltTipSeniorRegular',
              ),
              textAlign: TextAlign.center,
            ),
            SvgAsset('down_arrow_fill.svg', width: 24, height: 24),

            Spacer(),
            Text(
              DateFormat('dd').format(_focusedDay),
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF000000),
                fontFamily: 'FeltTipSeniorRegular',
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
  }

  Widget _buildCustomTableCalendar() {
    return TableCalendar(
      focusedDay: _focusedDay,
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      headerVisible: false,
      selectedDayPredicate: (day) => isSameDay(_seletecDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _seletecDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
      calendarBuilders: CalendarBuilders(
        dowBuilder: (context, day) {
          final text = DateFormat.E().format(day)[0];
          return Center(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
        defaultBuilder: (context, day, focusedDay) {
          return _buildDayCell(day, isToday: false);
        },
        todayBuilder: (context, day, focusedDay) {
          return _buildDayCell(day, isToday: true);
        },
        selectedBuilder: (context, day, focusedDay) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: _buildDayCell(day, isToday: false),
          );
        },
      ),
    );
  }

  Widget _buildDayCell(DateTime day, {required bool isToday}) {
    bool hasIcon = day.day == 15 || day.day == 20;
    if (hasIcon) {
      return Center(child: Icon(Icons.coffee, size: 24, color: Colors.black87));
    }
    return Center(
      child: Text(
        '${day.day}',
        style: TextStyle(
          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          decoration: isToday ? TextDecoration.underline : null,
        ),
      ),
    );
  }

  Widget _buildFooterStats() {
    return Column(
      children: const [
        Text(
          '9 icons created this month',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          '20 more days to go!',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
        ),
      ],
    );
  }
}
