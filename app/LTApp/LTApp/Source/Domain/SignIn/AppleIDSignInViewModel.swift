//
//  LTApp, This code is protected by intellectual property rights.
//

import Combine
import AuthenticationServices
import GoogleSignIn

class AppleIDSignInViewModel: NSObject, ObservableObject, ASAuthorizationControllerDelegate, @unchecked Sendable {
    private let service: any AppDataWithAuthorizationServiceful
    var onLoginSuccess: (() -> Void)?
    
    var onboardingEnabled: Bool {
        service.onboardingAccessUseCase.isEnabled
    }
    
    init(service: any AppDataWithAuthorizationServiceful) {
        self.service = service
        GIDSignIn.sharedInstance.configure { error in
            if let error {
                debugPrint("Error configuring `GIDSignIn` for Firebase App Check: \(error)")
            }
        }
    }
    
    func loginWithApple(authorizationCode: String, identityToken: String) async throws {
        debugPrint("authorizationCode:\(authorizationCode)")
        debugPrint("identityToken:\(identityToken)")
        try await service.authUseCasse.execute(authorizationCode: authorizationCode, identityToken: identityToken)
    }
    
    func loginWihtGoogle(identityToken: String) async throws {
        debugPrint("identityToken:\(identityToken)")
        try await service.authUseCasse.executeGoogleLogin(idToken: identityToken)
    }
    
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }
        guard let idToken = credential.identityToken, let idTokenStr = String(data: idToken, encoding: .utf8) else {
            return
        }
        var authorizationCode = ""
        if let authorizationCodeData = credential.authorizationCode, let code = String(data: authorizationCodeData, encoding: .utf8) {
            authorizationCode = code
        }
        Task.detached { [weak self] in
            guard let self else { return }
            do {
                try await self.loginWithApple(authorizationCode: authorizationCode, identityToken: idTokenStr)
                await MainActor.run {
                    self.onLoginSuccess?()
                }
            } catch {
                print("Apple sign in error: \(error)")
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple sign in failed: \(error)")
    }
}
