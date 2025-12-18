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
}

struct NotificationPayload: Codable {
    var topic: NotificationTopic
}

protocol NotificationHandlingType: Sendable {
    var topic: AnyPublisher<NotificationTopic, Never> { get }
    
    func didRecieveNotification(_ userInfo: [String: any Sendable]) async
}
