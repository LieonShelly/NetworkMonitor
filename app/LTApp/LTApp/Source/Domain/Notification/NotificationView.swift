//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent
import UserNotifications

struct NotificationView: View {
    @StateObject var viewModel: NotificationViewModel
    @Binding var opacity: CGFloat
    let dismissed: () -> Void
    
    init(viewModel: NotificationViewModel, opacity: Binding<CGFloat>, dismissed: @escaping () -> Void) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.dismissed = dismissed
        self._opacity = opacity
    }
    
    var body: some View {
        VStack {
            titleView
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
                            print("requestPermission-error:\(error)")
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
        .opacity(opacity)
    }
    
    @ViewBuilder var titleView: some View {
        FixedHeader {
            Text(Date().dayMonthDesc)
                .textStyle(font: .section, color: AppColor.color(hex: 0x423D3D))
        }
    }
    
    @ViewBuilder var loadingView: some View {
        VStack(spacing: .zero) {
            LoadingView()
                .frame(width: 290, height: 200)
                .transition(.opacity)
            
            Text("Weaving your moments...")
                .textStyle(font: .heading)
                .padding(.vertical, 36)
                .transition(.opacity)
        }
        .padding(.top, 42)
        .transition(.opacity)
    
    }
    
    func dismiss() {
        withAnimation(.easeIn(duration: 0.5)) {
            opacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            dismissed()
        })
    }
}
