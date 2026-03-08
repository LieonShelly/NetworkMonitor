import 'package:intl/intl.dart';
import '../dto/dto_model.dart';
import '../repository/repository.dart';

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
    final datefromt = DateFormat('yyyy-MM-dd');
    DateTime currentDay;
    DateTime targetEnday;
    if (list.isEmpty) {
      currentDay = DateTime(start.year, start.month, start.day);
      targetEnday = DateTime(end.year, end.month, end.day);
    } else {
      currentDay = DateTime.parse(list.first.date);
      targetEnday = DateTime.parse(list.last.date);
    }

    while (!currentDay.isAfter(targetEnday)) {
      final key = datefromt.format(currentDay);
      if (list.isEmpty) {
        resultMap[key] = CalendarDayItem(
          date: key,
          style: const CalendarDayOnlyDateStyle(),
        );
      } else {
        resultMap[key] = CalendarDayItem(
          date: key,
          style: const CalendarDayDashlineStyle(),
        );
      }
      currentDay = currentDay.add(const Duration(days: 1));
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
