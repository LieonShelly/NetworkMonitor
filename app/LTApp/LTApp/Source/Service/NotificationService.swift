//
//  NotificationService.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/17.
//

import UserNotifications

class NotificationService {
    
    func requestPermission() async throws -> Bool {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
    }
}
