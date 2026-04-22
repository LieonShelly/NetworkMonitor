//
//  LTApp, This code is protected by intellectual property rights.
//
import SwiftUI
import UIComponent


struct AppHomeView: View {
    @StateObject var viewModel: AppHomeViewModel
    @StateObject private var tabbarVisibility = TabbarVisibility()
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    @State var showPage: Bool = false
    @State var subPagePrensented: Bool = false
    
    init(viewModel: AppHomeViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        GeometryReader { proxy in
            homeView(proxy)
        }
        .environmentObject(tabbarVisibility)
        .innerPageRoute($viewModel.subPageRoute)
    }
    
    fileprivate func scrollContentView() -> AppScrollContentView {
        return AppScrollContentView(
            viewModel: viewModel.contentViewModel,
            addAction: { questions in
                viewModel.pushToAddTodayAnsnwer(questions)
            },
            onTapAnswerAction: { answerDetailViewModel in
                if let answerDetailViewModel {
                    viewModel.route(.answerDetail(answerDetailViewModel))
                }
            })
    }
    
    fileprivate func tabbar() -> some View {
        AppTabbar(viewModel: viewModel.tabbarViewModel)
            .padding(.horizontal, 50)
            .padding(.top, 10)
    }
    
    func homeView(_ proxy: GeometryProxy) -> some View {
        VStack {
            if showPage {
                ZStack(alignment: .bottom) {
                    scrollContentView()
                        .frame(width: proxy.size.width)
                    if tabbarVisibility.isVisible {
                        tabbar()
                            .frame(width: proxy.size.width)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .toolbarVisibility(.hidden, for: .navigationBar)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.25), value: tabbarVisibility.isVisible)
            }
        }
        .frame(width: proxy.size.width)
        .toolbarVisibility(.hidden, for: .navigationBar)
        .defaultBackground()
        .task {
            withAnimation(.easeInOut) {
                showPage = true
            }
        }
    }
    
}
