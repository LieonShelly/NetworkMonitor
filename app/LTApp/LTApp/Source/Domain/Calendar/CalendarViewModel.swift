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
    @MainActor @Published var currentMonth: Date?
    @MainActor @Published var scrollPostion: UUID? = nil
    @MainActor @Published var todayUpdatingIcon: IconData?
    @MainActor @Published var selectedDay: CalendarDay?
    @MainActor @Published var showTodayAnswerView: Bool = false
    @MainActor @Published var months: [CalendarMonth] = []
    
    let itemSize: CGSize = .init(width: 30, height: 30)
    
    private let service: any AppDataWithAuthorizationServiceful
    
    init(service: any AppDataWithAuthorizationServiceful) {
        self.service = service
    }
    
    @MainActor
    func goNextMonth() {
        guard let currentMonth else { return }
        let calendar = Calendar.current
        if let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
           if let month = months.first(where: { $0.date.isSameMonth(nextMonth)}) {
               withAnimation(.easeInOut) {
                   self.scrollPostion = month.id
               }
           }
        }
    }
    
    @MainActor
    func goPreviousMonth() {
        guard let currentMonth else { return }
        let calendar = Calendar.current
        if let nextMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
           if let month = months.first(where: { $0.date.isSameMonth(nextMonth)}) {
               withAnimation(.easeInOut) {
                   self.scrollPostion = month.id
               }
              
            }
        }
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
            for reflection in reflections {
                for monthIndex in 0 ..< months.count {
                    var days = months[monthIndex].days
                    if let index = days.firstIndex(where: { $0.date.isSameDay(reflection.day)}) {
                        let newDay = days[index].copyWith(reflection)
                        days[index] = newDay
                    }
                    months[monthIndex].days = days
                }
            }
           self.months = months
        }
    }
    
   @MainActor
    func scrollToCurrentMonth() {
        let endMonth = Date()
        if let month = months.first(where: { $0.date.isSameMonth(endMonth)}) {
            currentMonth = endMonth
            withAnimation(.easeInOut) {
                self.scrollPostion = month.id
            }
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
                            isToday: false
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
                            isToday: calendar.isDateInToday(date)
                        )
                    )
                }
            }
            let calendarMonth = CalendarMonth(date: monthDate, days: days)
            calendarMonths.append(calendarMonth)
        }
        await MainActor.run {
            self.months = calendarMonths
        }
    }
}
