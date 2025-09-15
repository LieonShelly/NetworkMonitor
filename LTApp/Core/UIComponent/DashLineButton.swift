//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct DashLineButton: View {
    let text: String
    let isSelected: Bool
    let onTap: (() -> Void)
    
    var body: some View {
        VStack {
            if isSelected {
                RoundedRectangle(cornerRadius: 24)
                    .foregroundStyle(AppColor.color(hex: 0x000000, alpha: 0.8))
                    .transition(.opacity)
            } else {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(style: .init(lineWidth: 2, dash: [2, 2]))
                    .foregroundStyle(AppColor.color(hex: 0x7F7F7F))
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: isSelected)
        .allowsHitTesting(true)
        .overlay {
            if isSelected {
                Text(text)
                    .font(AppFont.poppins(size: 16))
                    .foregroundStyle(AppColor.color(hex: 0xffffff))
                    .transition(.opacity)
            } else {
                Text(text)
                    .font(AppFont.poppins(size: 16))
                    .foregroundStyle(AppColor.color(hex: 0x282828))
                    .transition(.opacity)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}
