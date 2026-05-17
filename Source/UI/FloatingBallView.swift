//
//  FloatingBallView.swift
//  Common
//
//  Created by LittleThings AI on 2026/05/17.
//

import SwiftUI

public struct FloatingBallView: View {
    @State private var store = NetworkMonitorStore.shared

    @State private var position: CGPoint = CGPoint(x: UIScreen.main.bounds.width - 60, y: UIScreen.main.bounds.height - 150)
    @State private var isDragging = false

    private let ballSize: CGFloat = 50

    public init() {}

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                if store.isExpanded {
                    NetworkMonitorPanelView()
                        .frame(width: min(geometry.size.width * 0.9, 380), height: min(geometry.size.height * 0.7, 600))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 8)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }

                Circle()
                    .fill(Color.accentColor)
                    .frame(width: ballSize, height: ballSize)
                    .shadow(color: .accentColor.opacity(0.4), radius: isDragging ? 12 : 6)
                    .overlay {
                        Image(systemName: "network")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .scaleEffect(isDragging ? 1.15 : 1.0)
                    .position(position)
                    .gesture(dragGesture(in: geometry))
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            store.isExpanded.toggle()
                        }
                    }

                if !store.entries.isEmpty && !store.isExpanded {
                    Text("\(min(store.entries.count, 99))")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .clipShape(Capsule())
                        .position(x: position.x + 20, y: position.y - 20)
                        .transition(.scale)
                }
            }
            .onAppear {
                let screenWidth = UIScreen.main.bounds.width
                let screenHeight = UIScreen.main.bounds.height
                position = CGPoint(x: screenWidth - 60, y: screenHeight - 150)
            }
        }
    }

    private func dragGesture(in geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { value in
                isDragging = true
                position = value.location
            }
            .onEnded { value in
                isDragging = false
                let screenWidth = geometry.size.width
                let screenHeight = geometry.size.height
                let margin: CGFloat = ballSize / 2

                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    position.x = min(max(margin, value.location.x), screenWidth - margin)
                    position.y = min(max(margin, value.location.y), screenHeight - margin)
                }
            }
    }
}
