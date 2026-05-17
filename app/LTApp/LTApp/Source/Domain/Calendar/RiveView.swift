//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import SwiftUI
import RiveRuntime
import Common

struct RiveView: View {
    @State var rive: Rive?
    private let resouce: RiveFileType
    
    init(resouce: RiveFileType) {
        self.resouce = resouce
    }
    
    
    var body: some View {
        if let rive {
            RiveUIViewRepresentable(rive: rive)
        } else {
            Color.clear
                .onFirstAppear {
                    Task {
                        let resource: any RiveResourceType = InjectionValues.resolve()
                        let file = try await resource.file(type: resouce)
                        let loaded = try await Rive(file: file, dataBind: .auto)
                        await MainActor.run {
                            self.rive = loaded
                        }
                    }
                }
        }
    }
}
