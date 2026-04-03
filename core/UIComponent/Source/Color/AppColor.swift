//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

public enum AppColor {
    public static let textPrimary = Color("textPrimary", bundle: UIComponentsModule.resourceBundle)
    case textSecondary
    public  static let backgroundPage = Color("backgroundPage", bundle: UIComponentsModule.resourceBundle)
    public static let white = AppColor.color(hex: 0xFFFFFF)
    public static let black = AppColor.color(hex: 0x000000)
    public static let greyNeutral = AppColor.color(hex: 0xCDCDCD)
    public static let greyDark = AppColor.color(hex: 0x323232)
    public static let oat = AppColor.color(hex: 0xFFFDF8)
    public static let grey = AppColor.color(hex: 0xB8B8B8)
    public static let greyLight = AppColor.color(hex: 0xEBEBEB)
    public static let greyMedium = AppColor.color(hex: 0x6F6F6F)
    
    
    public static func color(hex: UInt32, alpha: CGFloat = 1) -> Color {
        Color(UIColor(hex: hex, alpha: alpha))
    }
}


public extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(red: CGFloat(UInt8((hex & 0xFF0000) >> 16)) / 0xFF,
                  green: CGFloat(UInt8((hex & 0xFF00) >> 8)) / 0xFF,
                  blue: CGFloat(UInt8(hex & 0xFF)) / 0xFF,
                  alpha: alpha)
    }
}




public extension Color {
   static var random: Color {
        Color(red: Double.random(in: 0 ... 255) / 255.0, green: Double.random(in: 0 ... 255) / 255.0, blue: Double.random(in: 0 ... 255) / 255.0)
    }
}

