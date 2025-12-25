//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public enum AppFontWeight {
    case regular
    case medium
    case bold
    case heavy
    case mediumItalic
}

public enum AppFontType: String, CaseIterable {
    case poppinsRegular
    case poppinsMediumItalic
    case feltTipSeniorRegular
    case sfProRegular
    case sfProMedium
    case sfProBold
    case vividlyRegular
    
    var fileName: String {
        switch self {
        case .poppinsRegular:
            "Poppins-Regular"
        case .feltTipSeniorRegular:
            "FeltTipSeniorRegular"
        case .sfProRegular:
            "SFPRODISPLAYREGULAR"
        case .sfProMedium:
            "SFPRODISPLAYMEDIUM"
        case .sfProBold:
            "SFPRODISPLAYBOLD"
        case .vividlyRegular:
            "VividlyRegular"
        case .poppinsMediumItalic:
            "Poppins-MediumItalic"
        }
    }
    
    var fileExtension: String {
        switch self {
        case .poppinsRegular, .feltTipSeniorRegular, .vividlyRegular, .poppinsMediumItalic:
            return "ttf"
        case .sfProRegular, .sfProBold, .sfProMedium:
            return "OTF"
        }
    }
    
    var fontName: String {
        switch self {
        case .poppinsRegular:
            "Poppins-Regular"
        case .feltTipSeniorRegular:
            "FeltTipSenior"
        case .sfProRegular:
            "SFProDisplay-Regular"
        case .sfProBold:
            "SFProDisplay-Bold"
        case .sfProMedium:
            "SFProDisplay-Medium"
        case .vividlyRegular:
            "Vividly-Regular"
        case .poppinsMediumItalic:
            "Poppins-MediumItalic"
        }
    }
}
