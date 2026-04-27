//
//  IconView.swift
//  LTApp
//
//  Created by Renjun Li on 2026/1/17.
//

import SwiftUI
import UIComponent
import RiveRuntime
import LTCommon

struct AnswerIconView: View {
    var answer: Answer
    var size: CGSize = .init(width: 24, height: 24)
    
    
    init(answer: Answer, size: CGSize = .init(width: 24, height: 24)) {
        self.answer = answer
        self.size = size
    }
    
    var body: some View {
        iconView(answer, size: size)
    }
    
    @ViewBuilder
    func iconView(_ answer: Answer, size: CGSize = .init(width: 24, height: 24)) -> some View {
      
        IconView(iconData: answer.icon, size: size)
    }
}

struct IconView: View {
    var iconData: IconData?
    var size: CGSize = .init(width: 24, height: 24)
    
    
    init(iconData: IconData?, size: CGSize = .init(width: 24, height: 24)) {
        self.iconData = iconData
        self.size = size
    }
    
    var body: some View {
        iconView(iconData, size: size)
    }
    
    @ViewBuilder
    func iconView(_ iconData: IconData?, size: CGSize = .init(width: 24, height: 24)) -> some View {
        if let icon = iconData {
            switch icon.status {
            case .pending:
                LoadingView()
                    .frame(width: size.width, height: size.height)
            case .failed:
                EmptyView()
            case .generated:
                if iconData?.readAt == nil {
                    RiveView(resouce: .lockAnimated)
                        .frame(width: size.width, height: size.height)
                } else {
                    if let url = icon.url {
                        ThumbnailIconImageView(url: url) { }
                            .frame(width: size.width, height: size.height)
                    }
                }
            }
        }
    }
}
