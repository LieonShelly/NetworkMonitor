//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct AppTabbarView: View {
    let icon: Image
    let normalColor: Color
    let selectedColor: Color
    let selectedOpacity: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                icon.tint(normalColor)
                    .opacity(1 - selectedOpacity)
                icon.tint(selectedColor)
                    .opacity(selectedOpacity)
            }
        }
    }
}
