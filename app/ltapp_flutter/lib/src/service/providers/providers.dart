import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltapp_flutter/src/core/image_processor/image_processor.dart';
import 'package:ltapp_flutter/src/core/network/network_provider.dart';
import 'package:ltapp_flutter/src/core/ui_component/uicomponent.dart';
import 'package:ltapp_flutter/src/service/repository/repository.dart';
import 'package:ltapp_flutter/src/service/usecase/usecase.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

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

final processedIconProvider = FutureProvider.family<Uint8List?, IconParams>((
  ref,
  parmas,
) async {
  if (parmas.imageUrl.isEmpty) return null;
  try {
    final file = await DefaultCacheManager().getSingleFile(
      parmas.imageUrl,
      key: parmas.iconId,
    );
    final originalBytes = await file.readAsBytes();
    final processedBytes = await ImageProcessor.processIcon(originalBytes);
    return processedBytes;
  } catch (e) {
    print("error processing icon: $e");
    return null;
  }
});
