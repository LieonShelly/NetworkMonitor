//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

enum DayType {
    case past
    case today
    case future
}

struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date
    let isCurrentMonth: Bool
    let isToday: Bool
    
    var dayType: DayType {
        let today = Date()
        if date.startOfDay() < today.startOfDay() {
            return .past
        } else if date.startOfDay() == today.startOfDay() {
            return .today
        } else {
            return .future
        }
    }
}

extension Date {
    
    func endOfDay() -> Date {
        let calendar = Calendar.current
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay()),
              let endOfDay = calendar.date(byAdding: .second, value: -1, to: nextDay) else {
            return Date()
        }
        return endOfDay
    }
    
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self))) ?? Date()
    }
    
    func startOfDay() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day],
                                                                           from: Calendar.current.startOfDay(for: self))) ?? Date()
    }
}

struct CalendarMonth: Identifiable {
    let id = UUID()
    let date: Date
    let days: [CalendarDay]
}

class CalendarViewModel: ObservableObject {
    @Published var days: [CalendarDay] = []
    @Published var weekdays: [String] = ["S", "M", "T", "W", "T", "F", "S"]
    @Published var monthList: [CalendarMonth] = []
    let itemSize: CGSize = .init(width: 30, height: 30)
    
    init() {
        monthList = generateMothList(for: 2025)
    }
    
    func generateDays(for moth: Date) -> [CalendarDay] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: moth)!
        let components = calendar.dateComponents([.year, .month], from: moth)
        let firstDay = calendar.date(from: components)!
        var days: [CalendarDay] = []
        let weekdayOffset = calendar.component(.weekday, from: firstDay) - calendar.firstWeekday
        let totalDays = range.count
        
        for i in 0 ..< weekdayOffset {
            days.append(
                CalendarDay(
                    date: calendar.date(byAdding: .day, value: -weekdayOffset + i, to: firstDay)!,
                    isCurrentMonth: false,
                    isToday: false
                )
            )
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
        
        let maxCounts: Int = 42
        while days.count - maxCounts != 0 {
            let date = calendar.date(byAdding: .day, value: 1, to: days.last!.date)!
            days.append(
                CalendarDay(
                    date: date,
                    isCurrentMonth: false,
                    isToday: false
                )
            )
        }
        return days
    }
    
    
    func generateMothList(for year: Int) -> [CalendarMonth] {
        let calendar = Calendar.current
        var monthList: [CalendarMonth] = []
        for month in 1...12 {
            var component = DateComponents()
            component.year = year
            component.month = month
            guard let date = calendar.date(from: component) else { continue }
            monthList.append(CalendarMonth(date: date, days: generateDays(for: date)))
        }
        return monthList
    }
    
}
    
