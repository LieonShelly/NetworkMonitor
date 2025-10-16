//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct FirstQuestionSubmittedView: View {
    let category: String
    let question: String
    let answerText: String
    let createAt: Date
    
    var body: some View {
        submittedForm
    }
    
    var submittedForm: some View {
        VStack(spacing: .zero) {
            topicTitleView
            
            Image(.dripper)
                .resizable()
                .frame(width: 135, height: 165)
                .padding(.top, 100)
            
            HStack {
                Text("\(question)")
                    .textStyle(size: 24)
                    .lineLimit(10)
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 59)
            
            HStack {
                Text(question)
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
}
