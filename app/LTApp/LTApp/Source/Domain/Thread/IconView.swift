//
//  IconView.swift
//  LTApp
//
//  Created by Renjun Li on 2026/1/17.
//

import SwiftUI
import UIComponent
import RiveRuntime
import Common

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
    var onTap: (() -> Void)?
    @State private var isUnlocking = false
    
    
    init(iconData: IconData?, size: CGSize = .init(width: 24, height: 24), onTap: (() -> Void)? = nil) {
        self.iconData = iconData
        self.size = size
        self.onTap = onTap
    }
    
    var body: some View {
        iconView(iconData, size: size)
    }
    
    @ViewBuilder
    func iconView(_ iconData: IconData?, size: CGSize = .init(width: 24, height: 24)) -> some View {
        Group {
            if let icon = iconData {
                switch icon.status {
                case .pending:
                    LoadingView()
                case .failed:
                    EmptyView()
                case .generated:
                  if iconData?.readAt == nil {
                        if isUnlocking {
                            unlockingAnimatedView
                        } else {
                            lockView
                                .contentShape(Rectangle().inset(by: -10))
                                .onTapGesture {
                                    isUnlocking = true
                                    Task {
                                        try? await Task.sleep(for: .seconds(1))
                                        onTap?()
                                        try? await Task.sleep(for: .seconds(1))
                                        isUnlocking = false
                                    }
                                }
                        }
                    } else {
                        if let url = icon.url {
                            ThumbnailIconImageView(url: url) { }
                        }
                    }
                }
            }
        }
        .frame(width: size.width, height: size.height)
      
    }
    
    var lockView: some View {
        RiveView(resouce: .lockAnimated)
    }
    
    var unlockingAnimatedView: some View {
        RiveView(resouce: .lockTapped)
    }
}
