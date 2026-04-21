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
    @EnvironmentObject var router: InsightsRouter
    @State private var isPrinting = false
    
    var body: some View {
        ZStack {
            AppColor.backgroundPage.edgesIgnoringSafeArea(.all)
            ZStack(alignment: .top) {
                
                Color.clear
                    .padding(.horizontal, 24 + 32 + 20)
                    .overlay(
                        PaperView(viewModel: viewModel, isSmall: true)
                            .padding(.horizontal, 24 + 32 + 20)
                            .fixedSize(horizontal: false, vertical: true)
                            .offset(y: isPrinting ? -10 : -1000),
                        alignment: .top
                    )
                    .clipShape(Rectangle())
                    
                    .offset(y: 34)
                    .zIndex(2)
                
                PrinterBodyView()
                    .zIndex(1)
                    .onFirstAppear {
                        withAnimation(.easeInOut(duration: 2.0), completionCriteria: .logicallyComplete, {
                            isPrinting.toggle()
                        }, completion: {
                            router.replace(.reported)
                        })
                    }
                    
            }
            .padding(.top, 43)
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
