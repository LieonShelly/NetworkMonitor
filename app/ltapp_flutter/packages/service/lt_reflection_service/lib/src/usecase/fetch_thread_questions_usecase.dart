import '../dto/calendar_reflection_model.dart';
import '../repository/repository.dart';

abstract interface class FetchThreadQuestionsUseCaseType {
  Future<List<QuestionModel>> execute();
}

final class FetchThreadQuestionsUseCase
    implements FetchThreadQuestionsUseCaseType {
  final ReflectionRepositoryType _repository;

  const FetchThreadQuestionsUseCase({
    required ReflectionRepositoryType repository,
  }) : _repository = repository;

  @override
  Future<List<QuestionModel>> execute() async {
    return await _repository.fetchThreadQuestions();
  }
}
