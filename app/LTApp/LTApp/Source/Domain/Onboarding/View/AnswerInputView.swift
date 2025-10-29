//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent


struct AnswerInputView: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .textStyle(size: 12, color: AppColor.color(hex: 0x323232), fontFamily: .poppinsRegular)
                .tint(AppColor.color(hex: 0x323232))
                .padding(.top, 10)
                .padding(.leading, 10)
               
            if text.isEmpty {
                Text(placeholder)
                    .textStyle(size: 12, fontFamily: .poppinsRegular)
                    .padding(.top, 17)
                    .padding(.leading, 13)
            }
        }
        .padding(5)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(style: .init(lineWidth: 1))
                .foregroundStyle(AppColor.color(hex: 0xEBEBEB))
               
        )
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}
