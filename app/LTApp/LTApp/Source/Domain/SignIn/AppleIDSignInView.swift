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
            Task.detached {
                do {
                    try await viewModel.login(authorizationCode: "c8fa3d210869a41a8a8988bc2b3127b7c.0.prxxu.iO7weocGaCTxBEkWY27qgw", identityToken: "eyJraWQiOiJZUXJxZE1ENGJxIiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLmxpdHRsZS50aGluZ3MiLCJleHAiOjE3NzQyNTg0MTcsImlhdCI6MTc3NDE3MjAxNywic3ViIjoiMDAxNzc0LmZiNmI2MWIyOTkyZTQ2ODM4YmVlMzRlNzgxYTZhMTE0LjEwMjEiLCJjX2hhc2giOiJzakQ4OFJyTHZUREZyZ2VzcnlzREZBIiwiZW1haWwiOiJieGJiZGR4eW40QHByaXZhdGVyZWxheS5hcHBsZWlkLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJpc19wcml2YXRlX2VtYWlsIjp0cnVlLCJhdXRoX3RpbWUiOjE3NzQxNzIwMTcsIm5vbmNlX3N1cHBvcnRlZCI6dHJ1ZX0.ESTmxIFaZeG4l3EmTTUyOlUTy7dfYQ75nHvCF2NqnjJw1SdlKPxcH093SCR-7aeZNzHcW_112IdorAoGHkgI0J9_UbKfOwhefWcmpRe_JZADx3gkbpFkQC4RKWnPFgZHD4btT4tIy5HuARcSF5m2S6g5lNYhrEUKti4gNTTzRSJphbSz4WFq8ef_D6RXgSZKj1d4jV7yE5zZ9LuG4qmv6BHr4EmNDRE9pr6UBe6drMTr0-QYEoXaeaCeE5j5e3PSMOgof9TZWpig6LM2Vgpb2h1A2QQk2NJlpG8tw1pUSkkDht3fFb6dYJ8QOceat_IcH9ihFuifE5QEYhAKPJAOGw")
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
