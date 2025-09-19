//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct FirstQuestionView: View {
    @ObservedObject var viewModel: FirstQuestionViewModel
    
    init(viewModel: FirstQuestionViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        answerForm.defaultBackground()
            .toolbarVisibility(.hidden, for: .navigationBar)
            .task {
                await viewModel.fetchData()
            }
    }
    
    var topicTitleView: some View {
        HStack(spacing: 6) {
            Text("daily life")
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
    }
    
    var questionView: some View {
        HStack {
            Text(viewModel.question?.title ?? "")
                .textStyle(size: 32)
                .lineLimit(4)
            Spacer()
        }
        .padding(.horizontal, 24)
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
        
    }
    
    var okBtn: some View {
        AppButton(isEnabled: !viewModel.answerText.isEmpty, title: "oK") {
                
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
    }
    
    var submittedForm: some View {
        VStack(spacing: .zero) {
            topicTitleView
            
            Image(.dripper)
                .resizable()
                .frame(width: 135, height: 165)
                .padding(.top, 100)
            
            HStack {
                Text("\(viewModel.question?.title ?? "")")
                    .textStyle(size: 24)
                    .lineLimit(10)
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 59)
            
            HStack {
                Text(viewModel.answerText)
                    .textStyle(size: 12, fontFamily: .poppinsRegular)
                    .padding(.init(top: 18, leading: 22, bottom: 18, trailing: 18))
                Spacer()
            }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(style: .init(lineWidth: 1))
                        .foregroundStyle(AppColor.color(hex: 0xEBEBEB))
                )
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
            
            HStack {
                Text("June 16, 2025")
                    .textStyle(size: 10, color: AppColor.color(hex: 0x9e9e9e), fontFamily: .sfProRegular)
                Spacer()
            }
            .padding(.horizontal, 24)
            Spacer()
        }
    }
}
