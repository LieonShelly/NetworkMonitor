//
//  MetalIconProcessor.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/3.
//


import Kingfisher
import UIKit

struct MetalIconProcessor: ImageProcessor {
    var identifier = "com.metal.icon.processor.v2"
    let thickness: Int
    
    init(thickness: Int = 1) {
        self.thickness = thickness
        self.identifier = "com.metal.icon.processor.v3_thicknes1s_\(thickness)"
    }
    
    func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
        case .image(let image):
            return MetalImageProcessor.shared.processSync(UIImage(resource: .test), thickness: thickness) ?? image
            
        case let .data(data):
            guard let image = UIImage(data: data) else { return nil }
            return MetalImageProcessor.shared.processSync(UIImage(resource: .test), thickness: thickness) ?? image
        }
    }
}
