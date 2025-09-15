//
//  LTApp, This code is protected by intellectual property rights.
//


import SwiftUI

public extension View {
    func textStyle(
        size: CGFloat,
        color: Color = AppColor.textPrimary,
        fontFamily: AppFontType = .feltTipSeniorRegular
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
        }
    }
}
