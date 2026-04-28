//
//  NotificationTopic.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/18.
//

import Combine

enum NotificationTopic: String, Codable {
    case iconFinished = "icon_finished"
    case todayQuestion = "today_question"
    case reportReady = "report_ready"
}

struct NotificationPayload: Codable {
    var topic: NotificationTopic
    var data: String?
}

protocol NotificationHandlingType: Sendable {
    var payload: AnyPublisher<NotificationPayload, Never> { get }
    
    func didRecieveNotification(_ userInfo: [String: any Sendable]) async
}
