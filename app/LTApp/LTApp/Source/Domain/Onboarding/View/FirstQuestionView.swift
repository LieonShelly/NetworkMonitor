//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent


struct FirstQuestionView: View {
    enum CurrentPage {
        case final
        case answer
    }
    enum Constants {
        static let headerH: CGFloat = 72
        static let spacing: CGFloat = 20
        static let questionHPercent: CGFloat = 0.6
        static let answerHPercent: CGFloat = 0.4
    }
    @EnvironmentObject var coordinaor: AppCoordinator
    @StateObject var viewModel: FirstQuestionViewModel
    @State var currentPage: CurrentPage = .answer
    @State var showFramesAniamtion: Bool = false
    @Namespace var animation
    @StateObject var keyboardObserver: KeyboardObserver = .init()
    @EnvironmentObject var navigator: PreHomeCoordinator
    
    init(viewModel: FirstQuestionViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            switch currentPage {
            case .final:
                EmptyView()
            case .answer:
                answerForm.defaultBackground()
                    .transition(.opacity)
                    .task {
                        await viewModel.fetchData()
                    }
            }
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
        .animation(.easeInOut(duration: 0.5), value: keyboardObserver.keyboardShown)
    }
    
    var topicTitleView: some View {
        HStack(spacing: 6) {
            Text(viewModel.category.name)
                .textStyle(size: 14, color: .white, fontFamily: .sfProBold)
            Image(.downArrow)
                .resizable()
                .frame(width: 12, height: 8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(AppColor.textPrimary)
        .cornerRadius(16, corners: .allCorners)
        .padding(.top, 16)
        .matchedGeometryEffect(id: "title", in: animation, properties: .position)
    }
    
    func dateView() -> some View {
        FixedHeader {
            Text(Date().dayMonthDesc)
                .textStyle(font: .section, color: AppColor.color(hex: 0x423D3D))
        } backAction: {
            navigator.pop()
        }
    }
    
    @ViewBuilder
    func questionCardView(parent: GeometryProxy) -> some View {
        let idleH = max((parent.size.height - Constants.spacing) * Constants.questionHPercent, 0)
        
        VStack {
            Text("#\(viewModel.category.name)")
                .textStyle(font: .section, color: AppColor.color(hex: 0xADA35F))
                .padding(.top, 10)
            Spacer()
        }
        .frame(height: idleH)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColor.color(hex: 0xFFFAEE))
                .shadow(color: AppColor.color(hex: 0xDFD7C4).opacity(0.25), radius: 4, x: 4, y: 4)
        }
        .overlay {
            Text(viewModel.question?.title ?? "")
                .textStyle(font: .heading)
                .frame(maxHeight: 120)
                .padding(.horizontal, 10)
        }
       
    }
    
    @ViewBuilder
    func answerInputView(parent: GeometryProxy) -> some View {
       let idleH = max((parent.size.height - Constants.spacing) * Constants.answerHPercent, 0)
        AnswerInputView(
            text: $viewModel.answerText,
            placeholder: "Jot down a tiny moment worth keeping..."
        )
        .frame(height: idleH)
        
    }
    
    var okBtn: some View {
        DefaultAppButton(isEnabled: !viewModel.answerText.isEmpty, title: "Create") {
            Task.detached {
                do {
                    try await viewModel.submit()
                    try await showSubmittedForm()
                } catch {
                    print(error)
                }
            }
        }
        .padding(.top, Constants.spacing)
        .padding(.bottom, keyboardObserver.keyboardShown ? Constants.spacing : .zero)
    }
    
    var answerForm: some View {
        VStack(spacing: .zero) {
            dateView()
            VStack(spacing: .zero) {
                GeometryReader { proxy in
                    VStack(spacing: Constants.spacing) {
                        questionCardView(parent: proxy)
                        answerInputView(parent: proxy)
                    }
                }
                okBtn
            }
            .padding(.horizontal, 24)
  
        }
        .contentShape(.rect)
        
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    
    func showSubmittedForm() async throws {
        viewModel.disableOnboardingFlow()
        coordinaor.changeRoot(
            .home(.init(showNotificationView: true))
        )
    }
}
