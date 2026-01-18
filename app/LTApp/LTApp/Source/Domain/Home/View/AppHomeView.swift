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
    
    init(viewModel: AppHomeViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        GeometryReader { proxy in
            homeView(proxy)
        }
        .innerPageRoute($viewModel.subPageRoute)
    }
    
    fileprivate func scrollContentView() -> AppScrollContentView {
        return AppScrollContentView(
            viewModel: viewModel.contentViewModel,
            addAction: { question in
                viewModel.pushToAddTodayAnsnwer(question)
            },
            onTapAnswerAction: {answerDetailViewModel in
                if let answerDetailViewModel {
                    viewModel.route(.answerDetail(answerDetailViewModel))
                }
            })
    }
    
    fileprivate func tabbar() -> ZStack<TupleView<(some View, (some View)?)>> {
        return ZStack(alignment: .bottom) {
            AppTabbar(viewModel: viewModel.tabbarViewModel)
                .padding(.horizontal, 50)
                .padding(.top, 10)
            
            if let head = viewModel.todayQuestions.first, viewModel.showTodayQuestion {
                TodayQuestionView(question: head) {
                    viewModel.pushToAddTodayAnsnwer()
                }
                .offset(y: -(40 + 16 * 2))
                .padding(.horizontal, 40)
                .padding(.bottom, 10)
                .transition(.opacity)
                .task {
                    viewModel.observeNotification()
                }
            }
        }
    }
    
    func homeView(_ proxy: GeometryProxy) -> some View {
        VStack {
            if showPage {
                ZStack(alignment: .bottom) {
                    scrollContentView()
                        .frame(width: proxy.size.width)
                    tabbar()
                        .frame(width: proxy.size.width)
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
    
}
