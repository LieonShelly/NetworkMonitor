//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import AuthenticationServices
import UIComponent
import GoogleSignIn

struct SignInView: View {
    @EnvironmentObject var coordinator: PreHomeCoordinator
    @EnvironmentObject var appCoordinator: AppCoordinator
    @ObservedObject var viewModel: SignInViewModel
    @State var showError: Bool = false
    
    var body: some View {
        VStack(spacing: .zero) {
            Spacer()
            VStack(spacing: 58) {
                icon
                title
            }
            Spacer()
            loginBtn
        }
        .defaultBackground()
        .toolbarVisibility(.hidden, for: .navigationBar)
        .transition(.asymmetric(insertion: .identity, removal: .opacity))
        .onFirstAppear {
            viewModel.onLoginSuccess = { [weak coordinator, weak appCoordinator] in
                guard let coordinator, let appCoordinator else { return }
                if viewModel.onboardingEnabled {
                    coordinator.push(PreHomeRoute.splash)
                } else {
                    appCoordinator.changeRoot(.home(.init()))
                }
            }
        }
    }
    
    var icon: some View {
        Image(.sun)
            .resizable()
            .frame(width: 45, height: 45)
    }
    
    var title: some View {
        Text("the little things")
            .textStyle(size: 36, fontFamily: .littleThing)
    }
    
    var signInBtn: some View {
        Button {
//            Task {
//                try? await viewModel.loginWithApple(authorizationCode: "", identityToken: "")
//            }
            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.fullName, .email]
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = viewModel
            controller.performRequests()
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "apple.logo")
                    .renderingMode(.template)
                    .foregroundStyle(AppColor.white)
                    .font(.system(size: 19, weight: .semibold))
                
                Text("Sign in with Apple")
                    .textStyle(size: 19, color: AppColor.white, fontFamily: .sfProBold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(AppColor.black)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
    
    var rootViewController: UIViewController? {
        return UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .compactMap { $0 as? UIWindowScene }
            .compactMap { $0.keyWindow }
            .first?.rootViewController
    }
    
    var loginBtn: some View {
        VStack(spacing: 16) {
            signInBtn
            googleBtn
        }
        .padding(.horizontal, 26)
        .padding(.bottom, 40)
    }
    
    var googleBtn: some View {
        Button {
            guard let rootViewController = self.rootViewController else {
                return
            }
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
                guard let result else {
                    print("Error signing in: \(String(describing: error))")
                    return
                }
                guard let idToken = result.user.idToken?.tokenString else {
                    return
                }
                Task.detached {
                   try? await viewModel.loginWihtGoogle(identityToken: idToken)
                }
            }
        } label: {
            HStack(spacing: 5) {
                Image(.google)
                    .resizable()
                    .frame(width: 22.8, height: 22.8)
                Text("Sign in with Google")
                    .textStyle(size: 19, color: AppColor.greyDark, fontFamily: .sfProBold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(AppColor.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(AppColor.color(hex: 0x1D1D1D), lineWidth: 1)
            )
        }
    }
    
    @MainActor
    func route() {
        if viewModel.onboardingEnabled {
            coordinator.push(PreHomeRoute.splash)
        } else {
            appCoordinator.changeRoot(
                .home(.init())
            )
        }
    }
    
}
