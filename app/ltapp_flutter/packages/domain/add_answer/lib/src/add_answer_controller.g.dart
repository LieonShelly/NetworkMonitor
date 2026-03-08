// GENERATED CODE - DO NOT MODIFY BY HAND

part of './add_answer_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddAnswerController)
final addAnswerControllerProvider = AddAnswerControllerProvider._();

final class AddAnswerControllerProvider
    extends $AsyncNotifierProvider<AddAnswerController, void> {
  AddAnswerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addAnswerControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addAnswerControllerHash();

  @$internal
  @override
  AddAnswerController create() => AddAnswerController();
}

String _$addAnswerControllerHash() =>
    r'dbe69fe36c409945b6e5d0f3e68cb5454f1a31ad';

abstract class _$AddAnswerController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
