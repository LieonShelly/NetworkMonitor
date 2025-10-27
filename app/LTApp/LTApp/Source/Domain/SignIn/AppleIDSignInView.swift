//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import AuthenticationServices

struct AppleIDSignInView: View {
    @EnvironmentObject var coordinator: PreHomeCoordinator
    @EnvironmentObject var appCoordinator: AppCoordinator
    @ObservedObject var viewModel: AppleIDSignInViewModel
    @State var showError: Bool = false
    
    var body: some View {
        VStack(spacing: .zero) {
            Spacer()
            VStack(spacing: 58) {
                icon
                title
            }
           Spacer()
            signInBtn
        }
        .defaultBackground()
        .toolbarVisibility(.hidden, for: .navigationBar)
        .transition(.asymmetric(insertion: .identity, removal: .opacity))
    }
    
    var icon: some View {
        Image(.sun)
            .resizable()
            .frame(width: 45, height: 45)
    }
    
    var title: some View {
        Text("the little things")
            .font(AppFont.feltTipSenior(size: 48, fontWeight: .regular))
            .foregroundStyle(AppColor.textPrimary)
    }
    
    var signInBtn: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: { result in
            switch result {
            case .success(let authResult):
                guard let credential = authResult.credential as? ASAuthorizationAppleIDCredential else {
                    return
                }
                guard let idToken = credential.identityToken, let idTokenStr = String(data: idToken, encoding: .utf8) else {
                    return
                }
                var authorizationCode = ""
                if let authorizationCodeData = credential.authorizationCode, let code = String(data: authorizationCodeData, encoding: .utf8) {
                    authorizationCode = code
                }
                Task.detached {
                    do {
                        try await viewModel.login(authorizationCode: authorizationCode, identityToken: idTokenStr)
                        await gotoSplash()
                    } catch {
                        
                    }
                   
                }
            case let .failure(error):
                print(error)
            }
        }
        .signInWithAppleButtonStyle(.black)
        .frame(height: 54)
        .padding(.horizontal, 30)
        .padding(.bottom, 168)
       /* .onTapGesture {
            Task.detached {
                do {
                    try await viewModel.login(authorizationCode: "c4149da5449004dcf95084633a4c67e5d.0.srxxu.WvnVJvs8bxJo4g6MyutZLw", identityToken: "eyJraWQiOiJVYUlJRlkyZlc0IiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLmxpdHRsZS50aGluZ3MiLCJleHAiOjE3NjA1OTQ0NjMsImlhdCI6MTc2MDUwODA2Mywic3ViIjoiMDAxNzc0LmZiNmI2MWIyOTkyZTQ2ODM4YmVlMzRlNzgxYTZhMTE0LjEwMjEiLCJjX2hhc2giOiJfYUt0NHdIYXd6bG14VHA2TnpoMkZBIiwiZW1haWwiOiJieGJiZGR4eW40QHByaXZhdGVyZWxheS5hcHBsZWlkLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJpc19wcml2YXRlX2VtYWlsIjp0cnVlLCJhdXRoX3RpbWUiOjE3NjA1MDgwNjMsIm5vbmNlX3N1cHBvcnRlZCI6dHJ1ZX0.gCj0FNA5chSSaBaoEtFQoEoleAe7j4EJAwLP18ap_8ypM90iASb07R33dxi-yP1y3evLbxyZuwMc582zBqe5clXPAims5aVhbVoN23kZiZa1KFmRI6EevPwct5_NcwZI7GKZZXkI4kA-_3EXVuXO7kuQP4BEj7sAklQ11zr839xM7Ag_m37ivYjMOoRkrFG1UxTOpqYTTXBASl_E7yyClCTxIbG354GDiO2eTkD8F0YiclwL_DIeLOqtv0YqasKbq7NB8Nv7C92SZkNpz3zCCRjebK8yjM1LYigoGL3oDFzUmYUJrvc0HNQaUsxqAWAGgxTpJIB2ie2REp9k3-qbHw")
                    await gotoSplash()

                } catch {
                  await MainActor.run {
                        showError = true
                    }
                }
            }
        } */
    }
    
    @MainActor
    func gotoSplash() {
        coordinator.push(PreHomeRoute.splash)
    }
}
