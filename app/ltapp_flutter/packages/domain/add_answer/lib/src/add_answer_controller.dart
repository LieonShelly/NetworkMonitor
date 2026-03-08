import 'package:intl/intl.dart';

import 'package:lt_reflection_service/reflection_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part './add_answer_controller.g.dart';

@riverpod
class AddAnswerController extends _$AddAnswerController {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> submitAnswer({
    required String questionId,
    required String content,
  }) async {
    final useCase = ref.read(submitAnswerUsecaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final DateFormat formt = DateFormat("yyyy-MM-dd HH:mm:ss");
      final createdAt = formt.format(DateTime.now());
      await useCase.execute(
        AnswerSubmittedParam(
          questionId: questionId,
          content: content,
          createdAt: createdAt,
        ),
      );
    });
  }
}
