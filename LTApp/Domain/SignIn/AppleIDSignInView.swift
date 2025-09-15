//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import AuthenticationServices

struct AppleIDSignInView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @ObservedObject var viewModel: AppleIDSignInViewModel
    
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
                let userId = credential.user
                let email = credential.email
                let fullname = credential.fullName
                
                print("User ID: \(userId)")
                print("Email: \(email ?? "nil")")
                print("Full Name: \(fullname?.givenName ?? "")")
                Task.detached {
                   await viewModel.login(appleId: userId, authToken: idTokenStr)
                }
            case .failure(let error):
                break
            }
        }
        .signInWithAppleButtonStyle(.black)
        .frame(height: 54)
        .padding(.horizontal, 30)
        .padding(.bottom, 168)
        .onTapGesture {
            coordinator.goToHome()
        }
    }
}
