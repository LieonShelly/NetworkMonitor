//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine

class AppleIDSignInViewModel: ObservableObject, @unchecked Sendable {
    private let service: any AppDataWithAuthorizationServiceful
    var onboardingEnabled: Bool {
        service.onboardingAccessUseCase.isEnabled
    }
    
    init(service: any AppDataWithAuthorizationServiceful) {
        self.service = service
    }
    
    func login(authorizationCode: String, identityToken: String) async throws {
        print("authorizationCode:\(authorizationCode)")
        print("identityToken:\(identityToken)")
        try await service.authUseCasse.execute(authorizationCode: authorizationCode, identityToken: identityToken)
    }
}
