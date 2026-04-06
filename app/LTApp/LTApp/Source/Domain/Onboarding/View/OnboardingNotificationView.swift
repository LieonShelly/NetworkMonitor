//
//  OnboardingNotificationView.swift
//  LTApp
//
//  Created by Renjun Li on 2026/4/4.
//

import SwiftUI
import UIComponent
import UserNotifications

struct OnboardingNotificationView: View {
    @StateObject var viewModel: NotificationViewModel
    let dismissed: () -> Void
    
    init(viewModel: NotificationViewModel,
         dismissed: @escaping () -> Void) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.dismissed = dismissed
    }
    
    var body: some View {
        VStack {
            headerView
            Spacer()
            loadingView
            
            Spacer()
            Text("A unique icon is being created based on what you wrote, we will let you know when it’s ready! ")
                .textStyle(font: .body, color: AppColor.color(hex: 0x323232))
                .padding(.bottom, 16)
                .padding(.horizontal, 32)
            
            VStack(spacing: 16) {
                DefaultAppButton(title: "Notify me") {
                    Task {
                        do {
                            let _ = try await viewModel.requestPermission()
                            await viewModel.didOpen()
                            dismiss()
                        } catch {
                            dismiss()
                        }
                    }
                }
                DefaultAppButton(style: .greyNormal, title: "Skip") {
                    dismiss()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
        }
        .defaultBackground()

    }
    
    var headerView: some View {
        FixedHeader {
            Text(Date().dayMonthDesc)
                .textStyle(font: .section, color: AppColor.color(hex: 0x423D3D))
        }
        .padding(.horizontal, 24)
    }
    
    @ViewBuilder var loadingView: some View {
        VStack(spacing: .zero) {
            LoadingView()
                .frame(width: 290, height: 200)
            
            Text("Weaving your thoughts...")
                .textStyle(font: .heading)
                .padding(.vertical, 36)
        }
        .padding(.top, 42)
    
    }
    
    func dismiss() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            dismissed()
        })
    }
}
