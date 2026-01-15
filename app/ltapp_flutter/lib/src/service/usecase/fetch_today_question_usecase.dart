import 'package:ltapp_flutter/src/service/dto/dto_model.dart';
import 'package:ltapp_flutter/src/service/repository/repository.dart';

abstract interface class FetchTodayQuestionUseCaseType {
  Future<List<QuestionModel>> execute();
}

final class FetchTodayQuestionUseCase implements FetchTodayQuestionUseCaseType {
  final ReflectionRepositoryType repository;

  const FetchTodayQuestionUseCase({required this.repository});

  @override
  Future<List<QuestionModel>> execute() async {
    return await repository.fetchTodayQuestions();
  }
}
