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
       .onTapGesture {
            Task.detached {
                do {
                    try await viewModel.login(authorizationCode: "c8c8dbfc39494450eaa3d3ecdde6f381f.0.srxxu.mebgNRevX0x8XD9i9JRq2Q", identityToken: "eyJraWQiOiJIdlZJNkVzWlhKIiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLmxpdHRsZS50aGluZ3MiLCJleHAiOjE3NjkwNjMwNjksImlhdCI6MTc2ODk3NjY2OSwic3ViIjoiMDAxNzc0LmZiNmI2MWIyOTkyZTQ2ODM4YmVlMzRlNzgxYTZhMTE0LjEwMjEiLCJjX2hhc2giOiJyUGZjRktNTHJrdEpIOENLWGFQdTBBIiwiZW1haWwiOiJieGJiZGR4eW40QHByaXZhdGVyZWxheS5hcHBsZWlkLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJpc19wcml2YXRlX2VtYWlsIjp0cnVlLCJhdXRoX3RpbWUiOjE3Njg5NzY2NjksIm5vbmNlX3N1cHBvcnRlZCI6dHJ1ZX0.hEFn2105mX03fKUq8gKpiSLIHLTwF3Z5EDnroy0ih28WsevP2G5htqZEMS59xjkRMJ2pNAJDntlSXAGDweKplCeDnxv3d3UifNP75_qUjHVq_gch15v-PNagBxBLyG6Gvx06oxsjAFv4RH75SGyEsjcsgFQwbwO4ABD3ZurgspzeowTRRyOiCMrub3TTSYnpIF9RgxWvfo4ohyGDTEB8OmPgPOw0uju8j6EzjXMxqS23VWTCI27jPCzazeSFAAuY_dRGSsJGnUFrhhnLILda034nXz-QM-8WXoJRdsYqnSMbjpZ5Ql8kZmJrQYFkt2FNSUxac6dm-YkUUefpFXIWyg")
                    await route()
                } catch {
                  await MainActor.run {
                        showError = true
                    }
                }
            }
        }
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
