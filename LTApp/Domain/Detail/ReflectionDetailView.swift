//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct ReflectionDetailView: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: .zero) {
                titleView
                totalView
                LazyVStack(spacing: .zero) {
                    DetailAnswerRow()
                    DetailAnswerRow()
                    DetailAnswerRow()
                }
                .padding(.horizontal, 42)
            }
        }
        .defaultBackground()
        .defaultNavigationBar("")
    }
    
    var titleView: some View {
        Text("One little things that make you happy today.")
            .textStyle(size: 32)
            .padding(.horizontal, 42)
            .padding(.top, 10)
    }
    
    var totalView: some View {
        Button {
            
        } label: {
            Text("5 answers, 789 days ")
                .textStyle(size: 10, color: AppColor.color(hex: 0xffffff), fontFamily: .poppinsRegular)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppColor.color(hex: 0x000000))
                }
        }
        .padding(.top, 27)
        .padding(.bottom, 24)
    }
}

struct DetailAnswerRow: View {
    var body: some View {
        HStack(alignment: .top, spacing: .zero) {
            dateView
            iconView
            textView
        }
    }
    
    var dateView: some View {
        VStack(spacing: .zero) {
            Text("oct")
                .textStyle(size: 20, color: AppColor.color(hex: 0x000000), fontFamily: .feltTipSeniorRegular)
            
            Text("29")
                .textStyle(size: 20, color: AppColor.color(hex: 0x000000), fontFamily: .feltTipSeniorRegular)
            
        }
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
    }
    
    var textView: some View {
        Text("High school friend brought me a new coffee dripper from California, and I’m so happy to continue my morning coffee routine with that.")
            .multilineTextAlignment(.leading)
            .textStyle(size: 14, color: AppColor.color(hex: 0x6f6f6f), fontFamily: .poppinsRegular)
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
