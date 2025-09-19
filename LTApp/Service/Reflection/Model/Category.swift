//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct Category: Sendable, Identifiable, Equatable {
    public var id: String
    public var title: String
    
    public  init(id: String, title: String) {
        self.id = id
        self.title = title
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.id == rhs.id
    }
}

