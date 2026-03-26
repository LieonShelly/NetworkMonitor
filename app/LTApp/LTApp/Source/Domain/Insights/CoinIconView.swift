//
//  CoinIconView.swift
//  LTApp
//
//  Created by Renjun Li on 2026/3/22.
//


import SwiftUI
import UIComponent

struct CoinIconView: View {
    let url: String
    let processorId: String
    
    init(url: String, processorId: String) {
        self.url = url
        self.processorId = processorId
    }
    
    var body: some View {
        Circle()
            .fill(AppColor.backgroundPage)
            .stroke(AppColor.color(hex: 0x000000), lineWidth: 1)
            .frame(width: 28, height: 28)
            .overlay(content: {
                ThumbnailIconImageView(url: url, processorIdentifier: processorId) {
                    
                }
                .frame(width: 18, height: 18)
            })
            .background {
                Circle()
                    .fill(Color.black)
                    .offset(x: 2, y: 2)
            }
    }
}

