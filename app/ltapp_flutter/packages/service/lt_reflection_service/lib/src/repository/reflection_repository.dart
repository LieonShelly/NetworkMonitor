import 'package:intl/intl.dart';
import 'package:lt_network/network.dart';
import '../dto/answer_submitted_param.dart';
import '../dto/calendar_reflection_model.dart';
import 'reflection_repository_type.dart';

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

  @override
  Future<List<QuestionModel>> fetchTodayQuestions() async {
    final response = await _apiClient.get('/api/questions-of-the-day');
    final data = response['data'];
    if (data is List) {
      return data.map((e) => QuestionModel.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  @override
  Future<AnswerModel> submit({required AnswerSubmittedParam param}) async {
    final response = await _apiClient.post(
      '/api/answers',
      data: param.mapToJson(),
    );
    final data = response["data"];
    return AnswerModel.fromJson(data);
  }

  @override
  Future<List<QuestionModel>> fetchThreadQuestions() async {
    final response = await _apiClient.get('/api/thread-view');
    final data = response['data'];
    if (data is List) {
      return data.map((e) => QuestionModel.fromJson(e)).toList();
    } else {
      return [];
    }
  }
}
