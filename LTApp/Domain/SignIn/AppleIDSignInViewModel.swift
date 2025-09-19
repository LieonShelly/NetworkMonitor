//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine

class AppleIDSignInViewModel: ObservableObject, @unchecked Sendable {
    private let service: any AppDataWithAuthorizationServicefull
    
    init(service: any AppDataWithAuthorizationServicefull) {
        self.service = service
    }
    
    func login(authorizationCode: String, identityToken: String) async {
        do {
           let user = try await service.authUseCasse.execute(authorizationCode: authorizationCode, identityToken: identityToken)
            print(user)
        } catch {
            print("error:\(error)")
        }
    }
}
