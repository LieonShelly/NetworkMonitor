//
//  AboutMeView.swift
//  LTApp
//

import SwiftUI
import UIComponent

struct AboutMeView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            // 标题
            Text("About me...")
                .textStyle(font: .heading, color: AppColor.black)
                .padding(.horizontal, 24)
                .padding(.top, 20)
            
            // 表单区域
            VStack(alignment: .leading, spacing: .zero) {
                // Name
                aboutMeRow(label: "Name", value: "Set your display name")
                
                // 分隔线
                divider
                
                // Email
                aboutMeRow(label: "Email", value: "example@email.com")
                
                // 分隔线
                divider
            }
            .padding(.top, 32)
            .padding(.horizontal, 32)
            
            // Logout 按钮
            Button {
                // logout action
            } label: {
                HStack(spacing: 8) {
                    Text("Logout")
                        .textStyle(size: 16, color: AppColor.color(hex: 0xE75C06), fontFamily: .poppinsRegular)
                    
                    Image(systemName: "arrow.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(AppColor.color(hex: 0xE75C06))
                }
            }
            .padding(.top, 32)
            .padding(.horizontal, 32)
            
            Spacer()
            
        }
        .defaultBackground()
    }
    
    // MARK: - 表单行
    private func aboutMeRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .textStyle(font: .caption, color: AppColor.greyMedium)
            
            Text(value)
                .textStyle(size: 16, color: AppColor.black, fontFamily: .poppinsRegular)
        }
        .padding(.vertical, 16)
    }
    
    // MARK: - 分隔线
    private var divider: some View {
        Rectangle()
            .fill(AppColor.greyLight)
            .frame(height: 0.5)
    }
}
