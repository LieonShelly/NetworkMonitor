//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import Foundation

struct AppTabbarItem: Identifiable {
    var id = UUID().uuidString
    let icon: Image
    let normalColor: Color
    let selectedColor: Color
    var selectedOpacity: CGFloat
    var isSelected: Bool {
        selectedOpacity >= 1.0
    }
}
