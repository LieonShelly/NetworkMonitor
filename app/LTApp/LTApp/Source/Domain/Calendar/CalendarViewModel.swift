//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation
import SwiftUI
import Kingfisher
import LTCommon

final class CalendarViewModel: ObservableObject, @unchecked Sendable {
    @MainActor @Published var weekdays: [WeekDay] = [
        WeekDay(title: "S"),
        WeekDay(title: "M"),
        WeekDay(title: "T"),
        WeekDay(title: "W"),
        WeekDay(title: "T"),
        WeekDay(title: "F"),
        WeekDay(title: "S")
    ]
    var currentMonth: CalendarMonth?
    @MainActor @Published var contentScrollPostion: UUID? = nil
    @MainActor @Published var monthScrollPostion: UUID? = nil
    @MainActor @Published var todayUpdatingIcon: IconData?
    @MainActor @Published var selectedDay: CalendarDay?
    @MainActor @Published var months: [CalendarMonth] = []
    @MainActor @Published var todayQuestions: [Question] = []
    @MainActor @Published var showTodayQuestion: Bool = true
    let itemSize: CGSize = .init(width: 30, height: 30)
    
    private let service: any AppDataWithAuthorizationServiceful
    private var didTapMontHeaderItem: Bool = false
    
    init(service: any AppDataWithAuthorizationServiceful) {
        self.service = service
    }
    
    deinit {
        debugPrint("deinit-CalendarViewModel")
    }
    
    func queryCurrenntIconStatus(_ iconId: String) {
        Task.detached {
            try await self.fetchData()
            let streams = self.service.queryIconStatusUseCase.execute(iconId)
            for try await stream in streams {
                await MainActor.run {
                    self.todayUpdatingIcon = stream.toDomain()
                }
            }
            try await self.fetchData()
        }
    }
    
    
    @MainActor
    func organize() -> [Question] {
        let count = self.todayQuestions.count
        let questions = self.todayQuestions
        guard let head = questions.first else { return [] }
       return [head] + questions[1 ..< count]
    }
}

extension CalendarViewModel {
    func fetchData() async throws {
        guard let currentMonth else { return }
        let endMonth = currentMonth.date.endOfMonth()
        let startMonth = currentMonth.date.startOfMonth()
        let reflections = try await service.calendarReflectionsUseCase.execute(
            startMonth: startMonth,
            endMonth: endMonth
        )
        await MainActor.run {
            var months = self.months
            for relectionIndex in 0 ..< reflections.count {
                let reflection = reflections[relectionIndex]
                for monthIndex in 0 ..< months.count {
                    var days = months[monthIndex].days
                    if let index = days.firstIndex(where: { $0.date.isSameDay(reflection.day)}) {
                        let newDay = days[index].copyWith(reflection)
                        days[index] = newDay
                    }
                    guard let firstAnswerDay = days.first(where: {$0.reflections != nil })?.date,
                          let endAnswerDay = days.last(where: { $0.reflections != nil })?.date else {
                        continue
                    }
                    let emptyDays = days.filter { $0.reflections == nil}
                    for emptyDay in emptyDays {
                        guard let dayIndex = days.firstIndex(where: { $0.id == emptyDay.id }) else { continue }
                        days[dayIndex].isAbsent = days[dayIndex].date >= firstAnswerDay &&  days[dayIndex].date <= endAnswerDay
                    }
                    let totalIcons = days
                        .filter { $0.isCurrentMonth }
                        .flatMap { $0.reflections?.reflections ?? []}
                        .filter { $0.icon != nil}.count
                    months[monthIndex].days = days
                    months[monthIndex].iconCount = totalIcons
                    let currentMonth = Date()
                    if months[monthIndex].date.isSameMonth(currentMonth), let currentIndex = days.firstIndex(where: { $0.date.isSameDay(currentMonth)}) {
                        months[monthIndex].moreDaysTogo = days.count - currentIndex - 1
                    }
                }
            }
            self.months = months
        }
    }
    
    func fetchDataTodayQuestions() async throws {
        let questions = try await service.fetchTodayQuestionsUseCase.execute()
        await MainActor.run {
            self.todayQuestions = questions
        }
    }
}

extension CalendarViewModel {
    
    @MainActor
    func onTapIcon(_ day: CalendarDay) -> TodayAnswerSubmittedViewModel? {
        guard let answer = day.reflections?.reflections.last, let question = answer.question  else {
            return nil
        }
        let todayAnswerSubmittedViewModel = TodayAnswerSubmittedViewModel(answer: answer, question: question, service: service)
        return todayAnswerSubmittedViewModel
    }
    
    
    @MainActor
    func onMonthContentScroll(_ progress: CGFloat) {
        guard !didTapMontHeaderItem else { return }
        let index = Int(progress.rounded())
        let monthContentItems = months.filter { $0.isValildMonth }
        guard index < monthContentItems.count else { return }
        let month = monthContentItems[index]
        currentMonth = month
        withAnimation(.easeInOut) {
            self.monthScrollPostion = month.id
        }
    }
    
    @MainActor
    func scrollToCurrentMonth() {
        let endMonth = Date()
        if let month = months.first(where: { $0.itemType == .normal && $0.date.isSameMonth(endMonth)}) {
            currentMonth = month
            didTapMontHeaderItem = true
            withAnimation(.easeInOut, completionCriteria: .logicallyComplete) {
                self.contentScrollPostion = month.id
                self.monthScrollPostion = month.id
            } completion: {
                self.didTapMontHeaderItem = false
            }
        }
    }
    
    @MainActor
    func didTapMonth(_ month: CalendarMonth) {
        currentMonth = month
        didTapMontHeaderItem = true
        withAnimation(.easeInOut, completionCriteria: .logicallyComplete) {
            self.monthScrollPostion = month.id
            self.contentScrollPostion = month.id
        } completion: {
            self.didTapMontHeaderItem = false
        }
    }
}


extension CalendarViewModel {
    
    func generateMonths() async {
        let calendar = Calendar.current
        var startComponents = DateComponents()
        startComponents.year = 2025
        startComponents.month = 1
        startComponents.day = 1
        let startDate = calendar.date(from: startComponents) ?? Date()
        
        let now = Date()
        let endDate = calendar.date(byAdding: .month, value: 1, to: now) ?? now
        let newMonths = await generateMonthsInRange(from: startDate, to: endDate)
        
        await MainActor.run {
            self.months = newMonths
        }
    }
    
    func generateAnswerDetailViewModel(_ answer: Answer) -> TodayAnswerSubmittedViewModel? {
        guard let question = answer.question else { return nil }
        return .init(answer: answer, question: question, service: service)
    }
    
    func generateMonthsInRange(from startDate: Date, to endDate: Date) async -> [CalendarMonth] {
        let calendar = Calendar.current
        var months: [CalendarMonth] = []
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: startDate)),
              let endOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: endDate)) else {
            return []
        }
        var currentDateIterator = startOfMonth
        while currentDateIterator <= endOfMonth {
            let currentMonth = calendar.component(.month, from: currentDateIterator)
            if currentMonth == 1 || currentDateIterator == startOfMonth {
                let zeroMonth = CalendarMonth(date: currentDateIterator, itemType: .yearPlaceholder)
                months.append(zeroMonth)
            }
            if let monthData = await generateSingleMonthData(for: currentDateIterator) {
                months.append(monthData)
            }
            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentDateIterator) else {
                break
            }
            currentDateIterator = nextMonth
        }
        return months
    }
    
    func generateSingleMonthData(for date: Date) async -> CalendarMonth? {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: date) else {
            return nil
        }
        
        guard let firstDayInMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return nil
        }
        var days: [CalendarDay] = []
        var weekdayOffset = calendar.component(.weekday, from: firstDayInMonth) - calendar.firstWeekday
        let totalDays = range.count
        if weekdayOffset < 0 {
            weekdayOffset += 7
        }
        for index in 0 ..< weekdayOffset {
            if let date = calendar.date(byAdding: .day, value: -weekdayOffset + index, to: firstDayInMonth) {
                days.append(
                    CalendarDay(
                        date: date,
                        isCurrentMonth: false,
                        isToday: false,
                        isAbsent: true
                    )
                )
            }
        }
        guard totalDays >= 1 else { return nil }
        for day in 1...totalDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayInMonth) {
                days.append(
                    CalendarDay(
                        date: date,
                        isCurrentMonth: true,
                        isToday: calendar.isDateInToday(date),
                        isAbsent: true
                    )
                )
            }
        }
        let calendarMonth = CalendarMonth(date: date, days: days, iconCount: 0, moreDaysTogo: 0)
        return calendarMonth
    }
}
