//
//  ContainerWithFixedHeader.swift
//  LTApp
//
//  Created by 李仁军 on 2026/4/23.
//

import SwiftUI

struct ContainerWithFixedHeader<Child: View>: View {
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    var childbuilder: () -> Child
    
    init( @ViewBuilder childbuilder: @escaping () -> Child) {
        self.childbuilder = childbuilder
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            FixedHeader(title: "", backAction: {
                homeCoordinator.pop()
            })
            childbuilder()
        }
    }
}
