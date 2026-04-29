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
import GoogleSignIn
import Common

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var appCoordinator: AppCoordinator!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        try! AppFont.registerFonts()
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        return true
    }
    
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
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
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime]
            formatter.timeZone = .current
            let timestamp = formatter.string(from: Date())
            try? await appCoordinator.appDataService.saveTimezoneUseCase.execute(timestamp: timestamp)
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        print("注册远程通知失败: \(error)")
    }
    
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var handled: Bool
         handled = GIDSignIn.sharedInstance.handle(url)
         if handled {
           return true
         }
         return false
    }
}
