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
    @State private var hasAcceptedTerms: Bool = false
    @State private var termsShakeTrigger: CGFloat = 0
    
    var body: some View {
        VStack(spacing: .zero) {
            Spacer()
            VStack(spacing: 32) {
                icon
                title
            }
            Spacer()
            loginBtn
        }
        .defaultBackground()
        .toolbarVisibility(.hidden, for: .navigationBar)
        .transition(.asymmetric(insertion: .identity, removal: .opacity))
        .task {
            await viewModel.fetchData()
        }
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
        Image(.appicon)
            .resizable()
            .frame(width: 72, height: 68)
    }
    
    var title: some View {
        Text("the little things")
            .textStyle(size: 36, fontFamily: .littleThing)
    }
    
    var signInBtn: some View {
        Button {
            guard validateTermsAcceptance() else {
                return
            }
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
        VStack(spacing: .zero) {
            VStack(spacing: 16) {
                signInBtn
                googleBtn
            }
            termsAndConditions
                .padding(.top, 68)
        }
        .padding(.horizontal, 26)
        .padding(.bottom, 48)
    }
    
    var googleBtn: some View {
        Button {
            guard validateTermsAcceptance() else {
                return
            }
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

    var termsAndConditions: some View {
        HStack(alignment: .top, spacing: 6) {
            Button {
                hasAcceptedTerms.toggle()
                showError = false
            } label: {
                checkbox
            }
            .buttonStyle(.plain)
            .modifier(ShakeEffect(trigger: termsShakeTrigger))

            Text(termsAttributedString)
                .textStyle(size: 12, color: termsColor, fontFamily: .poppinsRegular)
                .lineSpacing(.zero)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 5)
    }

    var checkbox: some View {
        ZStack {
            if hasAcceptedTerms {
                RoundedRectangle(cornerRadius: 2)
                    .fill(AppColor.black)

                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(AppColor.white)
            } else {
                RoundedRectangle(cornerRadius: 2)
                    .fill(AppColor.oat)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(termsColor, lineWidth: 1)
                    )
            }
        }
        .frame(width: 16, height: 16)
        .frame(width: 24, height: 24)
        .contentShape(Rectangle())
    }

    var termsColor: Color {
        showError ? AppColor.color(hex: 0xF47B0A) : AppColor.black
    }

    var termsAttributedString: AttributedString {
        var text = AttributedString("By continuing, you agree to our Terms of Service and Privacy Policy")
        text.foregroundColor = termsColor
        text.font = AppFont.poppins(size: 12)

        if let range = text.range(of: "Terms of Service") {
            text[range].link = URL(string: "https://butternut-gate-2ce.notion.site/Terms-of-Service-3418215586fe80699ccae50e432f3cb5")
            text[range].underlineStyle = .single
        }

        if let range = text.range(of: "Privacy Policy") {
            text[range].link = URL(string: "https://butternut-gate-2ce.notion.site/Privacy-Policy-2848215586fe800fb222f18fd4f0d500")
            text[range].underlineStyle = .single
        }

        return text
    }

    func validateTermsAcceptance() -> Bool {
        guard hasAcceptedTerms else {
            showError = true
            withAnimation(.linear(duration: 0.25)) {
                termsShakeTrigger += 1
            }
            return false
        }

        showError = false
        return true
    }
    
}

private struct ShakeEffect: GeometryEffect {
    var trigger: CGFloat
    var travelDistance: CGFloat = 3
    var numberOfShakes: CGFloat = 3

    var animatableData: CGFloat {
        get { CGFloat(trigger) }
        set { trigger = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: travelDistance * sin(animatableData * .pi * numberOfShakes),
                y: 0
            )
        )
    }
}
