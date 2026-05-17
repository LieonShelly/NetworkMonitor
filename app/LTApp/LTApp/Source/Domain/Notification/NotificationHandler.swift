//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import Combine
import Foundation

@MainActor
class NotificationHandler: @preconcurrency NotificationHandlingType, @unchecked Sendable {
    
    var payload: AnyPublisher<NotificationPayload, Never> {
        payloadSubject
            .filter { $0 != nil }
            .map { $0! }
            .eraseToAnyPublisher()
    }
    
    deinit {
        print("NotificationHandler-deinit")
    }
    
    private let payloadSubject: CurrentValueSubject<NotificationPayload?, Never> = .init(nil)
    private var hasAppBecomeActive = false
    
    func appDidBecomeActive() {
        hasAppBecomeActive = true
    }
    
    func didRecieveNotification(_ userInfo: [String : any Sendable]) async {
        guard !hasAppBecomeActive else { return }
        hasAppBecomeActive = true
        guard let customPayload = userInfo["custom"] as? [String: Any] else { return }
        guard let data = try? JSONSerialization.data(withJSONObject: customPayload) else {
            return
        }
        guard let payload = try? JSONDecoder().decode(NotificationPayload.self, from: data) else {
            return
        }
        payloadSubject.send(payload)
    }
}
