//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import UserNotifications

class NotificationService {
    
    func requestPermission() async throws -> Bool {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
    }
}
