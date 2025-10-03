//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

@main
struct LTAppApp: App {
    @StateObject var coordinator: AppCoordinator
    @StateObject var homeCoordinator: HomeCoordinator
    @StateObject var preHomeCoordinator: PreHomeCoordinator
    
    init() {
        try! AppFont.registerFonts()
        
        let appCoordinator = AppCoordinator()
        _coordinator = StateObject(
            wrappedValue: appCoordinator
        )
        _homeCoordinator = StateObject(wrappedValue: HomeCoordinator(appDataService: appCoordinator.appDataService))
        
        _preHomeCoordinator = StateObject(wrappedValue: PreHomeCoordinator(appDataService: appCoordinator.appDataService))
    }
    
    var body: some Scene {
        WindowGroup {
            coordinator.rootView()
        }
        .environmentObject(homeCoordinator)
        .environmentObject(coordinator)
        .environmentObject(preHomeCoordinator)
    }
}
