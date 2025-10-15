
//
//  LTApp, This code is protected by intellectual property rights.
//

import Foundation

public struct Question: Sendable, Equatable, Hashable {
    public var id: String
    var title: String
    var pinned: Bool = false
    
    public init(id: String, title: String, pinned: Bool = false) {
        self.id = id
        self.title = title
        self.pinned = pinned
    }
    
    
}
