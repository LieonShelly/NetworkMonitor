//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public enum AppFontWeight {
    case regular
    case bold
    case heavy
}

public enum AppFontType: String, CaseIterable {
    case poppinsRegular
    case feltTipSeniorRegular
    case sfProRegular
    case sfProBold
    
    var fileName: String {
        switch self {
        case .poppinsRegular:
            "Poppins-Regular"
        case .feltTipSeniorRegular:
            "FeltTipSeniorRegular"
        case .sfProRegular:
            "SFPRODISPLAYREGULAR"
        case .sfProBold:
            "SFPRODISPLAYBOLD"
        }
    }
    
    var fileExtension: String {
        switch self {
        case .poppinsRegular, .feltTipSeniorRegular:
            return "ttf"
        case .sfProRegular, .sfProBold:
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
        }
    }
}
