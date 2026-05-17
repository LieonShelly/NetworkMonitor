//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import SVGKit
import Kingfisher
import UIKit

struct SVGIconProcessor: ImageProcessor {
    var identifier = "com.svg.icon.processor.v2"

    func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
        case .image(let image):
            return image
            
        case let .data(data):
            let imsvg = SVGKImage(data: data)
            return imsvg?.uiImage
        }
    }
}
