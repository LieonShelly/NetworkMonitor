// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_question_banner_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TodayQuestionBannerController)
final todayQuestionBannerControllerProvider =
    TodayQuestionBannerControllerProvider._();

final class TodayQuestionBannerControllerProvider
    extends
        $NotifierProvider<TodayQuestionBannerController, TodayQuestionState> {
  TodayQuestionBannerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayQuestionBannerControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayQuestionBannerControllerHash();

  @$internal
  @override
  TodayQuestionBannerController create() => TodayQuestionBannerController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TodayQuestionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TodayQuestionState>(value),
    );
  }
}

String _$todayQuestionBannerControllerHash() =>
    r'aa35d34de50d9e6ffbc676520302e3dc842ace9d';

abstract class _$TodayQuestionBannerController
    extends $Notifier<TodayQuestionState> {
  TodayQuestionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TodayQuestionState, TodayQuestionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TodayQuestionState, TodayQuestionState>,
              TodayQuestionState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
