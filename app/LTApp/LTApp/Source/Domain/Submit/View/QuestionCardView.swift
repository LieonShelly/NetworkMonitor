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
            Text("# \(question.category?.name ?? "")")
                .textStyle(font: .section, color: AppColor.color(hex: 0xADA35F))
                .padding(.top, 10)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColor.color(hex: 0xFFFAEE))
                .shadow(color: AppColor.color(hex: 0xDFD7C4).opacity(0.25), radius: 4, x: 4, y: 4)
        }
        .overlay {
            Text(question.title)
                .textStyle(font: .heading)
                .frame(maxHeight: 120)
                .padding(.horizontal, 10)
        }
    }
}
