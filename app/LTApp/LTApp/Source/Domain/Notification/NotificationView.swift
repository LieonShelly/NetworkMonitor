//
//  NotificationView.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/16.
//

import SwiftUI
import UIComponent

struct NotificationView: View {
    var body: some View {
        VStack {
            titleView
            Spacer()
            loadingView
            
            Spacer()
            Text("A unique icon is being created based on what you wrote, we will let you know when it’s ready! ")
                .textStyle(size: 12, color: AppColor.color(hex: 0x323232), fontFamily: .poppinsRegular)
                .padding(.bottom, 16)
                .padding(.horizontal, 43)
            
            VStack(spacing: 16) {
                DefaultAppButton(title: "Notify me") {
                }
                Button(action: {
                    
                }) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColor.color(hex: 0xD9D9D9).opacity(0.4))
                        .overlay {
                            Text("Back")
                                .font(AppFont.feltTipSenior(size: 24, fontWeight: .regular))
                                .foregroundStyle(AppColor.textPrimary )
                        }
                        .frame(height: 62)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
        }
        .defaultBackground()
    }
    
    @ViewBuilder var titleView: some View {
        Text("daily life")
            .textStyle(size: 24, color: AppColor.color(hex: 0x323232), fontFamily: .feltTipSeniorRegular)
            .padding(.vertical, 4)
            .padding(.horizontal, 10)
            .background(AppColor.color(hex: 0xD9D9D9).opacity(0.4))
            .cornerRadius(30, corners: .allCorners)
            .padding(.top, 16)
        
    }
    
    @ViewBuilder var loadingView: some View {
        VStack(spacing: .zero) {
            LoadingView()
                .frame(width: 290, height: 200)
                .transition(.opacity)
            
            Text("Weaving your thoughts...")
                .textStyle(size: 24, fontFamily: .feltTipSeniorRegular)
                .padding(.vertical, 36)
                .transition(.opacity)
        }
        .padding(.top, 42)
        .transition(.opacity)
    
    }
}
