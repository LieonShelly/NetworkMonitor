import 'package:lt_reflection_service/reflection_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'today_question_banner_controller.g.dart';

class TodayQuestionState {
  final AsyncValue<List<QuestionModel>> todayQuestions;

  TodayQuestionState({this.todayQuestions = const AsyncValue.loading()});

  TodayQuestionState copyWith({
    AsyncValue<List<QuestionModel>>? todayQuestions,
  }) {
    return TodayQuestionState(
      todayQuestions: todayQuestions ?? this.todayQuestions,
    );
  }
}

@riverpod
class TodayQuestionBannerController extends _$TodayQuestionBannerController {
  @override
  TodayQuestionState build() {
    _fetchTodayQuestions();
    return TodayQuestionState();
  }

  Future<void> _fetchTodayQuestions() async {
    final usecase = ref.read(fethTodayQuestionUseCaseProvider);
    try {
      final list = await usecase.execute();
      if (!ref.mounted) return;
      state = state.copyWith(todayQuestions: AsyncValue.data(list));
    } catch (e, stack) {
      if (!ref.mounted) return;
      state = state.copyWith(todayQuestions: AsyncValue.error(e, stack));
    }
  }
}
