//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

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
        .frame(width: 30)
        .padding(.top, 42)
    }
    
    var iconView: some View {
        VStack(spacing: .zero) {
            Image(.calendarDripper)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
            line()
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
    
    
    func line(segmentCount: Int = 40, seed: Int = 100) -> some View {
        WavyLine(segmentCount: segmentCount, seed: seed)
            .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round))
            .foregroundColor(AppColor.color(hex: 0x000000))
            .frame(width: 2)
        
    }
}
