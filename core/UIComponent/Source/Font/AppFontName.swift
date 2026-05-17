//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
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
    case poppinsBold
    case poppinsMediumItalic
    case feltTipSeniorRegular
    case sfProRegular
    case sfProMedium
    case sfProBold
    case vividlyRegular
    case ibmPlexMonoRegular
    case dsDigital
    case littleThing
    
    var fileName: String {
        switch self {
        case .poppinsRegular:
            "Poppins-Regular"
        case .poppinsBold:
            "Poppins-Bold"
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
        case .ibmPlexMonoRegular:
            "IBMPlexMono-Regular"
        case .dsDigital:
            "DS-DIGI"
        case .littleThing:
            "TheLittleThings02"
        }
    }
    
    var fileExtension: String {
        switch self {
        case .poppinsRegular, .feltTipSeniorRegular, .vividlyRegular, .poppinsMediumItalic, .ibmPlexMonoRegular, .poppinsBold:
            return "ttf"
        case .sfProRegular, .sfProBold, .sfProMedium:
            return "OTF"
        case .dsDigital:
            return "TTF"
        case .littleThing:
            return "otf"
        }
    }
    
    var fontName: String {
        switch self {
        case .poppinsRegular:
            "Poppins-Regular"
        case .poppinsBold:
            "Poppins-Bold"
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
        case .ibmPlexMonoRegular:
            "IBMPlexMono-Regular"
        case .dsDigital:
            "DS-Digital"
        case .littleThing:
            "TheLittleThings02Regular"
        }
    }
}
