//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent

public struct FixedHeader<Trailing: View>: View {
    let title: String
    let size: HeaderSize
    var backAction: (() -> Void)? = nil
    @ViewBuilder let trailing: (() -> Trailing)
    
    public init(title: String = "",
                size: HeaderSize = .plain,
                @ViewBuilder trailing:  @escaping (() -> Trailing) = { EmptyView() },
                backAction: (() -> Void)? = nil ) {
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
            switch size {
            case .plain:
                ZStack {
                    HStack {
                        backBtn
                        Spacer()
                        trailing()
                    }
                    titleView
                }
            case .large:
                backBtn
                titleView
                trailing()
            }
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .frame(height: size.height)
        .background(AppColor.oat)
    }
    
    @ViewBuilder
    var backBtn: some View {
        if let backAction {
            Image(.back)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
                .onTapGesture {
                backAction()
            }
        }
    }
    
    var titleView: some View {
        Text(title)
            .textStyle(font: .heading)
            .lineSpacing(0)
            .frame(maxWidth: .infinity, minHeight: 30, alignment: size == .large ? .leading : .center)
    }
}
