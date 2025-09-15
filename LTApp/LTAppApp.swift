//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

@main
struct LTAppApp: App {
    @StateObject var coordinator: AppCoordinator
    
    init() {
        try! AppFont.registerFonts()
        let apiClient = ApiClient(environment: .dev)
        let authRepository = AuthRepository(apiClient: apiClient)
        _coordinator = StateObject(
            wrappedValue: AppCoordinator(
                appDataService: AppDataService(
                    authRepository: authRepository
                )
            )
        )
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environmentObject(coordinator)
    }
}
