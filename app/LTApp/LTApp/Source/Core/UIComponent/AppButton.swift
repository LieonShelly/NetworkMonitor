//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct AppButton: View {
    let isEnabled: Bool
    let title: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            RoundedRectangle(cornerRadius: 12)
                .fill(!isEnabled ? AppColor.color(hex: 0xD9D9D9) : AppColor.textPrimary)
                .overlay {
                    Text(title)
                        .font(AppFont.feltTipSenior(size: 32, fontWeight: .regular))
                        .foregroundStyle(isEnabled ? AppColor.white : AppColor.textPrimary )
                }
        }
        .disabled(!isEnabled)
        .animation(.easeInOut, value: isEnabled)
    }
}


struct DefaultAppButton: View {
    let isEnabled: Bool
    let title: String
    let onTap: () -> Void
    
    
    init(isEnabled: Bool = true, title: String, onTap: @escaping () -> Void) {
        self.isEnabled = isEnabled
        self.title = title
        self.onTap = onTap
    }
    
    var body: some View {
        AppButton(isEnabled: isEnabled, title: title, onTap: onTap)
            .frame(height: 62)
    }
}
