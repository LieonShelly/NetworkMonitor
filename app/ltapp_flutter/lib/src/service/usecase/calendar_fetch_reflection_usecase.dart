import 'package:ltapp_flutter/src/service/dto/calendar_reflection_model.dart';
import 'package:ltapp_flutter/src/service/repository/reflection_repository_type.dart';

abstract interface class CalendarFetchReflectionUseCaseType {
  Future<List<CalendardayModel>> execute(DateTime start, DateTime end);
}

class CalendarFetchReflectionUseCase
    implements CalendarFetchReflectionUseCaseType {
  final ReflectionRepositoryType repository;

  CalendarFetchReflectionUseCase({required this.repository});

  @override
  Future<List<CalendardayModel>> execute(DateTime start, DateTime end) async {
    return await repository.fetchCalendarView(start: start, end: end);
  }
}
