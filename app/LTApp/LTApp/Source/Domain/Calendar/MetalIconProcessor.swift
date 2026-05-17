//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//


import Kingfisher
import UIKit

struct MetalIconProcessor: ImageProcessor {
    var identifier = "com.metal.icon.processor.v2"
    let thickness: Int
    
    init(thickness: Int = 1, identifier: String? = nil) {
        self.thickness = thickness
        self.identifier = identifier ?? "com.metal.icon.processor.v3_thickness_\(thickness)"
    }
    
    func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
        case .image(let image):
            return MetalImageProcessor.shared.processSync(image, thickness: thickness) ?? image
            
        case let .data(data):
            guard let image = UIImage(data: data) else { return nil }
            return MetalImageProcessor.shared.processSync(image, thickness: thickness) ?? image
        }
    }
}
