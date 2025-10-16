//
//  LTApp, This code is protected by intellectual property rights.
//


import SwiftUI

struct AppHomeRootView: View {
    @EnvironmentObject var coordinator: HomeCoordinator
    @StateObject var viewModel: AppHomeRootViewModel
    @Namespace var animationSpace
    
    init(viewModel: AppHomeRootViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
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
        .overlay(content: {
            if viewModel.showOverlay {
                FirstQuestionSubmittedView(
                    data: viewModel.overLayData,
                    showCalendarDripple: $viewModel.showCalendarDripple
                )
            }
        })
        
        .environment(\.drippleAnimationSpace, animationSpace)
        .environment(\.showCalendarDripple, viewModel.showCalendarDripple)
        .task {
            coordinator.start()
        }
    }
}

private struct DrippleNamespaceKey: EnvironmentKey {
    static let defaultValue: Namespace.ID? = nil
}

extension EnvironmentValues {
    var drippleAnimationSpace: Namespace.ID? {
        get { self[DrippleNamespaceKey.self] }
        set { self[DrippleNamespaceKey.self] = newValue }
    }
    
    var showCalendarDripple: Bool {
        get { self[DrippleShowNamespaceKey.self] }
        set { self[DrippleShowNamespaceKey.self] = newValue }
    }
}



private struct DrippleShowNamespaceKey: EnvironmentKey {
    static let defaultValue: Bool = false
}
