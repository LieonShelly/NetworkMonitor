//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Combine

enum NotificationTopic: String, Codable {
    case iconFinished = "stamp_reveal"
    case todayQuestion = "today_spark_unanswered"
    case reportReady = "weekly_report"
    case thread = "stamp_thread"
    case calendar = "daily_calendar"
}

struct NotificationPayload: Codable {
    var topic: NotificationTopic
    var data: String?
}

protocol NotificationHandlingType: Sendable {
    var payload: AnyPublisher<NotificationPayload, Never> { get }
    
    func appDidBecomeActive()
    func didRecieveNotification(_ userInfo: [String: any Sendable]) async
}
