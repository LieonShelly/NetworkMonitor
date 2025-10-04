//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

extension View {
    func defaultNavigationBar(_ title: String, backBtnAction: (() -> Void)? = nil) -> some View {
        self
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        backBtnAction?()
                    } label: {
                        Image(.back)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .textStyle(size: 36)
                }
            }
    }
}
