//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct SummaryView: View {
    let summary: ReflectionSummary
    
    var body: some View {
        VStack(spacing: .zero) {
            topLine
            text
                .padding(.horizontal, 32)
                .padding(.top, 32)
                .padding(.bottom, 54)
            closeBtn
        }
        .background(
            RoundedRectangleWithCorners(radius: 20, corners: [.topLeft, .topRight])
                .fill(AppColor.backgroundPage)
        )
    }
    
    var topLine: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(AppColor.color(hex: 0xD9D9D9))
            .frame(width: 60, height: 6)
    }
    
    var text: some View {
        HStack {
            Text("Awesome! \n\n Since October 13th, 2023, you’ve reflected on this question 5 times over 789 days. \n\nReturning to the same topic over time helps you quietly notice the little things that make you happy, see your own gentle growth, and remember moments of warmth even on rainy days. \n\nTake a deep breath, and keep going—your journey matters. ☕✨")
                .textStyle(size: 14, color: AppColor.color(hex: 0x6F6F6F), fontFamily: .poppinsRegular)
            Spacer()
        }
    }
    
    var closeBtn: some View {
        Button {
            
        } label: {
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColor.color(hex: 0xD9D9D9))
                .frame(width: 48, height: 48)
                .overlay {
                    Image(.xmark)
                }
        }
        .ignoresSafeArea(edges: .bottom)
        .padding(.bottom, 45)
    }
}
