//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct FirstQuestionView: View {
    @EnvironmentObject var coordinaor: AppCoordinator
    @ObservedObject var viewModel: FirstQuestionViewModel
    @State var submitted: Bool = false
    @State var showFramesAniamtion: Bool = false
    @Namespace var animation
    
    init(viewModel: FirstQuestionViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            if submitted {
                submittedForm.defaultBackground()
                    .transition(.opacity)
            } else {
                answerForm.defaultBackground()
                    .toolbarVisibility(.hidden, for: .navigationBar)
                    .transition(.opacity)
                    .task {
                        await viewModel.fetchData()
                    }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: submitted)
        .animation(.easeInOut(duration: 0.5), value: showFramesAniamtion)
      
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
    
    var topicTitleSubmittedView: some View {
        HStack(spacing: 6) {
            Text(viewModel.category.name)
                .textStyle(size: 14, color: .white, fontFamily: .sfProBold)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(AppColor.textPrimary)
        .cornerRadius(16, corners: .allCorners)
        .padding(.top, 16)
        .matchedGeometryEffect(id: "category", in: animation, properties: .position)
    }
    
    var questionView: some View {
        HStack {
            Text(viewModel.question?.title ?? "")
                .textStyle(size: 32)
            Spacer()
        }
        .padding(.horizontal, 24)
        .matchedGeometryEffect(id: "question", in: animation, properties: .position)
    }
  
    var answerInputView: some View {
        AnswerInputView(
            text: $viewModel.answerText,
            placeholder: "Write anything...."
        )
            .padding(.horizontal, 24)
            .frame(height: 286)
            .padding(.top, 35)
            .padding(.bottom, 76)
            .matchedGeometryEffect(id: "answer", in: animation, properties: .position)
        
    }
    
    var okBtn: some View {
        AppButton(isEnabled: !viewModel.answerText.isEmpty, title: "oK") {
         
            Task {
                submitted.toggle()
                try await Task.sleep(for: .milliseconds(700))
                showFramesAniamtion.toggle()
            }
//                Task.detached {
//                    do {
//                       try await viewModel.submit()
//                        await coordinaor.changeRoot(.home)
//                    } catch {
//                        print(error)
//                    }
//                   
//                }
            }
            .frame(height: 62)
            .padding(.horizontal, 32)
    }
    
    var answerForm: some View {
        VStack(spacing: .zero) {
            topicTitleView
            Spacer()
            questionView
            answerInputView
            okBtn
        }
        .contentShape(.rect)
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    var submittedForm: some View {
        VStack(spacing: .zero) {
            topicTitleSubmittedView
            ImageFramesAnimationView(aniamationData: .dripple)
                .padding(.top, 100)
                .opacity(showFramesAniamtion ? 1 : 0)
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
            
            if submitted {
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
}
