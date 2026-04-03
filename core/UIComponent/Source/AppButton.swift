//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

public struct AppButton: View {
    public enum Style {
        case blackNormal
        case greyNormal
        case greyDisabled
        
        var background: Color {
            switch self {
            case .blackNormal:
                return AppColor.black
            case .greyNormal:
                return AppColor.greyLight
            case .greyDisabled:
                return AppColor.greyLight
            }
        }
        
        var foreground: Color {
            switch self {
            case .blackNormal:
                return AppColor.white
            case .greyNormal:
                return AppColor.greyDark
            case .greyDisabled:
                return AppColor.greyMedium
            }
        }
    }
    let style: Style
    let title: String
    let onTap: () -> Void
    
    public init(style: AppButton.Style, title: String, onTap: @escaping () -> Void) {
        self.style = style
        self.title = title
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: onTap) {
            RoundedRectangle(cornerRadius: 12)
                .fill(style.background)
                .overlay {
                    Text(title)
                        .textStyle(font: .heading, color: style.foreground)
                }
        }
        .disabled(style == .greyDisabled)
        .animation(.easeInOut, value: style)
    }
}


public struct DefaultAppButton: View {
    let isEnabled: Bool
    let title: String
    let onTap: () -> Void
    
    
    public init(isEnabled: Bool = true, title: String, onTap: @escaping () -> Void) {
        self.isEnabled = isEnabled
        self.title = title
        self.onTap = onTap
    }
    
    public var body: some View {
        AppButton(style: isEnabled ? .blackNormal : .greyDisabled, title: title, onTap: onTap)
            .frame(height: 62)
    }
}

