// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_answer_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddAnswerController)
final addAnswerControllerProvider = AddAnswerControllerProvider._();

final class AddAnswerControllerProvider
    extends $NotifierProvider<AddAnswerController, AddAnswerState> {
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

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddAnswerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddAnswerState>(value),
    );
  }
}

String _$addAnswerControllerHash() =>
    r'305224c994b717baba499fd46785fffd73cd922a';

abstract class _$AddAnswerController extends $Notifier<AddAnswerState> {
  AddAnswerState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AddAnswerState, AddAnswerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AddAnswerState, AddAnswerState>,
              AddAnswerState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
