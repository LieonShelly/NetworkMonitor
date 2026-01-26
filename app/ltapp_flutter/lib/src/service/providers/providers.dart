import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltapp_flutter/src/core/network/network_provider.dart';
import 'package:ltapp_flutter/src/service/repository/repository.dart';
import 'package:ltapp_flutter/src/service/usecase/usecase.dart';

final reflectionRepositoryProvider = Provider<ReflectionRepositoryType>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReflectionRepository(apiClient: apiClient);
});

final calendarFetchReflectionUseCaseProvider =
    Provider<CalendarFetchReflectionUseCaseType>((ref) {
      final repository = ref.watch(reflectionRepositoryProvider);
      return CalendarFetchReflectionUseCase(repository: repository);
    });

final fethTodayQuestionUseCaseProvider =
    Provider<FetchTodayQuestionUseCaseType>((ref) {
      final repository = ref.watch(reflectionRepositoryProvider);
      return FetchTodayQuestionUseCase(repository: repository);
    });

final submitAnswerUsecaseProvider = Provider<SubmitAnswerUsecaseType>((ref) {
  final repository = ref.watch(reflectionRepositoryProvider);
  return SubmitAnswerUsecase(repository: repository);
});
