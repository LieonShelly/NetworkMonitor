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
    let content: () -> Content
    
    @State private var scrollPosition = ScrollPosition(x: 0)
    @State private var marqueeDistance: CGFloat = 0
    
    init(contentWidth: CGFloat, spacing: CGFloat = 0, paddingLeading: CGFloat = 0, paddingVertical: CGFloat = 0, @ViewBuilder content: @escaping () -> Content) {
        self.contentWidth = contentWidth
        self.spacing = spacing
        self.paddingLeading = paddingLeading
        self.paddingVertical = paddingVertical
        self.content = content
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false, content: {
            HStack(spacing: spacing) {
                content()
                content()
            }
            .padding(.vertical, paddingVertical)
        })
        .frame(width: contentWidth)
        .scrollPosition($scrollPosition)
        .scrollDisabled(true)
        .padding(.leading, paddingLeading)
        .onFirstAppear {
            startMarquee(width: contentWidth)
        }
        .onChange(of: contentWidth) { oldValue, newValue in
            startMarquee(width: newValue)
        }
        .task(id: marqueeDistance) {
            await runMarquee(distance: marqueeDistance)
        }
    }
    
    private func startMarquee(width: CGFloat) {
        guard width > 0 else {
            marqueeDistance = 0
            return
        }
        
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            scrollPosition.scrollTo(x: 0)
            marqueeDistance = width + spacing
        }
    }
    
    private func runMarquee(distance: CGFloat) async {
        guard distance > 0 else { return }
        
        let speed: CGFloat = 40
        let frameDelay: UInt64 = 16_666_667
        var offset: CGFloat = 0
        var lastUpdate = Date()
        
        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: frameDelay)
            guard !Task.isCancelled else { break }
            
            let now = Date()
            let elapsed = now.timeIntervalSince(lastUpdate)
            lastUpdate = now
            
            offset += speed * CGFloat(elapsed)
            if offset >= distance {
                offset.formTruncatingRemainder(dividingBy: distance)
            }
            
            await MainActor.run {
                scrollPosition.scrollTo(x: offset)
            }
        }
    }
}
