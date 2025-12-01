//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import AuthenticationServices
import UIComponent


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
                        await route()
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
//       .onTapGesture {
//            Task.detached {
//                do {
//                    try await viewModel.login(authorizationCode: "cbcd2dfdea8ac4b35a6a54477a25b5fde.0.mrxxu.pTOAAFQiZvJ9LGDJSIiFBA", identityToken: "eyJraWQiOiJZUXJxZE1ENGJxIiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLmxpdHRsZS50aGluZ3MiLCJleHAiOjE3NjQ2NzMyNTQsImlhdCI6MTc2NDU4Njg1NCwic3ViIjoiMDAxNzc0LmZiNmI2MWIyOTkyZTQ2ODM4YmVlMzRlNzgxYTZhMTE0LjEwMjEiLCJjX2hhc2giOiJwQmJ3SVdrZktLcTVEMGk3S2wtV2dRIiwiZW1haWwiOiJieGJiZGR4eW40QHByaXZhdGVyZWxheS5hcHBsZWlkLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJpc19wcml2YXRlX2VtYWlsIjp0cnVlLCJhdXRoX3RpbWUiOjE3NjQ1ODY4NTQsIm5vbmNlX3N1cHBvcnRlZCI6dHJ1ZX0.l_yA5Viza9WYJtUKyG3URMnV63iK-w8VG-ddaCH9zjWIHEmVaMHDd8RabsN3acnEHEc8jh--_CV1eLJz0WxuZNMtX4QYpoPnXSTL6jbXuo3po0UNRUkh99kgDKsVZNq2Yx3Xd4lb9iFfDPURuy-v71EjLka3CRZmqU1UHznNynn-kE-X_mLBw3w3uwPCGTZiCZuEI183PaUOJJXSUs9qeirpccKdqqe2Zv5FNUrIZK_mQ-COn9Mo-0LUiHYKQyoSbgYNQRBkBscEyXu7wYOA6U6DOphKEfBiyeA5kUvUjrxSmO_B_SYkjfdu2ffz9jonKSLhk0deqqowoME0M00new")
//                    await route()
//                } catch {
//                  await MainActor.run {
//                        showError = true
//                    }
//                }
//            }
//        }
    }
    
    @MainActor
    func route() {
        if viewModel.onboardingEnabled {
            coordinator.push(PreHomeRoute.splash)
        } else {
            appCoordinator.changeRoot(
                .home(.init(overLayData: nil))
            )
        }
    }
}
