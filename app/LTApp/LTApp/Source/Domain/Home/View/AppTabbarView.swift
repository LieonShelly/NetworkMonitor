//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import SwiftUI

struct AppTabbarView: View {
    let item: AppTabbarItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                item.deselectedIcon
                    .opacity(1 - item.selectedOpacity)
                item.selectedIcon
                    .opacity(item.selectedOpacity)
            }
        }
    }
}
