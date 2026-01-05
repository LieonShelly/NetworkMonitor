import 'package:ltapp_flutter/src/service/dto/calendar_reflection_model.dart';
import 'package:ltapp_flutter/src/service/repository/reflection_repository_type.dart';

abstract interface class CalendarFetchReflectionUseCaseType {
  Future<Map<String, CalendardayModel>> execute(DateTime start, DateTime end);
}

class CalendarFetchReflectionUseCase
    implements CalendarFetchReflectionUseCaseType {
  final ReflectionRepositoryType repository;

  CalendarFetchReflectionUseCase({required this.repository});

  @override
  Future<Map<String, CalendardayModel>> execute(
    DateTime start,
    DateTime end,
  ) async {
    final list = await repository.fetchCalendarView(start: start, end: end);
    final Map<String, CalendardayModel> resultMap = {};
    for (var item in list) {
      resultMap[item.date] = item;
    }
    return resultMap;
  }
}
