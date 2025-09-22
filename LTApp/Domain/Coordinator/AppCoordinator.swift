//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

@MainActor
final class AppCoordinator: ObservableObject, @unchecked Sendable {
    @Published var root: AppRootType = .preHome

    var children: [any Coordinator] = []
    
    private let appDataService: any AppDataWithAuthorizationServiceful
    
    init(appDataService: any AppDataWithAuthorizationServiceful) {
        self.appDataService = appDataService
    }
    
    func changeRoot(_ type: AppRootType) {
        root = type
    }
    
    func rootView(_ type: AppRootType) -> AnyView {
        switch root {
        case .preHome:
            return AnyView(PreHomeContentView())
        case .home:
            return AnyView(AppHomeRootView())
        }
    }
}

enum AppRoute: Route {
    
}


enum AppRootType {
    case preHome
    case home
}
