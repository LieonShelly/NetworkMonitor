//
//  ReadyToPrintView.swift
//  LTApp
//
//  Created by Renjun Li on 2026/3/17.
//

import SwiftUI
import UIComponent

struct ReadyToPrintView: View {
    var body: some View {
        VStack(spacing: .zero) {
            iconListView
            rpView
            startView
        }
        .defaultBackground()
    }
    
    @ViewBuilder
    var iconListView: some View {
        HStack(spacing: .zero) {
            HStack(spacing: .zero) {
                Text("YOUR COINS")
                    .textStyle(size: 12, fontFamily: .poppinsRegular)
                
                Image(.rightPloly)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .padding(.leading, 4)
                
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 12)
            .overlay {
                Rectangle()
                    .stroke(AppColor.color(hex: 0x000000), lineWidth: 1)
            }
            .padding(.vertical, 16)
            .padding(.leading, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(0 ..< 10) { _ in
                        Circle()
                            .fill(Color.random)
                            .frame(width: 25, height: 25)
                            .background {
                                Circle()
                                    .fill(Color.black)
                                    .offset(x: 2, y: 2)
                            }
                    }
                }
                .padding(.vertical, 10)
            }
            .padding(.leading, 15)
            .padding(.trailing, 11)
            
        }
        .overlay(content: {
            Rectangle()
                .stroke(AppColor.color(hex: 0x000000), lineWidth: 1)
        })
        .padding(.horizontal, 16)
        
        Trapezoid(padding: 20, direction: .bottom)
            .stroke(AppColor.color(hex: 0x000000), lineWidth: 1)
            .frame(height: 30)
            .padding(.horizontal, 16)
        
        VStack(spacing: .zero) {
            
        }
        
        
    }
    
    
    var rpView: some View {
        VStack(spacing: .zero) {
            Image(.invader)
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .padding(.bottom, 8)
            
            Image(.rtp)
                .resizable()
                .scaledToFit()
                .aspectRatio(contentMode: .fit)
                .frame(height: 40)
                .padding(.horizontal, 14)
        }
        .frame(height: 320)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColor.color(hex: 0x000000), lineWidth: 1)
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 28)
        .overlay {
            Rectangle()
                .stroke(AppColor.color(hex: 0x000000), lineWidth: 1)
        }
        .padding(.horizontal, 16 + 20)
    }
    
    var startView: some View {
        HStack(spacing: .zero) {
            HStack(alignment: .bottom, spacing: .zero) {
                JoyStickView()
                    .frame(width: 48, height: 123)
                    
                
                Image(.rpBtn)
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 30)
                    .offset(y: -30)
                
            
                Image(.rpBtn)
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 30)
            }
            .padding(.leading, 45)
            .offset(y: -35)
            Spacer()
            Button {
                
            } label: {
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColor.color(hex: 0x000000))
                    .frame(width: 155, height: 52)
                    .overlay {
                        Image(.startReport)
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 95, height: 32)
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColor.color(hex: 0x000000), lineWidth: 1)
                            .offset(x: 3, y: 6)
                    }
            }
            .padding(.top, 15)
            .padding(.bottom, 20)
            .padding(.trailing, 36)

        }
        .background {
            Trapezoid(padding: 16 + 20, direction: .top)
                .stroke(AppColor.color(hex: 0x000000), lineWidth: 1)
        }
    }
}

#Preview {
    ReadyToPrintView()
}


struct JoyStickView: View {
    var body: some View {
        VStack(spacing: .zero) {
           Circle()
                .fill(AppColor.backgroundPage)
                .stroke(AppColor.color(hex: 0x000000), lineWidth: 1)
                .frame(width: 48, height: 48)
                .zIndex(11)
            
            
            Image(.roundRect)
                .resizable()
                .scaledToFit()
                .aspectRatio(contentMode: .fit)
                .frame(width: 8, height: 64)
                .zIndex(10)
            
            Image(.rpBtn)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 30)
                .offset(y: -5)
            
        }
    }
}
