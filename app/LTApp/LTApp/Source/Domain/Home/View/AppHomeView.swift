//
//  LTApp, This code is protected by intellectual property rights.
//
import SwiftUI
import UIComponent


struct AppHomeView: View {
    @StateObject var viewModel: AppHomeViewModel
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    
    @State var showPage: Bool = false
    @State var showTodayQuestion: Bool = true
    @State var showTodayAnswerView: Bool = false
    
    init(service: any AppDataWithAuthorizationServiceful) {
        self._viewModel = StateObject(wrappedValue: AppHomeViewModel(service: service))
    }
    
    var body: some View {
        GeometryReader { proxy in
            if showTodayAnswerView {
                todayAnswerView
                    .transition(
                        .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            } else {
                homeView(proxy)
            }
        }
    }
    
    func homeView(_ proxy: GeometryProxy) -> some View {
        VStack {
            if showPage {
                VStack(spacing: .zero) {
                    AppScrollContentView(viewModel: viewModel.contentViewModel)
                    ZStack(alignment: .bottom) {
                        AppTabbar(viewModel: viewModel.tabbarViewModel)
                            .padding(.horizontal, 50)
                            .padding(.top, 10)
                            
                        if let head = viewModel.todayQuestions.first, showTodayQuestion {
                            TodayQuestionView(question: head) {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    showTodayAnswerView = true
                                }
                            }
                                .offset(y: -(40 + 16 * 2))
                                .padding(.horizontal, 40)
                                .padding(.bottom, 10)
                                .transition(.opacity)
                        }
                    }
                }
                .toolbarVisibility(.hidden, for: .navigationBar)
                .transition(.opacity)
            }
        }
        .frame(width: proxy.size.width)
        .toolbarVisibility(.hidden, for: .navigationBar)
        .defaultBackground()
        .task {
            withAnimation(.easeInOut) {
                showPage = true
            }
           try? await viewModel.fetchData()
        }
    }
    
    var todayAnswerView: some View {
        homeCoordinator.build(HomeRoute.addTodayAnswer(.init(questions: viewModel.organize(), submiited: { @MainActor in
            //                                        showTodayQuestion = false
                                            })))
    }
    
    var titleView: some View {
        Text("The Little Things")
            .textStyle(size: 36)
            .padding(.top, 35)
    }
}
