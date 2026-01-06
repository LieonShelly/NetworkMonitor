import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltapp_flutter/src/core/network/network_provider.dart';
import 'package:ltapp_flutter/src/service/repository/reflection_repository.dart';
import 'package:ltapp_flutter/src/service/repository/reflection_repository_type.dart';
import 'package:ltapp_flutter/src/service/usecase/calendar_fetch_reflection_usecase.dart';

final reflectionRepositoryProvider = Provider<ReflectionRepositoryType>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReflectionRepository(apiClient: apiClient);
});

final calendarFetchReflectionUseCaseProvider =
    Provider<CalendarFetchReflectionUseCaseType>((ref) {
      final repository = ref.watch(reflectionRepositoryProvider);
      return CalendarFetchReflectionUseCase(repository: repository);
    });
