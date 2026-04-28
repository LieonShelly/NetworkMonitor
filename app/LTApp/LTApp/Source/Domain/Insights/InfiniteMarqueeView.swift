//
//  InfiniteMarqueeView.swift
//  LTApp
//
//  Created by 李仁军 on 2026/4/28.
//


import SwiftUI

struct InfiniteMarqueeView<Content: View>: View {
    let contentWidth: CGFloat
    let spacing: CGFloat
    let paddingLeading: CGFloat
    let paddingVertical: CGFloat
    let content: Content
    
    @State private var scrollOffset: CGFloat = 0
    
    init(contentWidth: CGFloat, spacing: CGFloat = 0, paddingLeading: CGFloat = 0, paddingVertical: CGFloat = 0, @ViewBuilder content: () -> Content) {
        self.contentWidth = contentWidth
        self.spacing = spacing
        self.paddingLeading = paddingLeading
        self.paddingVertical = paddingVertical
        self.content = content()
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            content
            content
        }
        .padding(.leading, paddingLeading)
        .padding(.vertical, paddingVertical)
        .offset(x: scrollOffset)
        .onAppear {
            startMarquee(width: contentWidth)
        }
        .onChange(of: contentWidth) { oldValue, newValue in
            startMarquee(width: newValue)
        }
    }
    
    private func startMarquee(width: CGFloat) {
        guard width > 0 else { return }
        
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            scrollOffset = 0
        }
        
        let distance = width + spacing
        let duration = Double(distance) / 40.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                scrollOffset = -distance
            }
        }
    }
}
