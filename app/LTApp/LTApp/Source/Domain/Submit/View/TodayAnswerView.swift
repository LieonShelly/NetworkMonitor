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
    @Namespace var animationID
    @State var opacity: CGFloat = 1
    
    init(viewModel: TodayAnswerViewModel, presented: Binding<Bool>) {
        self._viewModel = .init(wrappedValue: viewModel)
        self._presented = presented
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            AppColor.backgroundPage
                .opacity(opacity)
            NaviBar(titlte: viewModel.title) {
                withAnimation(.easeInOut) {
                    opacity = 0
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
            answerText: viewModel.answerText,
            animationID: animationID,
            opacity: opacity
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
                .matchedGeometryEffect(id: "question", in: animationID)
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
        .matchedGeometryEffect(id: "answer", in: animationID)
        
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
    let animationID: Namespace.ID
    var opacity: CGFloat
    
    var body: some View {
        VStack(spacing: .zero) {
            questionView
            imageView
            answerView
            Spacer()
            closeBtn
        }
        .animation(.easeInOut, value: opacity)
    }
    
    var questionView: some View {
        Text(quesitionText)
            .textStyle(size: 32, fontFamily: .vividlyRegular)
            .padding(.horizontal, 16)
            .opacity(opacity)
            .matchedGeometryEffect(id: "question", in: animationID)
        
    }
    
    var answerView: some View {
        HStack {
            Text(answerText)
                .textStyle(size: 12, color: AppColor.color(hex: 0x323232), fontFamily: .poppinsRegular)
                .padding(.init(top: 22, leading: 18, bottom: 22, trailing: 18))
            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(style: .init(lineWidth: 1))
                .foregroundStyle(AppColor.color(hex: 0xEBEBEB))
        )
        .frame(maxHeight: 149)
        .padding(.horizontal, 24)
        .padding(.top, 90)
        .opacity(opacity)
        .matchedGeometryEffect(id: "answer", in: animationID)
    }
    
    var imageView: some View {
        Image(uiImage: LocalIconLib.fallLeave)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 150, height: 147)
            .padding(.top, 58)
        
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
        .opacity(opacity)
    }
}
