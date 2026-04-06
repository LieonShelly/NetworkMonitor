//
//  LTApp, This code is protected by intellectual property rights.
//


import SwiftUI
import UIComponent

struct AppHomeRootView: View {
    @EnvironmentObject var coordinator: HomeCoordinator
    @StateObject var viewModel: AppHomeRootViewModel
    @Namespace var animationSpace
    @State private var notificationVisible = false
    
    init(viewModel: AppHomeRootViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            AppColor.backgroundPage.ignoresSafeArea()
            
            NavigationStack(path: $coordinator.path) {
                EmptyView()
                    .toolbarVisibility(.hidden, for: .navigationBar)
                    .navigationDestination(for: HomeRoute.self) { path in
                        coordinator.build(path)
                    }
                    .navigationDestination(for: PreHomeRoute.self) { path  in
                        coordinator.build(path)
                    }
                    .navigationDestination(for: UserRoute.self) { path  in
                        coordinator.build(path)
                    }
            }
            .transaction { transaction in
                if viewModel.showNotificationView {
                    transaction.disablesAnimations = true
                }
            }
            .opacity(viewModel.showNotificationView ? 0 : 1)
            .task {
                coordinator.start()
            }
            
            if notificationVisible {
                OnboardingNotificationView(viewModel: .init(appService: coordinator.appDataService)) {
                    withAnimation(.easeInOut) {
                        notificationVisible = false
                    }
                    viewModel.showNotificationView = false
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .task {
            if viewModel.showNotificationView {
                withAnimation(.easeInOut(duration: 0.5)) {
                    notificationVisible = true
                }
            }
        }
    }
}

struct DrippleTransitionData {
    var drippleAnimationSpace: Namespace.ID
    var showCalendarDripple: Bool
    var showDrippleClose: Bool
    var date: Date
}

