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
                print("authorizationCode:\(authorizationCode)")
                print("idTokenStr:\(idTokenStr)")
//                Task.detached {
//                    do {
//                        try await viewModel.login(authorizationCode: authorizationCode, identityToken: idTokenStr)
//                        await gotoSplash()
//                    } catch {
//                        
//                    }
//                   
//                }
            case let .failure(error):
                print(error)
            }
        }
        .signInWithAppleButtonStyle(.black)
        .frame(height: 54)
        .padding(.horizontal, 30)
        .padding(.bottom, 168)
        .onTapGesture {
            Task.detached {
                do {
                    try await viewModel.login(authorizationCode: "c86413f37df9f420485c7431ec78b727e.0.rrxxu.Q54tqIH36av8xNmRMnuZKw", identityToken: "eyJraWQiOiJiRnd6bGVSOHRmIiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLmxpdHRsZS50aGluZ3MiLCJleHAiOjE3NTk1NjkwNDcsImlhdCI6MTc1OTQ4MjY0Nywic3ViIjoiMDAxNzc0LmZiNmI2MWIyOTkyZTQ2ODM4YmVlMzRlNzgxYTZhMTE0LjEwMjEiLCJjX2hhc2giOiJDYzZWQ2lQZk9pWWwzUnNheW1yM0hnIiwiZW1haWwiOiJieGJiZGR4eW40QHByaXZhdGVyZWxheS5hcHBsZWlkLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJpc19wcml2YXRlX2VtYWlsIjp0cnVlLCJhdXRoX3RpbWUiOjE3NTk0ODI2NDcsIm5vbmNlX3N1cHBvcnRlZCI6dHJ1ZX0.TjMlzGTbhW4z_hhOOFgDYNQS4iSS0xd0GXf4cHvEdHCtbi-z8hQAxV4TmjzRHO86kxndArnYVJwtLXdAMh-Jg6EnwKXq_U6l-sXS3IKsyWn6zPvwVeNDtqYgcTFPRyCnodAZ4ukJv3FbF4yzlPqOFNXC5Q-bnlqwLIP74Yy4bIWV1gjwJuXr5246fDrUFBe61XAwJfHazyuljiiXJZzdWWJjScIQQMpeNXuyCTJqr6px1xl5egwfmIrLyvKt53KSoBYELu7NzPTg1zk3qUmIlGLAScpsKUjhaI2q7lw-q3Ku08HZk17ckHhf2noEsIiLjSptSsvujHJ2il2YjTWyew")
                    await gotoSplash()

                } catch {
                  await MainActor.run {
                        showError = true
                    }
                }
            }
        }
    }
    
    @MainActor
    func gotoSplash() {
        coordinator.push(PreHomeRoute.splash)
    }
}
