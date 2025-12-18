//
//  NotificationHandler.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/18.
//

import Combine
import Foundation

@MainActor
class NotificationHandler: @preconcurrency NotificationHandlingType, @unchecked Sendable {
    
    var topic: AnyPublisher<NotificationTopic, Never> {
        topicSubject
            .filter { $0 != nil }
            .map { $0! }
            .eraseToAnyPublisher()
    }
    
    deinit {
        print("NotificationHandler-deinit")
    }
    
    private let topicSubject: CurrentValueSubject<NotificationTopic?, Never> = .init(nil)
    
    func didRecieveNotification(_ userInfo: [String : any Sendable]) async {
        guard let aps = userInfo["aps"] as? [String: Any] else { return }
        guard let customPayload = aps["custom"] as? [String: Any] else { return }
        guard let data = try? JSONSerialization.data(withJSONObject: customPayload) else {
            return
        }
        guard let payload = try? JSONDecoder().decode(NotificationPayload.self, from: data) else {
            return
        }
        topicSubject.send(payload.topic)
    }
}
