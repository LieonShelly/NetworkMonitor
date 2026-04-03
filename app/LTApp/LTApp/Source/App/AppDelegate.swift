//
//  NotificationService.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/17.
//

import Foundation
import UserNotifications
import UIKit
import UIComponent

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var appCoordinator: AppCoordinator!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        try! AppFont.registerFonts()
        print(UIFont.familyNames)
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        return true
    }
    
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.notification.request.identifier
        print("用户点击了通知，ID: \(identifier)")
        print(response.notification.request.content.userInfo)
        guard let userInfo = response.notification.request.content.userInfo as? [String: any Sendable] else {
            return  completionHandler()
        }
        Task { @MainActor in
           await appCoordinator.notificationHandler.didRecieveNotification(userInfo)
        }
        completionHandler()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        Task {
            try? await appCoordinator.appDataService.postNotificationDeviceTokenUseCase.execute(deviceToken: token)
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        print("注册远程通知失败: \(error)")
    }
}
