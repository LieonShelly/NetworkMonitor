//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent

struct QuestionCardView: View {
    let question: Question
    @StateObject var keyboardObserver: KeyboardObserver = .init()
    
    var body: some View {
        VStack {
            titleView
            questionView
        }
        .frame(maxWidth: .infinity)
        .background(AppColor.color(hex: 0xFFFAEE))
        .cornerRadius(12, corners: .allCorners)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColor.color(hex: 0x717171), lineWidth: 1)
        )
    }
    
    var titleView: some View {
        Text("# \(question.category?.name ?? "")")
              .textStyle(size: 10, color: AppColor.color(hex: 0x000000), fontFamily: .poppinsRegular)
              .padding(.horizontal, 10)
              .padding(.vertical, 6)
              .background(AppColor.color(hex: 0xFFFDF8))
              .overlay(
                  RoundedRectangle(cornerRadius: 16)
                      .stroke(AppColor.color(hex: 0xEBEBEB), lineWidth: 1)
              )
              .padding(.top, keyboardObserver.keyboardShown ? 0 : 5)

    }
    
    var questionView: some View {
        Text(question.title)
            .textStyle(size: keyboardObserver.keyboardShown ? 32: 36)
              .fixedSize(horizontal: false, vertical: true)
              .padding(.bottom, keyboardObserver.keyboardShown ? 10 : 45)
              .padding(.top, keyboardObserver.keyboardShown ? 0 : 12)
              .padding(.horizontal, 20)

    }

}
