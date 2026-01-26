import 'package:ltapp_flutter/src/service/dto/dto_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'add_answer_controller.g.dart';

class AddAnswerState {
  final AnswerSubmittedParam? param;

  const AddAnswerState({this.param});

  AddAnswerState copyWith(AnswerSubmittedParam? param) {
    return AddAnswerState(param: param ?? this.param);
  }
}

@riverpod
class AddAnswerController extends _$AddAnswerController {
  @override
  AddAnswerState build() {
    return AddAnswerState();
  }

  // Future<void> submitAnswer() {}
}
