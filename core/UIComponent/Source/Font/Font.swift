//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

public class AppFont {
    
    public static func feltTipSenior(size: CGFloat, fontWeight: AppFontWeight = .regular) -> Font {
        switch fontWeight {
        case .regular:
            return Font.custom(AppFontType.feltTipSeniorRegular.fontName, size: size)
        case .medium, .bold:
            return Font.custom(AppFontType.feltTipSeniorRegular.fontName, size: size)
        case .heavy:
            return Font.custom(AppFontType.feltTipSeniorRegular.fontName, size: size)
        }
    }
    
    
    public static func feltTipSenior(size: CGFloat, fontWeight: AppFontWeight = .regular) -> UIFont {
        switch fontWeight {
        case .regular:
            return UIFont(descriptor: .init(name: AppFontType.feltTipSeniorRegular.fontName, size: size), size: size)
        case .medium, .bold:
            return UIFont(descriptor: .init(name: AppFontType.feltTipSeniorRegular.fontName, size: size), size: size)
        case .heavy:
            return UIFont(descriptor: .init(name: AppFontType.feltTipSeniorRegular.fontName, size: size), size: size)
        }
    }
    
    public static func poppins(size: CGFloat, fontWeight: AppFontWeight = .regular) -> Font {
        switch fontWeight {
        case .regular:
            return Font.custom(AppFontType.poppinsRegular.fontName, size: size)
        case .medium, .bold:
            return Font.custom(AppFontType.poppinsRegular.fontName, size: size)
        case .heavy:
            return Font.custom(AppFontType.poppinsRegular.fontName, size: size)
        }
    }
    
    public static func sfPro(size: CGFloat, fontWeight: AppFontWeight = .regular) -> Font {
        switch fontWeight {
        case .regular:
            return Font.custom(AppFontType.sfProRegular.fontName, size: size)
        case .medium:
            return Font.custom(AppFontType.sfProMedium.fontName, size: size)
        case .bold:
            return Font.custom(AppFontType.sfProBold.fontName, size: size)
        case .heavy:
            return Font.custom(AppFontType.sfProRegular.fontName, size: size)
        }
    }
    
    
    public static func vividly(size: CGFloat, fontWeight: AppFontWeight = .regular) -> Font {
        switch fontWeight {
        case .regular:
            return Font.custom(AppFontType.vividlyRegular.fontName, size: size)
        case .medium:
            return Font.custom(AppFontType.vividlyRegular.fontName, size: size)
        case .bold:
            return Font.custom(AppFontType.vividlyRegular.fontName, size: size)
        case .heavy:
            return Font.custom(AppFontType.vividlyRegular.fontName, size: size)
        }
    }
    
    
    public static func vividly(size: CGFloat, fontWeight: AppFontWeight = .regular) -> UIFont {
        switch fontWeight {
        case .regular:
            return UIFont(descriptor: .init(name: AppFontType.vividlyRegular.fontName, size: size), size: size)
        case .medium, .bold:
            return UIFont(descriptor: .init(name: AppFontType.vividlyRegular.fontName, size: size), size: size)
        case .heavy:
            return UIFont(descriptor: .init(name: AppFontType.vividlyRegular.fontName, size: size), size: size)
        }
    }
    
    
    public static func registerFonts() throws {
        try AppFontType.allCases.forEach { try UIFont.register(from: resourceUrl(fontType: $0)) }
    }
    
    static func resourceUrl(bundle: Bundle? = nil, fontType: AppFontType) -> URL {
        let fontsBundle = bundle ?? UIComponentsModule.resourceBundle
        
        guard let resourceUrl = fontsBundle.url(forResource: fontType.fileName, withExtension: fontType.fileExtension) else {
            fatalError("Resource doesn't exist")
        }
        return resourceUrl
    }
}


public enum FontError: Error {
    case cantRegisterUrl
}

public extension UIFont {
    
    static func register(from url: URL) throws {
        var error: Unmanaged<CFError>?
        guard CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) else {
            throw FontError.cantRegisterUrl
        }
    }
}
