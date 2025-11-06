//
//  QuestionCardView.swift
//  LTApp
//
//  Created by Renjun Li on 2025/11/6.
//

import SwiftUI
import UIComponent

struct QuestionCardView: View {
    var body: some View {
        VStack {
            titleView
            questionView
        }
        .frame(maxWidth: .infinity)
        .background(AppColor.color(hex: 0xFFFAEE))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColor.color(hex: 0x717171), lineWidth: 1)
        )
    }
    
    var titleView: some View {
        Text("# simple joys")
              .textStyle(size: 10, color: AppColor.color(hex: 0x000000), fontFamily: .poppinsRegular)
              .padding(.horizontal, 10)
              .padding(.vertical, 6)
              .background(AppColor.color(hex: 0xFFFDF8))
              .overlay(
                  RoundedRectangle(cornerRadius: 16)
                      .stroke(AppColor.color(hex: 0xEBEBEB), lineWidth: 1)
              )
              .padding(.top, 5)

    }
    
    var questionView: some View {
        Text("What small moment of peace did you experience today?")
              .textStyle(size: 36)
              .fixedSize(horizontal: false, vertical: true)
              .padding(.bottom, 45)
              .padding(.top, 12)
              .padding(.horizontal, 20)

    }
    
}


extension View {
    func roundedBorder(color: Color, cornerRadius: CGFloat, lineWidth: CGFloat = 1) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(color, lineWidth: lineWidth)
            )
    }
}
