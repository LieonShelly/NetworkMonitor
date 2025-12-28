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
    var isAbsent: Bool
    var reflections: DayReflections?
    
    init(date: Date, isCurrentMonth: Bool, isToday: Bool, isAbsent: Bool, reflections: DayReflections? = nil) {
        self.date = date
        self.isCurrentMonth = isCurrentMonth
        self.isToday = isToday
        self.reflections = reflections
        self.isAbsent = isAbsent
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
        entity.isAbsent = false
        return entity
    }
}

enum DayType {
    case past
    case today
    case future
}

enum MonthItemType {
    case normal
    case yearPlaceholder
}

struct CalendarMonth: Identifiable {
    let id = UUID()
    let date: Date
    var days: [CalendarDay]
    var iconCount: Int
    var moreDaysTogo: Int
    var isFuture: Bool {
        date.startOfDay() > Date().startOfDay()
    }
    var itemType: MonthItemType = .normal
    
    init(date: Date, days: [CalendarDay] = [], iconCount: Int = 0, moreDaysTogo: Int = 0, itemType: MonthItemType = .normal) {
        self.date = date
        self.days = days
        self.iconCount = iconCount
        self.moreDaysTogo = moreDaysTogo
        self.itemType = itemType
    }
    
    var isValildMonth: Bool {
        switch itemType {
        case .normal:
            return true
        case .yearPlaceholder:
            return false
        }
    }
}
