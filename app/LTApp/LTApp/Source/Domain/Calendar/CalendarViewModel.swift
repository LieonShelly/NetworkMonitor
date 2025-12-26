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
    @MainActor @Published var currentMonth: CalendarMonth?
    @MainActor @Published var contentScrollPostion: UUID? = nil
    @MainActor @Published var monthScrollPostion: UUID? = nil
    @MainActor @Published var todayUpdatingIcon: IconData?
    @MainActor @Published var selectedDay: CalendarDay?
    @MainActor @Published var months: [CalendarMonth] = []
    
    let itemSize: CGSize = .init(width: 30, height: 30)
    
    private let service: any AppDataWithAuthorizationServiceful
    
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
    
    @MainActor
    func onTapIcon(_ day: CalendarDay) -> TodayAnswerSubmittedViewModel? {
        guard let answer = day.reflections?.reflections.last, let question = answer.question  else {
            return nil
        }
        let todayAnswerSubmittedViewModel = TodayAnswerSubmittedViewModel(answer: answer, question: question, service: service)
        return todayAnswerSubmittedViewModel
    }
    
    @MainActor
    func onContentScroll(_ progress: CGFloat) {
        let index = Int(progress.rounded())
        guard index < months.count else { return }
        let month = months[index]
        withAnimation(.easeInOut) {
            self.monthScrollPostion = month.id
            currentMonth = month
        }
    }
    
    func generateAnswerDetailViewModel(_ answer: Answer) -> TodayAnswerSubmittedViewModel? {
        guard let question = answer.question else { return nil }
        return .init(answer: answer, question: question, service: service)
    }
}

extension CalendarViewModel {
    func fetchData() async throws {
        let endMonth = Date()
        let startMonth = Date.January
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
                       days[dayIndex].isConsecutive = days[dayIndex].date >= firstAnswerDay &&  days[dayIndex].date <= endAnswerDay
                   }
                   let totalIcons = days.flatMap { $0.reflections?.reflections ?? []}.filter { $0.icon != nil}.count
                   months[monthIndex].days = days
                   months[monthIndex].iconCount = totalIcons
                   if months[monthIndex].date.isSameMonth(endMonth), let currentIndex = days.firstIndex(where: { $0.date.isSameDay(endMonth)}) {
                       months[monthIndex].moreDaysTogo = days.count - currentIndex
                   }
                }
            }
           self.months = months
        }
    }
    
   @MainActor
    func scrollToCurrentMonth() {
        let endMonth = Date()
        if let month = months.first(where: { $0.date.isSameMonth(endMonth)}) {
            currentMonth = month
            withAnimation(.easeInOut) {
                self.contentScrollPostion = month.id
                self.monthScrollPostion = month.id
            }
        }
    }
    
    @MainActor
    func didTapMonth(_ month: CalendarMonth) {
        withAnimation(.easeInOut) {
            self.contentScrollPostion = month.id
            self.monthScrollPostion = month.id
            currentMonth = month
        }
    }
}


extension CalendarViewModel {
    func generateMonthForYear(_ year: Int) async {
        let calendar = Calendar.current
        var component = DateComponents()
        component.year = year
        var calendarMonths: [CalendarMonth] = []
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
                            isConsecutive: false
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
                            isConsecutive: false
                        )
                    )
                }
            }
            let calendarMonth = CalendarMonth(date: monthDate, days: days, iconCount: 0, moreDaysTogo: 0)
            calendarMonths.append(calendarMonth)
        }
        await MainActor.run {
            self.months = calendarMonths
        }
    }
}
