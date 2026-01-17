//
//  IconView.swift
//  LTApp
//
//  Created by Renjun Li on 2026/1/17.
//

import SwiftUI

struct IconView: View {
    let answer: Answer
    var size: CGSize = .init(width: 24, height: 24)
    
    var body: some View {
        iconView(answer, size: size)
    }
    
    @ViewBuilder
    func iconView(_ answer: Answer, size: CGSize = .init(width: 24, height: 24)) -> some View {
      
        if let icon = answer.icon {
            switch icon.status {
            case .pending:
                Image(.lock)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size.width, height: size.height)
            default:
                placeholderIcon
                    .frame(width: size.width, height: size.height)
                
//                if let url = icon.url {
//                    ThumbnailIconImageView(url: url) {
//                        placeholderIcon
//                    }
//                    .frame(width: size.width, height: size.height)
//                } else {
//                    placeholderIcon
//                        .frame(width: size.width, height: size.height)
//                }
            }
        } else {
            placeholderIcon
                .frame(width: size.width, height: size.height)
        }
    }
    
    var placeholderIcon: some View {
        Circle()
            .fill(Color.clear)
            .overlay(content: {
                Image(.calendarDripper)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            })
    }
}
