//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent

struct CalendarSlashLine: View {
    var color: Color = AppColor.color(hex: 0xCDCDCD)
    let lineWidth: CGFloat = 0.5
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: width, y: height))
            }
            .stroke(color)
        }
        .allowsHitTesting(false)
    }
}
