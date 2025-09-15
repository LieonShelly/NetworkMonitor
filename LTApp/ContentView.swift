//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            EmptyView()
                .toolbarVisibility(.hidden, for: .navigationBar)
                .navigationDestination(for: AppRoute.self) { path in
                    coordinator.build(path)
                }
        }
        .onAppear {
            coordinator.start()
        }
    }
}
