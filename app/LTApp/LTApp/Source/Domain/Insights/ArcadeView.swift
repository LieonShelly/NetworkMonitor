//
//  ArcadeView.swift
//  LTApp
//
//  Created by 李仁军 on 2026/4/19.
//

import SwiftUI
import UIComponent

struct ArcadeView: View {
    var body: some View {
        VStack(spacing: .zero) {
            tokenHeader
            screen
            controlPanel
        }
    }
    
    var tokenHeader: some View {
        ZStack(alignment: .bottom) {
            HStack {
                
            }
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background {
                Image(.tokenBg)
                    .resizable()
            }
            .padding(.bottom, 26)
            HStack(spacing: .zero) {

                Image(.vector128)
                    .resizable()
                    .frame(width: 12, height: 28)
                    
                Spacer()
                Image(.vector129)
                    .resizable()
                    .frame(width: 12, height: 28)
                    
            }
            
        }
        .padding(.horizontal, 8)
        
    }

    
    var screen: some View {
        VStack {
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image(.screen)
                .resizable()
        )
        .padding(.horizontal, 18)
        .offset(y: -2)
      
    }
    
    var controlPanel: some View {
        ZStack(alignment: .bottom) {
            HStack(spacing: .zero) {
                Image(.vector130)
                    .resizable()
                    .frame(width: 20, height: 69)
                Spacer()
                Image(.vector131)
                    .resizable()
                    .frame(width: 20, height: 69)
                    .offset(x: -1)
                
            }
         
            WavyLine(segmentCount: 200, seed: 200, axis: .horizontal)
                .stroke(style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                .foregroundColor(AppColor.black)
                .frame(height: 1)
            
        }
        .offset(y: -12)
        .frame(height: 85)
      
    }
    
}
