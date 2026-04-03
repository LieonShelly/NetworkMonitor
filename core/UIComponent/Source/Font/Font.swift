//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

public enum AppFont {
    case heading
    case title
    case section
    case subSection
    case subTitle
    case body
    case caption
    case annotation
    
    var font: Font {
        switch self {
        case .heading:
            AppFont.ltFont(size: 24, fontWeight: .regular)
        case .title:
            AppFont.ltFont(size: 18, fontWeight: .regular)
        case .section:
            AppFont.ltFont(size: 14, fontWeight: .regular)
        case .subSection:
            AppFont.ltFont(size: 10, fontWeight: .regular)
        case .subTitle:
            AppFont.poppins(size: 16, fontWeight: .regular)
        case .body:
            AppFont.poppins(size: 14, fontWeight: .regular)
        case .caption:
            AppFont.poppins(size: 12, fontWeight: .regular)
        case .annotation:
            AppFont.ibmPlexMono(size: 12, fontWeight: .regular)
        }
    }
}

extension AppFont {
    
    public static func ltFont(size: CGFloat, fontWeight: AppFontWeight = .regular) -> Font {
        switch fontWeight {
        case .regular:
            return Font.custom(AppFontType.littleThing.fontName, size: size)
        case .medium, .bold:
            return Font.custom(AppFontType.littleThing.fontName, size: size)
        case .heavy:
            return Font.custom(AppFontType.littleThing.fontName, size: size)
        case .mediumItalic:
            return Font.custom(AppFontType.littleThing.fontName, size: size)
        }
    }
    
    public static func dsDigtal(size: CGFloat, fontWeight: AppFontWeight = .regular) -> Font {
        switch fontWeight {
        case .regular:
            return Font.custom(AppFontType.dsDigital.fontName, size: size)
        case .medium, .bold:
            return Font.custom(AppFontType.feltTipSeniorRegular.fontName, size: size)
        case .heavy:
            return Font.custom(AppFontType.feltTipSeniorRegular.fontName, size: size)
        case .mediumItalic:
            return Font.custom(AppFontType.poppinsMediumItalic.fontName, size: size)
        }
    }
    
    public static func feltTipSenior(size: CGFloat, fontWeight: AppFontWeight = .regular) -> Font {
        switch fontWeight {
        case .regular:
            return Font.custom(AppFontType.feltTipSeniorRegular.fontName, size: size)
        case .medium, .bold:
            return Font.custom(AppFontType.feltTipSeniorRegular.fontName, size: size)
        case .heavy:
            return Font.custom(AppFontType.feltTipSeniorRegular.fontName, size: size)
        case .mediumItalic:
            return Font.custom(AppFontType.poppinsMediumItalic.fontName, size: size)
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
        case .mediumItalic:
            return UIFont(descriptor: .init(name: AppFontType.poppinsMediumItalic.fontName, size: size), size: size)
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
        case .mediumItalic:
            return Font.custom(AppFontType.poppinsMediumItalic.fontName, size: size)
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
        case .mediumItalic:
            return Font.custom(AppFontType.poppinsMediumItalic.fontName, size: size)
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
        case .mediumItalic:
            return Font.custom(AppFontType.poppinsMediumItalic.fontName, size: size)
        }
    }
    
    public static func ibmPlexMono(size: CGFloat, fontWeight: AppFontWeight = .regular) -> Font {
        switch fontWeight {
        case .regular:
            return Font.custom(AppFontType.ibmPlexMonoRegular.fontName, size: size)
        case .medium:
            return Font.custom(AppFontType.ibmPlexMonoRegular.fontName, size: size)
        case .bold:
            return Font.custom(AppFontType.ibmPlexMonoRegular.fontName, size: size)
        case .heavy:
            return Font.custom(AppFontType.ibmPlexMonoRegular.fontName, size: size)
        case .mediumItalic:
            return Font.custom(AppFontType.ibmPlexMonoRegular.fontName, size: size)
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
        case .mediumItalic:
            return UIFont(descriptor: .init(name: AppFontType.poppinsMediumItalic.fontName, size: size), size: size)
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
