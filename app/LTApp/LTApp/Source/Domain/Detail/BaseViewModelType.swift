//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import SwiftUI

protocol BaseViewModelType: AnyObject {
    var subPageRoute: InnerPageRouteState { get set }
    
    func route(_ route: InnerPageRouteState)
}


extension BaseViewModelType {
    
    @MainActor
    func route(_ route: InnerPageRouteState) {
        guard subPageRoute != route else { return }
        withAnimation(.easeInOut) {
            subPageRoute = route
        }
    }
}
