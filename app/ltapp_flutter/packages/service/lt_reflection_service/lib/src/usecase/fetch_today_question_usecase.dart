import '../dto/dto_model.dart';
import '../repository/repository.dart';

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
