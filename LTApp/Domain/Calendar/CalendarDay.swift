//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

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
