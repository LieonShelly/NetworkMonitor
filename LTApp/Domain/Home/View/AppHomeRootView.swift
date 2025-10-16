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
                    data: viewModel.overLayData
                )
            }
        })
        .task {
            coordinator.start()
            coordinator.generateDripleTransitionData(animationSpace)
        }
    }
}

struct DrippleTransitionData {
    var drippleAnimationSpace: Namespace.ID
    var showCalendarDripple: Bool
    var showDrippleClose: Bool
    var date: Date?
}

