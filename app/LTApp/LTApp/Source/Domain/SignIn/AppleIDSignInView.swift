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
                        await gotoSplash()
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
       /* .onTapGesture {
            Task.detached {
                do {
                    try await viewModel.login(authorizationCode: "ca956246d14cb4840bf2181e6f41b5b28.0.rrxxu.Ciodj8mvlmOmYohAG6vn7Q", identityToken: "eyJraWQiOiJVYUlJRlkyZlc0IiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLmxpdHRsZS50aGluZ3MiLCJleHAiOjE3NjM1NDgzOTQsImlhdCI6MTc2MzQ2MTk5NCwic3ViIjoiMDAxNzc0LmZiNmI2MWIyOTkyZTQ2ODM4YmVlMzRlNzgxYTZhMTE0LjEwMjEiLCJjX2hhc2giOiJWaldqV3lvY0Q3YmJMM0U2UE9lUFV3IiwiZW1haWwiOiJieGJiZGR4eW40QHByaXZhdGVyZWxheS5hcHBsZWlkLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJpc19wcml2YXRlX2VtYWlsIjp0cnVlLCJhdXRoX3RpbWUiOjE3NjM0NjE5OTQsIm5vbmNlX3N1cHBvcnRlZCI6dHJ1ZX0.N4Elie6rxZOh1PHGuQLtXY7TaRy9QIrszEVactkPDVFT0XzzgKSWjAmuxPtBeW-YfdkEeVdCQoD4P9m17DwckqgOm37I41WwuPS-mQc9OW53hItOGdDxQOP_igODDU5COlxup6nebtcHri3SIr3AvzljK5Zgh2ze5FmkHO82D1eUKtK2owLgggYu_EU_NAzFm9KdxT_191R2-M7Ug0zpDmNzl9SJuRRzuOPed33QBVUaIRDlQaaOPEsqm2fUgtejIE8shgT6mLnfmUKS-M0lhp8ECGtmOIvYTVsG2L-7tIVHO_m6BJl4CapnD13MhAlUKn8BxkYnG49GXIUtpAHw7w")
                    await gotoSplash()

                } catch {
                  await MainActor.run {
                        showError = true
                    }
                }
            }
        } */
    }
    
    @MainActor
    func gotoSplash() {
        coordinator.push(PreHomeRoute.splash)
    }
}
