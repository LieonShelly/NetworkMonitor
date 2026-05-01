//
//  NotificationTopic.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/18.
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
    
    func didRecieveNotification(_ userInfo: [String: any Sendable]) async
}
