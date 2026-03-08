import '../dto/dto_model.dart';
import '../repository/reflection_repository_type.dart';

abstract interface class SubmitAnswerUsecaseType {
  Future<AnswerModel> execute(AnswerSubmittedParam param);
}

final class SubmitAnswerUsecase implements SubmitAnswerUsecaseType {
  final ReflectionRepositoryType repository;
  const SubmitAnswerUsecase({required this.repository});

  @override
  Future<AnswerModel> execute(AnswerSubmittedParam param) {
    return repository.submit(param: param);
  }
}
