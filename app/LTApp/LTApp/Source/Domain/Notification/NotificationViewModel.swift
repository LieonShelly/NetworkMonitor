//
//  NotificationViewModel.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/17.
//

import SwiftUI
import UIComponent
import UserNotifications

class NotificationViewModel: ObservableObject, @unchecked Sendable {
    let appService: any AppDataWithAuthorizationServiceful
    
    init(appService: any AppDataWithAuthorizationServiceful) {
        self.appService = appService
    }
    
    func requestPermission() async throws -> Bool {
        return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
    }
    
    func didOpen() async {
        await appService.notificationFlagUseCase.save()
    }
    
    deinit {
        debugPrint("NotificationViewModel-deinit")
    }
}
