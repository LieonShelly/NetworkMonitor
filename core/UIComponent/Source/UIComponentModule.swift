//
//  UIComponentModule.swift
//  UIComponent
//
//  Created by Renjun Li on 2025/10/30.
//


import Foundation

public class UIComponentModule {
    
    static let bundle = Bundle(for: UIComponentModule.self)
    
    static var lottieBundle: Bundle {
        if let path = UIComponentModule.bundle.path(forResource: "Lottie.bundle", ofType: nil) {
            return Bundle(path: path) ?? bundle
        }
        return bundle
    }

}
