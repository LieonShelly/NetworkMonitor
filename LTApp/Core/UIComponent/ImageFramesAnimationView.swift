//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct ImageFramesAnimationView: View {
    let frames: [String]
    let bundle: Bundle
    @State var trigger = UUID()
    
    init(frames: [String], bundle: Bundle) {
        self.frames = frames
        self.bundle = bundle
    }
    
    var body: some View {
        PhaseAnimator([0, 1, 2]) { phase in
            if let imagePath = bundle.path(forResource: frames[phase], ofType: "png"),
               let uiImage = UIImage(contentsOfFile: imagePath) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 134, height: 165)
            }
            
        } animation: { _ in
                .linear(duration: 0.5)
        }

    }
}
