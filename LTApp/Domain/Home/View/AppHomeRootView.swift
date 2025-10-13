//
//  LTApp, This code is protected by intellectual property rights.
//


import SwiftUI

struct AppHomeRootView: View {
    @EnvironmentObject var coordinator: HomeCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            EmptyView()
                .toolbarVisibility(.hidden, for: .navigationBar)
                .navigationDestination(for: HomeRoute.self) { path in
                    coordinator.build(path)
                }
                .navigationDestination(for: PreHomeRoute.self) { path  in
                    coordinator.build(path)
                }
        }
        .task {
            coordinator.start()
        }
    }
}
