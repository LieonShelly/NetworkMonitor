//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

public struct DashLineButton: View {
    let text: String
    let isSelected: Bool
    let onTap: (() -> Void)
    
    public init(text: String, isSelected: Bool, onTap: @escaping () -> Void) {
        self.text = text
        self.isSelected = isSelected
        self.onTap = onTap
    }
    
    public var body: some View {
        VStack {
            if isSelected {
                RoundedRectangle(cornerRadius: 24)
                    .foregroundStyle(AppColor.color(hex: 0x000000, alpha: 0.8))
                    .transition(.opacity)
            } else {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(style: .init(lineWidth: 1, lineCap: .square, dash: [2, 2]))
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


#Preview {
    
    DashLineButton(text: "asdfasdfsd", isSelected: false, onTap: {})
        .frame(height: 112)
        .padding()
}
