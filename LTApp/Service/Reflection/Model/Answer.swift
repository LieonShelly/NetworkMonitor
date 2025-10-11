//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct Answer: Sendable {
    let id: String
    let content: String
}


public struct DayReflections: Sendable {
    let day: Date
    let reflections: [Answer]
}
