//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent

struct TodayAnswerView: View {
    @State var input: String = ""
    
    var body: some View {
        VStack(spacing: .zero) {
            cardListView
            refreshBtn
            answerInputView
            okBtn
        }
        .defaultBackground()
    }
    
    var cardListView: some View {
        ZStack {
            ForEach(0 ..< 3, id: \.self) { index in
                QuestionCardView()
                    .zIndex(3 - Double(index))
                    .rotationEffect(.degrees((2.0 ) * CGFloat(index)), anchor: .init(x: 0, y: 0.5))
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 20)
    }
    
    var refreshBtn: some View {
        Button {} label: {
            Image(.refresh)
                .resizable()
                .frame(width: 32, height: 32)
        }
        .padding(.top, 8 * 3)
    }
    
    
    var answerInputView: some View {
        AnswerInputView(
            text: $input,
            placeholder: "Write anything...."
        )
        .frame(maxHeight: .infinity)
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 16)
        
    }
    
    var okBtn: some View {
        AppButton(isEnabled: !input.isEmpty, title: "oK") {
        }
        .frame(height: 62)
        .padding(.horizontal, 24)
    }
    
}
