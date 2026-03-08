import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lt_uicomponent/uicomponent.dart';
import 'package:lt_network/network.dart';
import '../repository/repository.dart';
import '../usecase/usecase.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

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
    final tempDir = await getTemporaryDirectory();
    final prcocessedFilePath =
        '${tempDir.path}/processed_icon+${parmas.iconId}.png';
    final processedFile = File(prcocessedFilePath);
    if (await processedFile.exists()) {
      return await processedFile.readAsBytes();
    }
    final file = await DefaultCacheManager().getSingleFile(
      parmas.imageUrl,
      key: parmas.iconId,
    );
    final originalBytes = await file.readAsBytes();
    final processedBytes = await ImageProcessor.processIcon(originalBytes);
    if (processedBytes != null && processedBytes.isNotEmpty) {
      await processedFile.writeAsBytes(processedBytes);
    }
    return processedBytes;
  } catch (e) {
    return null;
  }
});

final fetchThreadQuestionsUseCaseProvider =
    Provider<FetchThreadQuestionsUseCaseType>((ref) {
      final repository = ref.watch(reflectionRepositoryProvider);
      final usecase = FetchThreadQuestionsUseCase(repository: repository);
      return usecase;
    });
