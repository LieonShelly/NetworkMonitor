//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

protocol Route: Hashable, Sendable { }

@MainActor
protocol Coordinator: Sendable {
    var path: NavigationPath { get set }
    
    func build(_ route: any Route) -> AnyView
    
    func start()
    
    func push( _ route: any Route)
    
    func pop()
    
    func popToRoot()
}
