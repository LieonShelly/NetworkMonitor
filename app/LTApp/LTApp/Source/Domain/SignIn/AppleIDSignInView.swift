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
            .textStyle(size: 36, fontFamily: .littleThing)
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
//                Task.detached {
//                    do {
//                        try await viewModel.login(authorizationCode: authorizationCode, identityToken: idTokenStr)
//                        await route()
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
           route()
           
//            Task.detached {
//                do {
//                    try await viewModel.login(authorizationCode: "", identityToken: "")
//                    await route()
//                } catch {
//                  await MainActor.run {
//                        showError = true
//                    }
//                }
//            }
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


struct TestView: View {
    var body: some View {
        ScrollView {
            
            VStack {
                offsetMonitorView
                ForEach(0 ..< 10) { index in
                    Rectangle()
                        .frame(height: 30)
                }
            }
        }
        .coordinateSpace(.named("scroll"))
       
    }
    
    var offsetMonitorView: some View {
        Color.clear
            .onGeometryChange(for: CGFloat.self, of: { $0.frame(in: .named("scroll")).minY }, action: { newValue in
                print(newValue)
            })
            .frame(height: 0)
    }
}
