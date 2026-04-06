//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent

struct TodayAnswerView: View {
    @StateObject var viewModel: TodayAnswerViewModel
    @Binding var presented: Bool
    @State var needRefresh: Bool = false
    @StateObject var keyboardObserver: KeyboardObserver = .init()
    @State var opacity: CGFloat = 1
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    enum Constants {
        static let headerH: CGFloat = 72
        static let spacing: CGFloat = 20
        static let questionHPercent: CGFloat = 0.6
        static let answerHPercent: CGFloat = 0.4
    }
    
    init(viewModel: TodayAnswerViewModel, presented: Binding<Bool>) {
        self._viewModel = .init(wrappedValue: viewModel)
        self._presented = presented
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            AppColor.backgroundPage
                .opacity(opacity).ignoresSafeArea()
            switch viewModel.pageState {
            case .unsubmit:
                naviBar
                unsubmittedForm
            case .submitted:
                submittedForm
            case .notificationView:
                NotificationView(viewModel: .init(appService: viewModel.service),
                                 opacity: $opacity) {
                    presented.toggle()
                }
            }
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
        .animation(.easeInOut, value: keyboardObserver.keyboardHeight)
        .animation(.easeInOut, value: viewModel.pageState)
        .animation(.easeInOut, value: presented)
        .task {
            viewModel.pageState = .unsubmit
            //            await viewModel.initializeData()
            guard viewModel.cardViewModels.isEmpty else { return }
            try? await viewModel.fetchData()
        }
    }
    
    @ViewBuilder var naviBar: some View {
        FixedHeader {
          refreshBtn
        } backAction: {
            withAnimation(.easeInOut, completionCriteria: .logicallyComplete) {
                opacity = 0
            } completion: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                    presented.toggle()
                })
            }
        }
        .zIndex(1)
        .opacity(opacity)
    }
    
    var unsubmittedForm: some View {
        VStack(spacing: .zero) {
            GeometryReader { proxy in
                VStack(spacing: Constants.spacing) {
                    cardListView(parent: proxy)
                    answerInputView(parent: proxy)
                }
            }
            .padding(.bottom, Constants.spacing)
            okBtn
        }
        .padding(.top, Constants.headerH)
        .padding(.horizontal, 24)
        .contentShape(.rect)
        .opacity(opacity)
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    @ViewBuilder
    var submittedForm: some View {
        if let viewModel = viewModel.submittedViewModel {
            TodayAnswerSubmittedView(
                viewModel: viewModel,
                opacity: $opacity,
                dismissed: {
                    presented.toggle()
                }
            )
            .padding(.top, 44)
            .contentShape(.rect)
            .padding(.top, 20)
        }
    }
    
    @ViewBuilder
    func cardListView(parent: GeometryProxy) -> some View  {
        let idleH = max((parent.size.height - Constants.spacing) * Constants.questionHPercent, 0)
        ZStack {
            ForEach(viewModel.cardViewModels, id: \.id) { cardViewModel in
                let count = cardViewModel.count
                let index = viewModel.cardViewModels.firstIndex(where: { $0.id == cardViewModel.id}) ?? 0
                let zIndex = Double(count - index)
                LoopingStackCardView(viewModel: cardViewModel)
                    .zIndex(zIndex)
                    .disabled(keyboardObserver.keyboardShown)
            }
        }
        .frame(height: idleH)
        .frame(maxWidth: .infinity)
        .opacity(opacity)
    }
    
    @ViewBuilder
    var refreshBtn: some View {
        if keyboardObserver.keyboardHeight <= 0, viewModel.cardViewModels.count > 1 {
            Button {
                viewModel.refresh()
            } label: {
                Image(.refresh)
                    .resizable()
                    .frame(width: 32, height: 32)
            }
            .transition(.opacity)
        }
      
    }
    
    @ViewBuilder
    func answerInputView(parent: GeometryProxy) -> some View  {
        let idleH = max((parent.size.height - Constants.spacing) * Constants.answerHPercent, 0)
        AnswerInputView(
            text: $viewModel.answerText,
            placeholder: "Write anything...."
        )
        .frame(height: idleH)
    }
    
    var okBtn: some View {
        DefaultAppButton(isEnabled: !viewModel.answerText.isEmpty, title: "Create") {
            Task.detached {
                do {
                    try await viewModel.submit()
                } catch {
                    print(error)
                }
            }
        }
        .padding(.top, Constants.spacing)
        .padding(.bottom, keyboardObserver.keyboardShown ? Constants.spacing : .zero)
    }
    
}
