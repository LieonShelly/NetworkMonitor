import 'package:ltapp_flutter/src/service/dto/calendar_reflection_model.dart';
import 'package:ltapp_flutter/src/service/providers/reflection_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'calendar_controller.g.dart';

class CalendarState {
  final DateTime focusedMonth;
  final DateTime selectedDate;
  final List<CalendarMonthItem> monthList;
  final AsyncValue<Map<String, CalendarDayItem>> reflectionMap;

  CalendarState({
    required this.monthList,
    required this.focusedMonth,
    required this.selectedDate,
    this.reflectionMap = const AsyncValue.loading(),
  });

  CalendarState copyWith({
    List<CalendarMonthItem>? monthList,
    DateTime? focusedMonth,
    DateTime? selectedDate,
    AsyncValue<Map<String, CalendarDayItem>>? reflectionMap,
  }) {
    return CalendarState(
      monthList: monthList ?? this.monthList,
      focusedMonth: focusedMonth ?? this.focusedMonth,
      selectedDate: selectedDate ?? this.selectedDate,
      reflectionMap: reflectionMap ?? this.reflectionMap,
    );
  }
}

@riverpod
class CalendarController extends _$CalendarController {
  @override
  CalendarState build() {
    final now = DateTime.now();
    final monthList = generateMonthList();
    _fetchData(now);
    return CalendarState(
      monthList: monthList,
      focusedMonth: now,
      selectedDate: now,
    );
  }

  void onPageChanged(DateTime newMonth) {
    state = state.copyWith(focusedMonth: newMonth);
    _fetchData(newMonth);
  }

  void setdDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  Future<void> _fetchData(DateTime month) async {
    final useCase = ref.read(calendarFetchReflectionUseCaseProvider);
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);

    try {
      final data = await useCase.execute(start, end);
      if (!ref.mounted) return;
      if (state.focusedMonth.year == month.year &&
          state.focusedMonth.month == month.month) {
        final currentMap = state.reflectionMap.value ?? {};
        final mergedMap = Map<String, CalendarDayItem>.from(currentMap);
        mergedMap.addAll(data);
        if (ref.mounted) {
          state = state.copyWith(reflectionMap: AsyncValue.data(mergedMap));
        }
      }
    } catch (e, stack) {
      if (!ref.mounted) return;
      if (state.focusedMonth.year == month.year &&
          state.focusedMonth.month == month.month) {
        state = state.copyWith(reflectionMap: AsyncValue.error(e, stack));
      }
    }
  }

  Future<void> refreshCurrentMonth() async {
    await _fetchData(state.focusedMonth);
  }

  List<CalendarMonthItem> generateMonthList() {
    DateTime now = DateTime.now();
    List<CalendarMonthItem> moths = [];

    moths.add(
      CalendarMonthItem(
        month: DateTime(now.year, 1),
        days: [],
        style: CalendarMonthItemStyle.showYear,
      ),
    );
    for (var index = 1; index <= 12; index++) {
      final month = DateTime(now.year, index);
      moths.add(
        CalendarMonthItem(
          month: month,
          days: [],
          style: CalendarMonthItemStyle.normal,
        ),
      );
    }
    return moths;
  }
}

enum CalendarMonthItemStyle { normal, showYear }

class CalendarMonthItem {
  final DateTime month;
  final List<CalendarDayItem> days;
  final CalendarMonthItemStyle style;

  const CalendarMonthItem({
    required this.month,
    required this.days,
    required this.style,
  });
}
