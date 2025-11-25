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
//                    try await viewModel.login(authorizationCode: "cbef6e869cca045efa2b9b1111213e777.0.mrxxu.bGfBd5VRQw6F-_8qRSzDBA", identityToken: "eyJraWQiOiJVYUlJRlkyZlc0IiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLmxpdHRsZS50aGluZ3MiLCJleHAiOjE3NjQxMjg0MjMsImlhdCI6MTc2NDA0MjAyMywic3ViIjoiMDAxNzc0LmZiNmI2MWIyOTkyZTQ2ODM4YmVlMzRlNzgxYTZhMTE0LjEwMjEiLCJjX2hhc2giOiJTc3pma2hDWXhtaDBvZDNxSHZTVERnIiwiZW1haWwiOiJieGJiZGR4eW40QHByaXZhdGVyZWxheS5hcHBsZWlkLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJpc19wcml2YXRlX2VtYWlsIjp0cnVlLCJhdXRoX3RpbWUiOjE3NjQwNDIwMjMsIm5vbmNlX3N1cHBvcnRlZCI6dHJ1ZX0.ZqM3PeMBqbbnr4Y5aC5ELeLlBk_JFn222ptTCSBgCvGCI7ZVcctVTFXRAlPLjYVmZtldpqSkTDxOxdrBY_24mS3RxacgCuHrGB_5JMl_Wrmqgvs7saW2nl7-pOD-Db6HB8yRJN75xj053pL5fshSE02ZEl_XJjQ5f6mXM68jhZbezUKKytmdY0SF8rrVa3_2s3U4i2QLD3dMM_UZfL6-nY5y_cPn0CzyoXiY1mYYXoLe_4PCTDoke2PheRxxDfhrTQ8zHELS8Ghqps5jCC-YlekmAFWpZ-fziJ6qXFpS3zNPc3tz9S3UmJtNANPqIaNpeF_cB3EN5Sa6-AFFuy9lXA")
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
