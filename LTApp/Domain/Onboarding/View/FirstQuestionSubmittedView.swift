//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct FirstQuestionSubmittedView: View {
    let category: String
    let question: String
    let answerText: String
    let createAt: Date
    @State var showCloseBtn: Bool = false
    
    var body: some View {
        submittedForm
            .animation(.easeInOut(duration: 0.5), value: showCloseBtn)
            .task {
                showCloseBtn.toggle()
            }
    }
    
    var submittedForm: some View {
        VStack(spacing: .zero) {
            topicTitleSubmittedView
            if let lastFrame = FramesAnimationData.dripple.lastFrame {
                Image(uiImage: lastFrame)
                    .resizable()
                    .scaledToFit()
                    .frame(width: FramesAnimationData.dripple.frameSize.width,
                           height: FramesAnimationData.dripple.frameSize.height)
                    .padding(.top, 100)
            }
            
            HStack {
                Text(question)
                    .textStyle(size: 24)
                    .lineLimit(10)
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 59)
            
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
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            
            HStack {
                Text(createAt.formatDateToEnglishStyle())
                    .textStyle(size: 10, color: AppColor.color(hex: 0x9e9e9e), fontFamily: .sfProRegular)
                Spacer()
            }
            .padding(.horizontal, 24)
            .transition(.opacity)
            Spacer()
            
            if showCloseBtn {
                closeBtn
            }
            
        }
    }
    var topicTitleView: some View {
        HStack(spacing: 6) {
            Text(category)
                .textStyle(size: 14, color: .white, fontFamily: .sfProBold)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(AppColor.textPrimary)
        .cornerRadius(16, corners: .allCorners)
        .padding(.top, 16)
    }
    
    var topicTitleSubmittedView: some View {
        HStack(spacing: 6) {
            Text(category)
                .textStyle(size: 14, color: .white, fontFamily: .sfProBold)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(AppColor.textPrimary)
        .cornerRadius(16, corners: .allCorners)
        .padding(.top, 16)
    }
    
    var closeBtn: some View {
        Button {
            
        } label: {
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColor.color(hex: 0xEBEBEBEB).opacity(0.92))
                .frame(width: 48, height: 48)
                .overlay {
                    Image(.back)
                }
        }
        .padding(.bottom, 42)
        .transition(.opacity)
    }
}
