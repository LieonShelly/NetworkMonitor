//
//  LTApp, This code is protected by intellectual property rights.
//
import SwiftUI
import UIComponent


struct AppHomeView: View {
    @StateObject var viewModel: AppHomeViewModel
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    @State var showPage: Bool = false
    @State var subPagePrensented: Bool = false
    
    init(service: any AppDataWithAuthorizationServiceful) {
        self._viewModel = StateObject(wrappedValue: AppHomeViewModel(service: service))
    }
    
    var body: some View {
        GeometryReader { proxy in
            homeView(proxy)
        }
        .innerPageRoute($viewModel.subPageRoute)
    }
    
    func homeView(_ proxy: GeometryProxy) -> some View {
        VStack {
            if showPage {
                VStack(spacing: .zero) {
                    AppScrollContentView(viewModel: viewModel.contentViewModel) {
                        pushToAddTodayAnsnwer()
                    } onTapAnswerAction: { answerDetailViewModel in
                        if let answerDetailViewModel {
                            viewModel.subPageRoute = .answerDetail(answerDetailViewModel)
                        }
                    }
                    ZStack(alignment: .bottom) {
                        AppTabbar(viewModel: viewModel.tabbarViewModel)
                            .padding(.horizontal, 50)
                            .padding(.top, 10)
                        
                        if let head = viewModel.todayQuestions.first, viewModel.showTodayQuestion {
                            TodayQuestionView(question: head) {
                                pushToAddTodayAnsnwer()
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
    
    
    var titleView: some View {
        Text("The Little Things")
            .textStyle(size: 36)
            .padding(.top, 35)
    }
    
    func pushToAddTodayAnsnwer() {
        viewModel.subPageRoute = .todayAnswer(viewModel.generateTodayViewModel())
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.viewModel.selected(0)
        })
    }
}
