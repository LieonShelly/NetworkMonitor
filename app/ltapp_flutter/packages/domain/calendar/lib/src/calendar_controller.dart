import 'package:lt_reflection_service/reflection_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'calendar_controller.g.dart';

class CalendarState {
  final DateTime focusedMonth;
  final DateTime selectedDate;
  final List<CalendarMonthItem> monthList;
  final AsyncValue<Map<String, CalendarDayItem>> reflectionMap;
  final AsyncValue<List<QuestionModel>> todayQuestions;

  CalendarState({
    required this.monthList,
    required this.focusedMonth,
    required this.selectedDate,
    this.reflectionMap = const AsyncValue.loading(),
    this.todayQuestions = const AsyncValue.loading(),
  });

  CalendarState copyWith({
    List<CalendarMonthItem>? monthList,
    DateTime? focusedMonth,
    DateTime? selectedDate,
    AsyncValue<Map<String, CalendarDayItem>>? reflectionMap,
    AsyncValue<List<QuestionModel>>? todayQuestions,
  }) {
    return CalendarState(
      monthList: monthList ?? this.monthList,
      focusedMonth: focusedMonth ?? this.focusedMonth,
      selectedDate: selectedDate ?? this.selectedDate,
      reflectionMap: reflectionMap ?? this.reflectionMap,
      todayQuestions: todayQuestions ?? this.todayQuestions,
    );
  }
}

@riverpod
class CalendarController extends _$CalendarController {
  List<CalendarMonthItem> get normalMonths {
    return state.monthList
        .where((e) => e.style == CalendarMonthItemStyle.normal)
        .toList();
  }

  @override
  CalendarState build() {
    final now = DateTime.now();
    final monthList = _generateMonthList();
    _fetchCalendarData(now);
    return CalendarState(
      monthList: monthList,
      focusedMonth: now,
      selectedDate: now,
    );
  }

  void onPageChanged(DateTime newMonth) {
    state = state.copyWith(focusedMonth: newMonth);
    _fetchCalendarData(newMonth);
  }

  void setdDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  Future<void> refreshCurrentMonth() async {
    await _fetchCalendarData(state.focusedMonth);
  }

  Future<void> _fetchCalendarData(DateTime month) async {
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

  List<CalendarMonthItem> _generateMonthList() {
    DateTime now = DateTime.now();
    List<CalendarMonthItem> moths = [];

    for (var year = 2025; year <= now.year + 10; year++) {
      moths.add(
        CalendarMonthItem(
          month: DateTime(year, 1),
          style: CalendarMonthItemStyle.showYear,
        ),
      );
      for (var index = 1; index <= 12; index++) {
        final month = DateTime(year, index);
        moths.add(
          CalendarMonthItem(month: month, style: CalendarMonthItemStyle.normal),
        );
      }
    }

    return moths;
  }
}

enum CalendarMonthItemStyle { normal, showYear }

class CalendarMonthItem {
  final DateTime month;
  final CalendarMonthItemStyle style;

  const CalendarMonthItem({required this.month, required this.style});
}
