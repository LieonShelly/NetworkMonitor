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
        self.identifier = "com.metal.icon.processor.v3_thickness_\(thickness)"
    }
    
    func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
        case .image(let image):
            return processImage(image)
        case let .data(data):
            guard let image = UIImage(data: data) else { return nil }
            return processImage(image)
        }
    }
    
    func processImage(_ image: UIImage) -> UIImage {
        var processedImage: UIImage?
        let semaphore = DispatchSemaphore(value: 0)
        MetalImageProcessor.shared.process(image, thickness: thickness) { result in
            processedImage = result
            semaphore.signal()
        }
        let waitResult = semaphore.wait(timeout: .now() + 3.0)
        
        if waitResult == .timedOut {
            return image
        }
        return processedImage ?? image
    }
}
