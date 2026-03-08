import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lt_reflection_service/reflection_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'thread_page_controller.freezed.dart';
part 'thread_page_controller.g.dart';

@freezed
class ThreadPageState with _$ThreadPageState {
  final AsyncValue<List<QuestionModel>> questions;

  ThreadPageState({required this.questions});
}

@riverpod
final class ThreadPageController extends _$ThreadPageController {
  @override
  ThreadPageState build() {
    _fetchThreadData();
    return ThreadPageState(questions: AsyncValue.loading());
  }

  void _fetchThreadData() async {
    final useCase = ref.read(fetchThreadQuestionsUseCaseProvider);
    try {
      final list = await useCase.execute();
      if (!ref.mounted) return;
      state = state.copyWith(questions: AsyncValue.data(list));
    } catch (e, stack) {
      if (!ref.mounted) return;
      state = state.copyWith(questions: AsyncValue.error(e, stack));
    }
  }
}
