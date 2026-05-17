//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
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
