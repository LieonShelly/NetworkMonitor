//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

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
    
    func monthDesc() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        formatter.locale = Locale.current
        let month = formatter.string(from: self)
        return month
    }
    
    var isTheFirstDayInMonth: Bool {
        let calendar = Calendar.current
        let date = self
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let firstDay = calendar.date(from: components) else { return false }
        let isFirstDay = calendar.isDate(date, inSameDayAs: firstDay)
        return isFirstDay
    }
    
    func isSameMonth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let component1 = calendar.dateComponents([.year, .month], from: self)
        let component2 = calendar.dateComponents([.year, .month], from: date)
        return component1.year == component2.year && component1.month == component2.month
    }
}
