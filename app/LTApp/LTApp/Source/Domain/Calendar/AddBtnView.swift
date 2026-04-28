//
//  AddBtnView.swift
//  LTApp
//
//  Created by 李仁军 on 2026/4/28.
//

import UIComponent
import SwiftUI

struct AddBtnView: View {
    let addAction: (() -> Void)
    let addIconsize: CGSize
    let blurBgSize: CGSize
    
    var body: some View {
        addBtn
    }
    
    @State private var isBreathing = false
    @ViewBuilder
    var addBtn: some View {
        Spacer()
        Button {
            addAction()
        } label: {
            LinearGradient(
                colors: [
                    AppColor.color(hex: 0x040404),
                    AppColor.color(hex: 0x656565)
                ],
                startPoint: .init(x: 0, y: 0),
                endPoint: .init(x: 1, y: 0.7)
            )
            .cornerRadius(blurBgSize.width * 0.5, corners: .allCorners)
            .blur(radius: 3)
            .frame(width: blurBgSize.width, height: blurBgSize.height)
            .overlay {
                Image(.smallAdd)
                    .resizable()
                    .frame(width: addIconsize.width, height: addIconsize.height)
            }
            .scaleEffect(isBreathing ? 1.2 : 1.0)
            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true),
                       value: isBreathing
            )
            .task {
                isBreathing = true
            }
        }
    }
}
