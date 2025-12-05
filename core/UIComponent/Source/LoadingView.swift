//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import Lottie

public struct LoadingView: View {
    
    public init() {}
    
    public var body: some View {
        VStack {
            LottieView(animation: .named("knitting", bundle: UIComponentModule.lottieBundle))
                .playing(loopMode: .loop)
        }
    }
}
