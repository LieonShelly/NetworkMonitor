// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CalendarStateProvider)
final calendarStateProviderProvider = CalendarStateProviderProvider._();

final class CalendarStateProviderProvider
    extends $NotifierProvider<CalendarStateProvider, CalendarState> {
  CalendarStateProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarStateProviderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarStateProviderHash();

  @$internal
  @override
  CalendarStateProvider create() => CalendarStateProvider();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalendarState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalendarState>(value),
    );
  }
}

String _$calendarStateProviderHash() =>
    r'623fdcd208488c31e25ea91229b2f4926ed6fa12';

abstract class _$CalendarStateProvider extends $Notifier<CalendarState> {
  CalendarState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CalendarState, CalendarState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CalendarState, CalendarState>,
              CalendarState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
