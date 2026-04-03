//
//  FixedHeader.swift
//  LTApp
//
//  Created by Renjun Li on 2026/4/4.
//

import SwiftUI
import UIComponent

public struct FixedHeader<Trailing: View>: View {
    let title: String
    let size: HeaderSize
    var backAction: (() -> Void)? = nil
    @ViewBuilder let trailing: (() -> Trailing)
    
    public init(title: String,
                size: HeaderSize = .plain,
                backAction: (() -> Void)? = nil,
                @ViewBuilder trailing:  @escaping (() -> Trailing) = { EmptyView() } ) {
        self.title = title
        self.backAction = backAction
        self.trailing = trailing
        self.size = size
    }
    
    public enum HeaderSize {
        case plain
        case large
        
        var height: CGFloat {
            switch self {
            case .plain:
                return 72
            case .large:
                return 100
            }
        }
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            HStack {
                if let backAction {
                    backBtn.onTapGesture {
                        backAction()
                    }
                }
            }
            .frame(width: 32, height: 32)
            switch size {
            case .plain:
                titleView
                HStack(spacing: .zero) {
                    trailing()
                }
                .frame(width: 32, height: 32)
            case .large:
                titleView
                trailing()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .frame(height: size.height)
        .background(AppColor.oat)
    }
    
    var backBtn: some View {
        Image(.back)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32)
    }
    
    var titleView: some View {
        Text(title)
            .textStyle(font: .heading)
            .lineSpacing(0)
            .frame(maxWidth: .infinity, minHeight: 30, alignment: size == .large ? .leading : .center)
    }
}

#Preview {
    ScrollView {
        
        VStack {
            FixedHeader(title: "header")
            FixedHeader(title: "header") {}
            
            FixedHeader(title: "header", backAction: { }, trailing: {
                Image(.library)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Color.black)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
            })
            
            FixedHeader(title: "What is one little thing that make you happy today?", size: .large)
            
            FixedHeader(title: "What is one little thing that make you happy today?", size: .large) {
                
            }
            FixedHeader(title: "What is one little thing that make you happy today?",
                        size: .large,
                        backAction: {},
                        trailing: {
                Image(.library)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Color.black)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
            })
            
            FixedHeader(title: "What is one little thing?", size: .large)
            
            FixedHeader(title: "What is one little thing?", size: .large) {
                
            }
            FixedHeader(title: "What is one little thing?",
                        size: .large,
                        backAction: {},
                        trailing: {
                Image(.library)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Color.black)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
            })
            
        }
        .background(Color.random)
    }
}
