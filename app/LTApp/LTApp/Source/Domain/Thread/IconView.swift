//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent
import RiveRuntime
import Common

struct AnswerIconView: View {
    var answer: Answer
    var size: CGSize = .init(width: 24, height: 24)
    var onTap: (() -> Void)?
    
    init(answer: Answer, size: CGSize = .init(width: 24, height: 24), onTap: (() -> Void)?) {
        self.answer = answer
        self.size = size
        self.onTap = onTap
    }
    
    var body: some View {
        iconView(answer, size: size)
    }
    
    @ViewBuilder
    func iconView(_ answer: Answer, size: CGSize = .init(width: 24, height: 24)) -> some View {
      
        IconView(iconData: answer.icon, size: size, showLockIcon: true, onTap: onTap)
    }
}

struct IconView: View {
    var iconData: IconData?
    var size: CGSize = .init(width: 24, height: 24)
    var onTap: (() -> Void)?
    private let showLockIcon: Bool
    @State private var isUnlocking = false
    
    
    init(iconData: IconData?, size: CGSize = .init(width: 24, height: 24), showLockIcon: Bool = true, onTap: (() -> Void)? = nil) {
        self.iconData = iconData
        self.size = size
        self.onTap = onTap
        self.showLockIcon = showLockIcon
    }
    
    var body: some View {
        iconView(iconData, size: size)
    }
    
    @ViewBuilder
    func iconView(_ iconData: IconData?, size: CGSize = .init(width: 24, height: 24)) -> some View {
        VStack {
            if let icon = iconData {
                switch icon.status {
                case .pending:
                    LoadingView()
                case .failed:
                    EmptyView()
                case .generated:
                    if showLockIcon {
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
                                      .onTapGesture {
                                          onTap?()
                                      }
                              }
                          }
                    } else {
                        if let url = icon.url {
                            ThumbnailIconImageView(url: url) { }
                                .onTapGesture {
                                    onTap?()
                                }
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
