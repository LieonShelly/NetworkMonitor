import '../dto/answer_submitted_param.dart';
import '../dto/calendar_reflection_model.dart';

abstract interface class ReflectionRepositoryType {
  Future<List<CalendardayDto>> fetchCalendarView({
    required DateTime start,
    required DateTime end,
  });

  Future<List<QuestionModel>> fetchTodayQuestions();

  Future<List<QuestionModel>> fetchThreadQuestions();

  Future<AnswerModel> submit({required AnswerSubmittedParam param});
}
