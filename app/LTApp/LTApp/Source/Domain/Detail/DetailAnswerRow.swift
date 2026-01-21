//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent


struct DetailAnswerRow: View {
    let answer: Answer
    
    var body: some View {
        HStack(alignment: .top, spacing: .zero) {
            dateView
            iconView
            textView
        }
    }
    
    var dateView: some View {
        VStack(alignment: .trailing, spacing: .zero) {
            Text(answer.createTms?.monthDesc(isShort: true) ?? "")
                .textStyle(size: 20, color: AppColor.color(hex: 0x000000), fontFamily: .feltTipSeniorRegular)
            
            Text(answer.createTms?.dayDesc() ?? "")
                .textStyle(size: 20, color: AppColor.color(hex: 0x000000), fontFamily: .feltTipSeniorRegular)
            
        }
        .padding(.top, 42)
    }
    
    var iconView: some View {
        VStack(spacing: .zero) {
            IconView(answer: answer)
            line(answer)
                .padding(.vertical, 8)
        }
        .padding(.leading, 8)
    }
    
    var textView: some View {
        HStack {
            Text(answer.content)
                .multilineTextAlignment(.leading)
                .textStyle(size: 14, color: AppColor.color(hex: 0x6f6f6f), fontFamily: .poppinsRegular)
            Spacer()
        }
      
            .padding(.top, 42)
            .padding(.bottom, 14)
    }
    
    
    @ViewBuilder  func line(_ answer: Answer) -> some View {
        let segmentCount: Int = answer.content.count < 100 ? 10 : 40
        let seed: Int = answer.content.count < 100 ? 30 : 100
        WavyLine(segmentCount: segmentCount, seed: seed)
            .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round))
            .foregroundColor(AppColor.color(hex: 0x000000))
            .frame(width: 2)
        
    }
}
