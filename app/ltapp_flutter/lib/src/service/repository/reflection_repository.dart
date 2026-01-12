import 'package:intl/intl.dart';
import 'package:ltapp_flutter/src/core/network/api_client.dart';
import 'package:ltapp_flutter/src/service/dto/calendar_reflection_model.dart';
import 'package:ltapp_flutter/src/service/repository/reflection_repository_type.dart';

class ReflectionRepository implements ReflectionRepositoryType {
  final ApiClientType _apiClient;

  ReflectionRepository({required ApiClientType apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<CalendardayDto>> fetchCalendarView({
    required DateTime start,
    required DateTime end,
  }) async {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String startStr = formatter.format(start);
    final String endStr = formatter.format(end);

    final response = await _apiClient.get(
      '/api/calendar-view',
      queryParameters: {'start': startStr, 'end': endStr},
    );
    final data = response['data'];
    if (data is List) {
      return data.map((e) => CalendardayDto.fromJson(e)).toList();
    } else {
      return [];
    }
  }
}
