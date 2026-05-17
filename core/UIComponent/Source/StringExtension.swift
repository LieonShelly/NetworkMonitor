//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import UIKit

public extension String {
    func height(font: UIFont, containerW: CGFloat) -> CGFloat {
        let attributeText = NSMutableAttributedString(string: self)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        attributeText.addAttributes([
            .font: font,
            .paragraphStyle: paragraphStyle
        ], range: NSRange(location: 0, length: count)
        )
       return attributeText.boundingRect(
            with: CGSize(width: containerW, height: .infinity),
            options: .usesDeviceMetrics,
            context: nil
        ).height
    }
}
