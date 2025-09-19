//
//  LTApp, This code is protected by intellectual property rights.
//


import Foundation
import Combine

class SessionMangaer: ObservableObject, TokenProvider, @unchecked Sendable {
    
    @Published var accessToken: String? = nil
    var refreshToken: String? = nil
    
    func updateTokens(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    
    func clear() {
        accessToken = nil
        refreshToken = nil
        
    }
}
