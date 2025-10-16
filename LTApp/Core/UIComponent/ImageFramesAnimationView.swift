//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct ImageFramesAnimationView: View {
    let aniamationData: FramesAnimationData
    
    var body: some View {
        PhaseAnimator(0 ..< aniamationData.frames.count) { phase in
            if let imagePath = aniamationData.bundle.path(forResource: aniamationData.frames[phase], ofType: "png"),
               let uiImage = UIImage(contentsOfFile: imagePath) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: aniamationData.frameSize.width,
                           height: aniamationData.frameSize.height)
            }
        } animation: { _ in
                .linear(duration: aniamationData.duration)
        }
    }
}

struct FramesAnimationData {
    let frames: [String]
    let bundle: Bundle
    let duration: CGFloat
    let frameSize: CGSize
}


extension FramesAnimationData {
    static var imageBundle: Bundle {
        if let path = Bundle.main.path(forResource: "Images.bundle", ofType: nil) {
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
