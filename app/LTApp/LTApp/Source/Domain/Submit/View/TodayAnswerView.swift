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
    
    init(viewModel: TodayAnswerViewModel, presented: Binding<Bool>) {
        self._viewModel = .init(wrappedValue: viewModel)
        self._presented = presented
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            AppColor.backgroundPage
                .opacity(opacity)
            NaviBar(titlte: viewModel.title, hideBackBtn: viewModel.submitted) {
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
            
            if viewModel.submitted {
                submittedForm
            } else {
                unsubmittedForm
            }
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
        .animation(.easeInOut, value: keyboardObserver.keyboardHeight)
        .animation(.easeInOut, value: viewModel.submitted)
        .animation(.easeInOut, value: presented)
        .task {
            viewModel.submitted = false
//            await viewModel.initializeData()
            guard viewModel.cardViewModels.isEmpty else { return }
            try? await viewModel.fetchData()
        }
    }
    
    var unsubmittedForm: some View {
        VStack(spacing: .zero) {
            cardListView
            refreshBtn
            answerInputView
            okBtn
        }
        .padding(.top, 44)
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
                presented: $presented
            )
            .padding(.top, 44)
            .contentShape(.rect)
            .padding(.top, 20)
        }
    }
    
    @ViewBuilder
    var cardListView: some View {
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
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .opacity(opacity)
        .matchedGeometryEffect(id: "question", in: homeCoordinator.dripleTransitionData.drippleAnimationSpace)
    }
    
    @ViewBuilder
    var refreshBtn: some View {
        if keyboardObserver.keyboardHeight <= 0  {
            Button {
                viewModel.refresh()
            } label: {
                Image(.refresh)
                    .resizable()
                    .frame(width: 32, height: 32)
            }
            .padding(.top, 8 * 3)
            .transition(.opacity)
        }
      
    }
    
    var answerInputView: some View {
        AnswerInputView(
            text: $viewModel.answerText,
            placeholder: "Write anything...."
        )
        .frame(minHeight: 200, maxHeight: .infinity)
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 16)
        .matchedGeometryEffect(id: "answer", in: homeCoordinator.dripleTransitionData.drippleAnimationSpace)
        
    }
    
    var okBtn: some View {
        AppButton(isEnabled: !viewModel.answerText.isEmpty, title: "oK") {
            Task.detached {
                do {
                    try await viewModel.submit()
                } catch {
                    print(error)
                }
            }
        }
        .frame(height: 62)
        .padding(.horizontal, 24)
    }
    
}
