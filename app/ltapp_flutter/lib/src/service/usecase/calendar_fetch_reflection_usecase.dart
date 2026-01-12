import 'package:intl/intl.dart';
import 'package:ltapp_flutter/src/service/dto/calendar_reflection_model.dart';
import 'package:ltapp_flutter/src/service/repository/reflection_repository_type.dart';

abstract interface class CalendarFetchReflectionUseCaseType {
  Future<Map<String, CalendarDayItem>> execute(DateTime start, DateTime end);
}

class CalendarFetchReflectionUseCase
    implements CalendarFetchReflectionUseCaseType {
  final ReflectionRepositoryType repository;

  CalendarFetchReflectionUseCase({required this.repository});

  @override
  Future<Map<String, CalendarDayItem>> execute(
    DateTime start,
    DateTime end,
  ) async {
    final list = await repository.fetchCalendarView(start: start, end: end);
    final Map<String, CalendarDayItem> resultMap = {};
    final startDay = start.day;
    final endDay = end.day;
    final datefromt = DateFormat('yyyy-MM-dd');
    for (int index = startDay; index <= endDay; index++) {
      final date = DateTime(start.year, start.month, index);
      final key = datefromt.format(date);
      resultMap[key] = CalendarDayItem(
        date: key,
        style: CalendarDayDashlineStyle(),
      );
    }
    for (var item in list) {
      resultMap[item.date] = CalendarDayItem(
        date: item.date,
        style: CalendarReflectionsStyle(item.date, item.reflections),
      );
    }
    return resultMap;
  }
}
