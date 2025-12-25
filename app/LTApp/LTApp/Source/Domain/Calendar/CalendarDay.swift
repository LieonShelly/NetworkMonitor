//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

struct WeekDay: Identifiable {
    let id = UUID()
    let title: String
    
    init(title: String) {
        self.title = title
    }
}

struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date
    let isCurrentMonth: Bool
    let isToday: Bool
    var isConsecutive: Bool
    var reflections: DayReflections?
    
    init(date: Date, isCurrentMonth: Bool, isToday: Bool, isConsecutive: Bool, reflections: DayReflections? = nil) {
        self.date = date
        self.isCurrentMonth = isCurrentMonth
        self.isToday = isToday
        self.reflections = reflections
        self.isConsecutive = isConsecutive
    }
    
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
    
    func copyWith(_ reflections: DayReflections) -> CalendarDay{
        var entity = self
        entity.reflections = reflections
        entity.isConsecutive = true
        return entity
    }
}

enum DayType {
    case past
    case today
    case future
}

struct CalendarMonth: Identifiable {
    let id = UUID()
    let date: Date
    var days: [CalendarDay]
}
