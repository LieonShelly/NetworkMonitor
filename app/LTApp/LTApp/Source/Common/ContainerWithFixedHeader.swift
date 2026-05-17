//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
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
