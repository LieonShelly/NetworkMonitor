//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

extension Date {
    
    func endOfDay() -> Date {
        let calendar = AppCalendar.current
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay()),
              let endOfDay = calendar.date(byAdding: .second, value: -1, to: nextDay) else {
            return Date()
        }
        return endOfDay
    }
    
    func startOfMonth() -> Date {
        let calendar = AppCalendar.current
        return calendar.date(from: calendar.dateComponents([.year, .month], from: calendar.startOfDay(for: self))) ?? Date()
    }
    
    func endOfMonth() -> Date {
        let calendar = AppCalendar.current
        let start = startOfMonth()
        return calendar.date(byAdding: DateComponents(month: 1, day:  -1), to: start) ?? Date()
    }
    
    func startOfDay() -> Date {
        return AppCalendar.current.date(from: AppCalendar.current.dateComponents([.year, .month, .day],
                                                                           from: Calendar.current.startOfDay(for: self))) ?? Date()
    }
    
    func monthDesc(isShort: Bool = true) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = isShort ? "MMM" : "MMMM"
        formatter.locale = AppCalendar.locale
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
        formatter.timeZone = AppCalendar.timeZone
        formatter.dateFormat = "MMMM d"
        formatter.locale = AppCalendar.locale
        return formatter.string(from: self)
    }
    
    var dayMonthDesc: String {
        let formatter = DateFormatter()
        formatter.timeZone = AppCalendar.timeZone
        formatter.dateFormat = "d MMMM"
        formatter.locale = AppCalendar.locale
        return formatter.string(from: self)
    }
    
    var isTheFirstDayInMonth: Bool {
        let calendar = AppCalendar.current
        let date = self
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let firstDay = calendar.date(from: components) else { return false }
        let isFirstDay = calendar.isDate(date, inSameDayAs: firstDay)
        return isFirstDay
    }
    
    func isSameMonth(_ date: Date) -> Bool {
        let calendar = AppCalendar.current
        return calendar.isDate(date, equalTo: self, toGranularity: .month)
    }
    
    func isSameDay(_ date: Date) -> Bool {
        let calendar = AppCalendar.current
        return calendar.isDate(date, equalTo: self, toGranularity: .day)
    }
    
    var yyyymmdd: String {
        let formatter = DateFormatter()
        formatter.timeZone = AppCalendar.timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = AppCalendar.locale
        return formatter.string(from: self)
    }
    
    /// e.g. "22 - 28 Mar"
    var weekRangeDesc: String {
        let calendar = AppCalendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: self) else {
            return yyyymmdd
        }
        let start = weekInterval.start
        let end = calendar.date(byAdding: .day, value: -1, to: weekInterval.end) ?? weekInterval.end
        
        let startDay = calendar.component(.day, from: start)
        let endDay = calendar.component(.day, from: end)
        let endMonth = end.monthDesc(isShort: true)
        
        if calendar.isDate(start, equalTo: end, toGranularity: .month) {
            return "\(startDay) - \(endDay) \(endMonth)"
        } else {
            let startMonth = start.monthDesc(isShort: true)
            return "\(startDay) \(startMonth) - \(endDay) \(endMonth)"
        }
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

    func formatDateToEnglishStyle(timeZone: TimeZone = .current, locale: Locale = AppCalendar.locale) -> String {
        let date = self
        let monthYearFormatter = DateFormatter()
        monthYearFormatter.dateFormat = "MMMM, yyyy"
        monthYearFormatter.timeZone = timeZone
        monthYearFormatter.locale = locale
        
        let monthYearString = monthYearFormatter.string(from: date)
        var calendar = AppCalendar.current
        calendar.timeZone = timeZone
        calendar.locale = locale
        let day = calendar.component(.day, from: date)
        
        let ordinalDay = "\(day)\(ordinalSuffix(for: day))"
        let parts = monthYearString.components(separatedBy: ", ")
        return "\(parts[0]) \(ordinalDay), \(parts[1])"
    }
    
    
    static var isWeekDay: Bool {
        let calendar = AppCalendar.current
        let now = Date()
        let weekday = calendar.component(.weekday, from: now)
        return weekday == 1
    }
}

struct AppDateFormatter {
   static var yyyymmdd: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = AppCalendar.timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = AppCalendar.locale
        return formatter
    }
    
    static var ymdhsm: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = AppCalendar.timeZone
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = AppCalendar.locale
        return formatter
    }
    
    static var iso8601: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }
    
}

struct AppCalendar {
   static var current: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        calendar.locale = locale
        return calendar
    }
    
    static var timeZone: TimeZone {
        .autoupdatingCurrent
    }
    
    static var locale: Locale {
        .autoupdatingCurrent
    }
}
