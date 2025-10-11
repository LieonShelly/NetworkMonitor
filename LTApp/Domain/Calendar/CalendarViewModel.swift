//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation
import SwiftUI

final class CalendarViewModel: ObservableObject, @unchecked Sendable {
    @Published var days: [CalendarDay] = []
    @Published var weekdays: [String] = ["S", "M", "T", "W", "T", "F", "S"]
    @Published var currentMonth: Date?
    @Published var scrollPostion: UUID? = nil

    let itemSize: CGSize = .init(width: 30, height: 30)
    
    private let service: any AppDataWithAuthorizationServiceful
    
    init(service: any AppDataWithAuthorizationServiceful) {
        self.service = service
        generateDaysForYear(2025)
        generateDaysForYear(2026)
        generateDaysForYear(2027)
    }
    
    func generateDaysForYear(_ year: Int) {
        let calendar = Calendar.current
        var component = DateComponents()
        component.year = year
        component.month = 1
        if let date = calendar.date(from: component) {
            self.currentMonth = date
            generateDays(for: date, needWeekdayOffset: true)
        }
        
        for month in 2...12 {
            component.year = year
            component.month = month
            guard let date = calendar.date(from: component) else { continue }
            generateDays(for: date, needWeekdayOffset: false)
        }
    }
    
    func generateDays(for moth: Date, needWeekdayOffset: Bool = true) {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: moth)!
        let components = calendar.dateComponents([.year, .month], from: moth)
        let firstDay = calendar.date(from: components)!
        var days: [CalendarDay] = []
        let weekdayOffset = calendar.component(.weekday, from: firstDay) - calendar.firstWeekday
        let totalDays = range.count
        if needWeekdayOffset {
            for i in 0 ..< weekdayOffset {
                days.append(
                    CalendarDay(
                        date: calendar.date(byAdding: .day, value: -weekdayOffset + i, to: firstDay)!,
                        isCurrentMonth: false,
                        isToday: false
                    )
                )
            }
        }
        
        for day in 1...totalDays {
            let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay)!
            days.append(
                CalendarDay(
                    date: date,
                    isCurrentMonth: true,
                    isToday: calendar.isDateInToday(date)
                )
            )
        }
        self.days.append(contentsOf: days)
    }
    
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
    func fetchData() async throws {
        let endMonth = Date()
        let startMonth = Date.January
        let reflections = try await service.calendarReflectionsUseCase.execute(
            startMonth: startMonth,
            endMonth: endMonth
        )
        print(reflections)
    }
}
