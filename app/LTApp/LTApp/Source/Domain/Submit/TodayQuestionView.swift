//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent

struct TodayQuestionView: View {
    let question: Question
    
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            titleView
            questionView
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColor.color(hex: 0xfffefd))
                .shadow(color: AppColor.color(hex: 0xcccccc).opacity(0.25), radius: 20)
        )
    }
    
    var titleView: some View {
        Text("Question of the day")
              .textStyle(size: 12, color: AppColor.color(hex: 0x6f6f6f), fontFamily: .poppinsRegular)
              .padding(.horizontal, 16)
              .padding(.top, 16)
              .padding(.bottom, 8)
    }
    
    var questionView: some View {
        HStack(alignment: .center, spacing: .zero) {
            questionRow
            Spacer()
            addBtn
        }
        .padding(.bottom, 16)
    }
    
    var questionRow: some View {
        Text(question.title)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .textStyle(size: 24)
            .padding(.horizontal, 16)
    }
    
    var addBtn: some View {
        Button {
            
        } label: {
            LinearGradient(
                colors: [
                    AppColor.color(hex: 0x040404),
                    AppColor.color(hex: 0x656565)
                ],
                startPoint: .init(x: 0, y: 0),
                endPoint: .init(x: 1, y: 0.7)
            )
            .cornerRadius(20, corners: .allCorners)
            .blur(radius: 3)
            .frame(width: 40, height: 40)
            .overlay {
                Image(.smallAdd)
                    .resizable()
                    .frame(width: 16, height: 16)
            }
        }
        .padding(.trailing, 14)
        .padding(.top, 2)
       
    }
    
}
