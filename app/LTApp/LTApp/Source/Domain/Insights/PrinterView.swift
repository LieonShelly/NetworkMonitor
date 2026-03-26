//
//  PrinterView.swift
//  LTApp
//
//  Created by Renjun Li on 2026/3/26.
//


import UIComponent
import SwiftUI

struct PrinterView: View {
    @ObservedObject var viewModel: InsightsViewModel
    @State private var isPrinting = false
    let bgColor = Color(red: 0.99, green: 0.98, blue: 0.96)
    
    var body: some View {
        ZStack {
            bgColor.edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                ZStack(alignment: .top) {
                    
                    Color.random
                        .padding(.horizontal, 24 + 32 + 20)
                        .overlay(
                            PaperView(viewModel: viewModel, isSmall: true)
                                .padding(.horizontal, 24 + 32 + 20)
                                .offset(y: isPrinting ? -10 : -2000),
                            alignment: .top
                        )
                        .clipShape(Rectangle())
                        .offset(y: 34)
                        .zIndex(2)
                    
                    PrinterBodyView()
                        .zIndex(1)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 2.0)) {
                        isPrinting.toggle()
                    }
                }) {
                    Text(isPrinting ? "收回纸张" : "开始打印")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(Color.black)
                        .cornerRadius(25)
                }
                .padding(.bottom, 50)
            }
        }
    }
}

struct PrinterBodyView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColor.color(hex: 0x000000), lineWidth: 1)
                .frame(height: 68)
            
            RoundedRectangle(cornerRadius: 5)
                .stroke(AppColor.color(hex: 0x000000), lineWidth: 1)
                .frame( height: 12)
                .padding(.horizontal, 32)
        }
        .padding(.horizontal, 24)
    }
}
