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
//                    try await viewModel.login(authorizationCode: "c58988adf6c7f4b868d7e60456f2983bd.0.mrxxu.BxSBveMcVjRS9JOOBhBfew", identityToken: "eyJraWQiOiJIdlZJNkVzWlhKIiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLmxpdHRsZS50aGluZ3MiLCJleHAiOjE3NjcwNjI3ODIsImlhdCI6MTc2Njk3NjM4Miwic3ViIjoiMDAxNzc0LmZiNmI2MWIyOTkyZTQ2ODM4YmVlMzRlNzgxYTZhMTE0LjEwMjEiLCJjX2hhc2giOiJraEdranlmWV90QUh2MnpRTVdKQUpnIiwiZW1haWwiOiJieGJiZGR4eW40QHByaXZhdGVyZWxheS5hcHBsZWlkLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJpc19wcml2YXRlX2VtYWlsIjp0cnVlLCJhdXRoX3RpbWUiOjE3NjY5NzYzODIsIm5vbmNlX3N1cHBvcnRlZCI6dHJ1ZX0.iorfRfas_m0C1GpesVlHKBXS0wCFrmXVpamhG4PDxO7GJscFaE40fTCyQ76zamlWQdznsm9D1ELQGRuIEo50-fRXk20WoOFTCkQ-Gv4sfw32KBfylvvrSgwkPnRodkIq9nRAtguHI8QzPmy18v86jzIqxV8iUQi5nRUxrplmOSU4Cgo3UiJIA3QklN5wgaq93O7E3QrPyJl8wouTxC27Pl4BzfeIMz1_YxZG7n9u6Chb3i9rVmeTYKunRJ9mvExdBxqMidgBenj5RTuDMlcau8lDd6YCvANaK9fGg5thixSCsGO6MpuQQWY2XrAViO5b9jS-U1QYS43feGA9TsX6Ow")
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
