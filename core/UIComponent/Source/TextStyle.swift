//
//  LTApp, This code is protected by intellectual property rights.
//


import SwiftUI

public extension View {
    func textStyle(
        size: CGFloat,
        color: Color = AppColor.textPrimary,
        fontFamily: AppFontType = .vividlyRegular
    ) -> some View {
        switch fontFamily {
        case .feltTipSeniorRegular:
            return self.foregroundStyle(color)
                .font(AppFont.feltTipSenior(size: size))
        case .poppinsRegular:
            return self.foregroundStyle(color)
                .font(AppFont.poppins(size: size))
        case .sfProRegular:
            return self.foregroundStyle(color)
                .font(AppFont.sfPro(size: size))
        case .sfProBold:
            return self.foregroundStyle(color)
                .font(AppFont.sfPro(size: size, fontWeight: .bold))
        case .sfProMedium:
            return self.foregroundStyle(color)
                .font(AppFont.sfPro(size: size, fontWeight: .medium))
        case .vividlyRegular:
            return self.foregroundStyle(color)
                .font(AppFont.vividly(size: size, fontWeight: .regular))
        }
    }
}
