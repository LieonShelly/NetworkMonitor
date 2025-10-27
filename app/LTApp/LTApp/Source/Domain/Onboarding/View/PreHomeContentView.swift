//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct PreHomeContentView: View {
    @EnvironmentObject var coordinator: PreHomeCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            EmptyView()
                .toolbarVisibility(.hidden, for: .navigationBar)
                .navigationDestination(for: PreHomeRoute.self) { path in
                    coordinator.build(path)
                }
        }
        .onAppear {
            coordinator.start()
        }
    }
}
