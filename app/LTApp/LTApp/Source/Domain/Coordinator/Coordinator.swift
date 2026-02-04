//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

protocol Route: Hashable, Sendable { }

@MainActor
protocol Coordinator: AnyObject, Sendable {
    var path: NavigationPath { get set }
    
    var children: [any Coordinator] { get set }
    
    func build(_ route: any Route) -> AnyView?
    
    func push( _ route: any Route)
    
    func pop()
    
    func popToRoot()
}


extension Coordinator {
    func buildChild(route: any Route) -> AnyView? {
        for child in self.children {
            guard let childView = child.build(route) else {
                continue
            }
            return childView
        }
        return nil
    }
    
    
    func addChild(_ coordinator: any Coordinator, isSameStack: Bool = true) {
        coordinator.path = path
        if isSameStack {
            children.append(coordinator)
        }
    }

    
    func push(_ route: any Route) {
        path.append(route)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
}
