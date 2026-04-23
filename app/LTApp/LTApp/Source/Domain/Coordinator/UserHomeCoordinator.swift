//
//  UserHomeCoordinator.swift
//  LTApp
//
//  Created by Renjun Li on 2026/2/4.
//

import SwiftUI

@MainActor
final class UserHomeCoordinator: Coordinator, ObservableObject, Sendable {
    @Published var path: NavigationPath = .init()

    var children: [any Coordinator] = []
    private let appDataService: any AppDataWithAuthorizationServiceful
    private let notificationHandler: any NotificationHandlingType
    
    init(appDataService: any AppDataWithAuthorizationServiceful, notificationHandler: any NotificationHandlingType) {
        self.appDataService = appDataService
        self.notificationHandler = notificationHandler
    }
    
    func build(_ route: any Route) -> AnyView? {
        guard let route = route as? UserRoute else {
            return buildChild(route: route)
        }
        switch route {
        case .qustionOfTodaySettings:
            return AnyView(QuestionOfTodaySettingView(viewModel: .init(dataService: appDataService)))
        case .aboutMeSetting:
            return AnyView(AboutMeView(viewModel: .init(dataService: appDataService)))
        case .personaSetting:
            return AnyView(PersonaSettingView(viewModel: .init(dataService: self.appDataService)))
        case .reminderSetting:
            return AnyView(ReminderSettingView(viewModel: .init(dataService: self.appDataService)))
        }
    }
    
    func start() {
        path = .init()
    }
}

enum UserRoute: Route {
    case aboutMeSetting
    case personaSetting
    case qustionOfTodaySettings
    case reminderSetting
}
