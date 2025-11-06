//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent

struct TodayAnswerView: View {
    @StateObject var viewModel: TodayAnswerViewModel
    @EnvironmentObject var homeCoordinator: HomeCoordinator
   
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
        .task {
            await viewModel.initializeData()
            guard viewModel.questions.isEmpty else { return }
            try? await viewModel.fetchData()
        }
    }
    
    @ViewBuilder
    var cardListView: some View {
        let count = viewModel.questions.count
        ZStack {
            ForEach(0 ..< count, id: \.self) { index in
                let realIndex = Double(count) - Double(index) - 1
                QuestionCardView(question: viewModel.questions[Int(realIndex)])
                    .zIndex(realIndex)
                    .rotationEffect(.degrees((2.0 ) * CGFloat(index)), anchor: .init(x: 0, y: 0.5))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    var refreshBtn: some View {
        Button {} label: {
            Image(.refresh)
                .resizable()
                .frame(width: 32, height: 32)
        }
        .padding(.top, 8 * 3)
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
