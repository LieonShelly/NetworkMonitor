//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date
    let isCurrentMonth: Bool
    let isToday: Bool
    var reflections: DayReflections?
    
    init(date: Date, isCurrentMonth: Bool, isToday: Bool, reflections: DayReflections? = nil) {
        self.date = date
        self.isCurrentMonth = isCurrentMonth
        self.isToday = isToday
        self.reflections = reflections
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
    let days: [CalendarDay]
}
