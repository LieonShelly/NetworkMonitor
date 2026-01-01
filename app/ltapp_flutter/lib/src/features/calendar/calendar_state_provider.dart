import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'calendar_state_provider.g.dart';

class CalendarState {
  final DateTime focusedMonth;
  final DateTime selectedDate;

  CalendarState({required this.focusedMonth, required this.selectedDate});

  CalendarState copyWith({DateTime? focusedMonth, DateTime? selectedDate}) {
    return CalendarState(
      focusedMonth: focusedMonth ?? this.focusedMonth,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

@riverpod
class CalendarStateProvider extends _$CalendarStateProvider {
  @override
  CalendarState build() {
    return CalendarState(
      focusedMonth: DateTime.now(),
      selectedDate: DateTime.now(),
    );
  }

  void onPageChanged(DateTime newMonth) {
    state = state.copyWith(focusedMonth: newMonth);
  }

  void setdDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }
}
