
//
//  LTApp, This code is protected by intellectual property rights.
//


import Foundation

public struct Question: Sendable {
    var id: String
    var title: String
    
    public  init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}
