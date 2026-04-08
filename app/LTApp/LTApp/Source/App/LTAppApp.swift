//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent

@main
struct LTAppApp: App {
    @StateObject var coordinator: AppCoordinator
    @StateObject var homeCoordinator: HomeCoordinator
    @StateObject var preHomeCoordinator: PreHomeCoordinator
    @Namespace var dripleTransition
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) var scenePhase
    init() {
        let appCoordinator = AppCoordinator()
        _coordinator = StateObject(
            wrappedValue: appCoordinator
        )
        _homeCoordinator = StateObject(wrappedValue: HomeCoordinator(
            appDataService: appCoordinator.appDataService,
            notificationHandler: appCoordinator.notificationHandler)
        )
        _preHomeCoordinator = StateObject(wrappedValue: PreHomeCoordinator(appDataService: appCoordinator.appDataService))
        appDelegate.appCoordinator = appCoordinator
    }
    
    var body: some Scene {
        WindowGroup {
            TestView()// coordinator.rootView()
        }
        .environmentObject(homeCoordinator)
        .environmentObject(coordinator)
        .environmentObject(preHomeCoordinator)
        .onChange(of: scenePhase) { oldValue, newValue in
            if newValue == .active {
                UNUserNotificationCenter.current().setBadgeCount(0)
            }
        }
    }
}


struct TestView: View {
    @State var colorRenderer = ColorOverlayRenderer.shared
    
    var body: some View {
        VStack {
            Image(.pinnedStar)
                .background {
                    Image(uiImage: colorRenderer.applyOverlay(to: UIImage(resource: .pinnedStar), color: UIColor.red)!)
                        .offset()
                }
            
            Image(.dripper)
                .background {
                    Image(uiImage: colorRenderer.applyOverlay(to: UIImage(resource: .dripper), color: UIColor.red)!)
                        .offset()
                }
        }
    }
}
