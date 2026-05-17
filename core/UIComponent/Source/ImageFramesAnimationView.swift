//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import SwiftUI

public struct ImageFramesAnimationView: View {
    let aniamationData: FramesAnimationData
    
    public init(aniamationData: FramesAnimationData) {
        self.aniamationData = aniamationData
    }
    
    public var body: some View {
        PhaseAnimator(0 ..< aniamationData.frames.count) { phase in
            if let imagePath = aniamationData.bundle.path(forResource: aniamationData.frames[phase], ofType: "png"),
               let uiImage = UIImage(contentsOfFile: imagePath) {
                Circle()
                    .fill(Color.clear)
                    .overlay(content: {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    })
                    .frame(width: aniamationData.frameSize.width,
                           height: aniamationData.frameSize.height)
            }
        } animation: { _ in
                .linear(duration: aniamationData.duration)
        }
    }
}

public struct FramesAnimationData : Sendable {
    public let frames: [String]
    public let bundle: Bundle
    public let duration: CGFloat
    public let frameSize: CGSize
    
    public var lastFrame: UIImage? {
        if let last = frames.last,
           let imagePath = bundle.path(forResource: last, ofType: "png"),
           let uiImage = UIImage(contentsOfFile: imagePath) {
            return uiImage
        }
        return nil
    }
}

public extension FramesAnimationData {
    static var imageBundle: Bundle {
        if let path = UIComponentModule.bundle.path(forResource: "Images.bundle", ofType: nil) {
            return Bundle(path: path) ?? .main
        }
        return .main
    }
    
    static let dripple: FramesAnimationData = .init(
        frames: ["dripper0", "dripper1", "dripper2"],
        bundle: imageBundle,
        duration: 0.5,
        frameSize: .init(width: 135, height: 165)
    )
}


public struct LocalIconLib {
    public static let fallLeave: UIImage = loadImage("fall_leaves")
    
    static func loadImage(_ name: String) -> UIImage {
        if  let imagePath = FramesAnimationData.imageBundle.path(
            forResource: name,
            ofType: "png"
        ), let uiImage = UIImage(contentsOfFile: imagePath) {
            return uiImage
        } else {
            fatalError("image not found")
        }
    }
}
