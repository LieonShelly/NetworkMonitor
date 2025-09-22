//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

@MainActor
final class AppCoordinator: ObservableObject, @unchecked Sendable {
    @Published private(set) var root: AppRootType = .preHome
    
    private let appDataService: any AppDataWithAuthorizationServiceful
    
    init(appDataService: any AppDataWithAuthorizationServiceful) {
        self.appDataService = appDataService
    }
    
    func changeRoot(_ type: AppRootType) {
        root = type
    }
    
    func rootView() -> AnyView {
        switch root {
        case .preHome:
            return AnyView(PreHomeContentView())
        case .home:
            return AnyView(AppHomeRootView())
        }
    }
}


enum AppRootType {
    case preHome
    case home
}



enum AppRoute: Route {
    
}
