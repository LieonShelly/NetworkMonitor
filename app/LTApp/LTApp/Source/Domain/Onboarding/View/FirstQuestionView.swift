//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent


struct FirstQuestionView: View {
    enum CurrentPage {
        case submitted
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
            case .submitted:
                submittedForm
                    .defaultBackground()
                    .transition(.opacity)
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
            Text(Date().monthDayDesc)
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
            placeholder: "Write anything...."
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
            GeometryReader { proxy in
                VStack(spacing: Constants.spacing) {
                    questionCardView(parent: proxy)
                    answerInputView(parent: proxy)
                }
            }
            okBtn
        }
        .contentShape(.rect)
        .padding(.horizontal, 24)
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    var submittedForm: some View {
        VStack(spacing: .zero) {
            ImageFramesAnimationView(aniamationData: .dripple)
                .padding(.top, 100)
                .opacity(0)
                .transition(.opacity)
            
            HStack {
                Text("\(viewModel.question?.title ?? "")")
                    .textStyle(size: 24)
                    .lineLimit(10)
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 59)
            .matchedGeometryEffect(id: "question", in: animation, properties: .position)
            
            HStack {
                Text(viewModel.answerText)
                    .textStyle(size: 12, color: AppColor.color(hex: 0x323232), fontFamily: .poppinsRegular)
                    .padding(.init(top: 22, leading: 18, bottom: 22, trailing: 18))
                Spacer()
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(style: .init(lineWidth: 1))
                    .foregroundStyle(AppColor.color(hex: 0xEBEBEB))
            )
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            .matchedGeometryEffect(id: "answer", in: animation, properties: .position)
            
            if currentPage == .submitted {
                HStack {
                    Text(viewModel.createAt?.formatDateToEnglishStyle() ?? "June 16, 2025")
                        .textStyle(size: 10, color: AppColor.color(hex: 0x9e9e9e), fontFamily: .sfProRegular)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .transition(.opacity)
            }
            Spacer()
        }
    }
    
    
    func showSubmittedForm() async throws {
        withAnimation(.easeInOut(duration: 0.5)) {
            currentPage = .submitted
        }
        viewModel.disableOnboardingFlow()
        try await Task.sleep(for: .milliseconds(700))
        coordinaor.changeRoot(
            .home(.init(
                overLayData: .init(
                    category: viewModel.category.name,
                    question: viewModel.question?.title ?? "",
                    answerText: viewModel.answerText,
                    createAt: viewModel.createAt ?? Date())
            ))
        )
    }
}
