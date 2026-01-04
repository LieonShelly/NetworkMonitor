import 'package:ltapp_flutter/src/service/calendar_reflection_model.dart';

abstract interface class ReflectionRepositoryType {
  Future<List<CalendardayModel>> fetchCalendarView({
    required DateTime start,
    required DateTime end,
  });
}
