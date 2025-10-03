//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

class CalendarViewModel: ObservableObject {
    @Published var days: [CalendarDay] = []
    @Published var weekdays: [String] = ["S", "M", "T", "W", "T", "F", "S"]
    let itemSize: CGSize = .init(width: 30, height: 30)
    
    init() {
        generateDaysForYear(2025)
    }
    
    func generateDaysForYear(_ year: Int) {
        let calendar = Calendar.current
        var component = DateComponents()
        component.year = year
        component.month = 1
        if let date = calendar.date(from: component) {
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
    
    
}
    
