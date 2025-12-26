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
    
    func monthDesc(isShort: Bool = true) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = isShort ? "MMM" : "MMMM"
        formatter.locale = Locale.current
        let month = formatter.string(from: self)
        return month
    }
    
    func dayDesc() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: self)
    }
    
    func yearDesc() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: self)
    }
    
    var monthDayDesc: String {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "MMMM d"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
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
    
    func isSameDay(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let component1 = calendar.dateComponents([.year, .month, .day], from: self)
        let component2 = calendar.dateComponents([.year, .month, .day], from: date)
        return component1.year == component2.year && component1.month == component2.month && component1.day == component2.day
    }
    
    func isPreviousMonth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let component1 = calendar.dateComponents([.year, .month], from: self)
        let component2 = calendar.dateComponents([.year, .month], from: date)
        return component1.year == component2.year && component1.month! < component2.month! || component1.year! < component2.year!
    }
    
    func isNextMonth(_ date: Date) -> Bool {
        !isPreviousMonth(date)
    }
    
    static var January: Date {
        var calendar = Calendar.current
        calendar.timeZone = .current
        calendar.locale = Locale(identifier: "en_US_POSIX")
        let currentYear = Date()
        var component = calendar.dateComponents([.year], from: currentYear)
        var firstDayComponent = DateComponents()
        firstDayComponent.year = component.year
        component.month = 1
        component.day = 1
        component.hour = 0
        component.minute = 0
        component.second = 0 
        return calendar.date(from: firstDayComponent) ?? currentYear
    }
    
    var yyyymmdd: String {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "YYYY-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
    
    func ordinalSuffix(for day: Int) -> String {
        switch day {
        case 1, 21, 31:
            return "st"
        case 2, 22:
            return "nd"
        case 3, 23:
            return "rd"
        default:
            return "th"
        }
    }

    func formatDateToEnglishStyle(timeZone: TimeZone = .current, locale: Locale = Locale(identifier: "en_US")) -> String {
        let date = self
        let monthYearFormatter = DateFormatter()
        monthYearFormatter.dateFormat = "MMMM, yyyy"
        monthYearFormatter.timeZone = timeZone
        monthYearFormatter.locale = locale
        
        let monthYearString = monthYearFormatter.string(from: date)
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        calendar.locale = locale
        let day = calendar.component(.day, from: date)
        
        let ordinalDay = "\(day)\(ordinalSuffix(for: day))"
        let parts = monthYearString.components(separatedBy: ", ")
        return "\(parts[0]) \(ordinalDay), \(parts[1])"
    }
}

struct AppDateFormatter {
   static var yyyymmdd: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "YYYY-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
    
    static var ymdhsm: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "YYYY-MM-dd hh:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
    
}
