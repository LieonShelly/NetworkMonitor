//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import SwiftUI
import Foundation

struct AppTabbarItem: Identifiable {
    var id = UUID().uuidString
    let selectedIcon: Image
    let deselectedIcon: Image
    
    var selectedOpacity: CGFloat
    var isSelected: Bool {
        selectedOpacity >= 1.0
    }
}
