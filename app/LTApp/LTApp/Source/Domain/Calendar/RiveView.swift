//
//  RiveView.swift
//  LTApp
//
//  Created by 李仁军 on 2026/4/27.
//

import SwiftUI
import RiveRuntime
import LTCommon

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
