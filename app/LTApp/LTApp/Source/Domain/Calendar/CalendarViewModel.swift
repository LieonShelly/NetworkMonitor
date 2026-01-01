//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation
import SwiftUI
import Kingfisher

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
    
    let itemSize: CGSize = .init(width: 30, height: 30)
    
    private let service: any AppDataWithAuthorizationServiceful
    private var didTapMontHeaderItem: Bool = false
    
    init(service: any AppDataWithAuthorizationServiceful) {
        self.service = service
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
                        months[monthIndex].moreDaysTogo = days.count - currentIndex
                    }
                }
            }
            self.months = months
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
    func generateMonthForYear(_ year: Int) async -> [CalendarMonth] {
        let calendar = AppCalendar.current
        var component = DateComponents()
        component.year = year
        var calendarMonths: [CalendarMonth] = []
        if let monthDate = calendar.date(from: component) {
            let zeroMonth = CalendarMonth(date: monthDate, itemType: .yearPlaceholder)
            calendarMonths.append(zeroMonth)
        }
        
        for month in 1 ... 12 {
            component.month = month
            
            guard let monthDate = calendar.date(from: component),
                  let range = calendar.range(of: .day, in: .month, for: monthDate) else {
                continue
            }
            
            guard let firstDayInMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate)) else {
                continue
            }
            var days: [CalendarDay] = []
            let weekdayOffset = calendar.component(.weekday, from: firstDayInMonth) - calendar.firstWeekday
            let totalDays = range.count
            guard weekdayOffset >= 0 else { continue }
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
            guard totalDays >= 1 else { continue }
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
            let calendarMonth = CalendarMonth(date: monthDate, days: days, iconCount: 0, moreDaysTogo: 0)
            calendarMonths.append(calendarMonth)
        }
        return calendarMonths
    }
    
    func generateMonths() async {
        var months = [CalendarMonth]()
        months.append(contentsOf: await generateMonthForYear(2025))
        months.append(contentsOf: await generateMonthForYear(2026))
        await MainActor.run {
            self.months = months
        }
    }
    
    func generateAnswerDetailViewModel(_ answer: Answer) -> TodayAnswerSubmittedViewModel? {
        guard let question = answer.question else { return nil }
        return .init(answer: answer, question: question, service: service)
    }
}
