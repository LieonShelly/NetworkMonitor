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
            if viewModel.submitted {
                submittedForm
            } else {
                unsubmittedForm
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
    
    var unsubmittedForm: some View {
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
    
    var submittedForm: some View {
        TodayAnswerSubmittedView(
            quesitionText: viewModel.cardViewModels.first?.question.title ?? "",
            answerText: viewModel.answerText
        )
        .padding(.top, 44)
        .contentShape(.rect)
        .padding(.top, 20)
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
        if keyboardObserver.keyboardHeight <= 0 || viewModel.answerText.isEmpty  {
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
                } catch {
                    print(error)
                }
            }
        }
        .frame(height: 62)
        .padding(.horizontal, 24)
    }
    
}


struct TodayAnswerSubmittedView: View {
    let quesitionText: String
    let answerText: String
    
    var body: some View {
        VStack(spacing: .zero) {
            questionView
            Spacer()
            imageView
            Spacer()
            answerView
            Spacer()
            closeBtn
        }
    }
    
    var questionView: some View {
        Text(quesitionText)
            .textStyle(size: 32, fontFamily: .vividlyRegular)
            .padding(.horizontal, 16)
    }
    
    var answerView: some View {
        HStack {
            Text(answerText)
                .textStyle(size: 12, color: AppColor.color(hex: 0x323232), fontFamily: .poppinsRegular)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.init(top: 22, leading: 18, bottom: 22, trailing: 18))
            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(style: .init(lineWidth: 1))
                .foregroundStyle(AppColor.color(hex: 0xEBEBEB))
        )
        .padding(.horizontal, 24)
    }
    
    var imageView: some View {
        Image(uiImage: LocalIconLib.fallLeave)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 150)
        
    }
    
    var closeBtn: some View {
        Button {
            
        } label: {
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColor.color(hex: 0xD9D9D9))
                .frame(width: 48, height: 48)
                .overlay {
                    Image(.xmark)
                }
        }
        .padding(.bottom, 45)
    }
}
