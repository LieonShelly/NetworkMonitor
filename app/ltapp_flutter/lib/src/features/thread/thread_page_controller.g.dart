// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_page_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ThreadPageController)
final threadPageControllerProvider = ThreadPageControllerProvider._();

final class ThreadPageControllerProvider
    extends $NotifierProvider<ThreadPageController, ThreadPageState> {
  ThreadPageControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'threadPageControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$threadPageControllerHash();

  @$internal
  @override
  ThreadPageController create() => ThreadPageController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThreadPageState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThreadPageState>(value),
    );
  }
}

String _$threadPageControllerHash() =>
    r'568d32bc6875bf5ed4032d8083123a6caed7634d';

abstract class _$ThreadPageController extends $Notifier<ThreadPageState> {
  ThreadPageState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ThreadPageState, ThreadPageState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThreadPageState, ThreadPageState>,
              ThreadPageState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
