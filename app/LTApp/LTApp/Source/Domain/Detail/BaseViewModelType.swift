//
//  BaseViewModelType.swift
//  LTApp
//
//  Created by Renjun Li on 2026/1/21.
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
