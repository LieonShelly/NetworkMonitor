//
//  JoyStickView.swift
//  LTApp
//
//  Created by Renjun Li on 2026/3/18.
//

import SwiftUI
import UIComponent

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
