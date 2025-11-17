//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent

struct TodayAnswerView: View {
    @StateObject var viewModel: TodayAnswerViewModel
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    @State var needRefresh: Bool = false
    @StateObject var keyboardObserver: KeyboardObserver = .init()
    
    init(viewModel: TodayAnswerViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            NaviBar(titlte: viewModel.title) {
                homeCoordinator.pop()
            }
            .zIndex(1)
            
            VStack(spacing: .zero) {
                cardListView
                refreshBtn
                answerInputView
                okBtn
            }
            .padding(.top, 44)
            .contentShape(.rect)
            .onTapGesture {
                hideKeyboard()
            }
        }
        .defaultBackground()
        .toolbarVisibility(.hidden, for: .navigationBar)
        .animation(.easeInOut, value: keyboardObserver.keyboardHeight)
        .task {
            await viewModel.initializeData()
            guard viewModel.cardViewModels.isEmpty else { return }
            try? await viewModel.fetchData()
        }
    }
    @ViewBuilder
    var cardListView: some View {
        let count = viewModel.cardViewModels.count
        if count > 0 {
            ZStack {
                ForEach(viewModel.cardViewModels, id: \.id) { cardViewModel in
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
        }
    }
    
    @ViewBuilder
    var refreshBtn: some View {
        if keyboardObserver.keyboardHeight <= 0 || viewModel.answerText.isEmpty {
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
        
    }
    
    var okBtn: some View {
        AppButton(isEnabled: !viewModel.answerText.isEmpty, title: "oK") {
            Task.detached {
                do {
                    try await viewModel.submit()
                    await MainActor.run {
                        homeCoordinator.pop()
                    }
                } catch {
                    print(error)
                }
            }
        }
        .frame(height: 62)
        .padding(.horizontal, 24)
    }
    
}

