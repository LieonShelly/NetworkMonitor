//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation
import SwiftUI

final class CalendarViewModel: ObservableObject, @unchecked Sendable {
    @MainActor @Published var days: [CalendarDay] = []
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

    let itemSize: CGSize = .init(width: 30, height: 30)
    
    private let service: any AppDataWithAuthorizationServiceful
    
    init(service: any AppDataWithAuthorizationServiceful) {
        self.service = service
    }
    
    func generateDaysForYear(_ year: Int, skipHeadder: Bool = false) async {
        let calendar = Calendar.current
        var component = DateComponents()
        component.year = year
        component.month = 1
        if let date = calendar.date(from: component) {
          await  generateDays(for: date, needWeekdayOffset: !skipHeadder)
        }
        
        for month in 2...12 {
            component.year = year
            component.month = month
            guard let date = calendar.date(from: component) else { continue }
           await generateDays(for: date, needWeekdayOffset: false)
        }
    }
    
    func generateDays(for moth: Date, needWeekdayOffset: Bool = true) async {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: moth) else {
            return
        }
        let components = calendar.dateComponents([.year, .month], from: moth)
        guard let firstDay = calendar.date(from: components) else {
             return
        }
        var days: [CalendarDay] = []
        let weekdayOffset = calendar.component(.weekday, from: firstDay) - calendar.firstWeekday
        let totalDays = range.count
        if needWeekdayOffset {
            guard weekdayOffset >= 0 else { return }
            for i in 0 ..< weekdayOffset {
                if let date = calendar.date(byAdding: .day, value: -weekdayOffset + i, to: firstDay) {
                    days.append(
                        CalendarDay(
                            date: date,
                            isCurrentMonth: false,
                            isToday: false
                        )
                    )
                }
            }
        }
        guard totalDays >= 1 else { return }
        for day in 1...totalDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(
                    CalendarDay(
                        date: date,
                        isCurrentMonth: true,
                        isToday: calendar.isDateInToday(date)
                    )
                )
            }
        }
        await MainActor.run {
            self.days.append(contentsOf: days)
        }
    }
    
    @MainActor
    func goNextMonth() {
        guard let currentMonth else { return }
        let calendar = Calendar.current
        if let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
           if let day = days.first(where: { $0.date.isSameMonth(nextMonth)}) {
               withAnimation(.easeInOut) {
                   self.scrollPostion = day.id
               }
           }
        }
    }
    
    @MainActor
    func goPreviousMonth() {
        guard let currentMonth else { return }
        let calendar = Calendar.current
        if let nextMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
           if let day = days.first(where: { $0.date.isSameMonth(nextMonth)}) {
               withAnimation(.easeInOut) {
                   self.scrollPostion = day.id
               }
              
            }
        }
    }
}

extension CalendarViewModel {
    func generateDay() async {
        await generateDaysForYear(2023, skipHeadder: false)
        for year in 2024 ... 2030 {
            await generateDaysForYear(year, skipHeadder: true)
        }
    }
    
    func fetchData() async throws {
        let endMonth = Date()
        let startMonth = Date.January
        let reflections = try await service.calendarReflectionsUseCase.execute(
            startMonth: startMonth,
            endMonth: endMonth
        )
       await MainActor.run {
            for reflection in reflections {
                guard let index = days.firstIndex(where: { $0.date.isSameDay(reflection.day)}) else { continue }
                let newDay = days[index].copyWith(reflection)
                days[index] = newDay
            }
           
           if let day = days.first(where: { $0.date.isSameMonth(endMonth)}) {
               currentMonth = endMonth
               withAnimation(.easeInOut) {
                   self.scrollPostion = day.id
               }
           }
        }
    }
}
