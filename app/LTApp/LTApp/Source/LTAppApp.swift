//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent

@main
struct LTAppApp: App {
    @StateObject var coordinator: AppCoordinator
    @StateObject var homeCoordinator: HomeCoordinator
    @StateObject var preHomeCoordinator: PreHomeCoordinator
    @Namespace var dripleTransition
    
    init() {
        try! AppFont.registerFonts()
        
        let appCoordinator = AppCoordinator()
        _coordinator = StateObject(
            wrappedValue: appCoordinator
        )
        _homeCoordinator = StateObject(wrappedValue: HomeCoordinator(appDataService: appCoordinator.appDataService))
        
        _preHomeCoordinator = StateObject(wrappedValue: PreHomeCoordinator(appDataService: appCoordinator.appDataService))
    }
    
    var body: some Scene {
        WindowGroup {
            coordinator.rootView()
//            MetalSmartIconView(originalImage: UIImage(resource: .chick))
//            ManualHeroAnimationView()
        }
        .environmentObject(homeCoordinator)
        .environmentObject(coordinator)
        .environmentObject(preHomeCoordinator)
    }
}


import SwiftUI


struct MetalSmartIconView: View {
    let originalImage: UIImage
    @State var processedImage: UIImage?
    
    var body: some View {
        
        VStack {
            Image(uiImage: originalImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
            
            if let processedImage {
                Image(uiImage: processedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .background(Color.red)
            }
        }
        
        .onAppear {
            MetalImageProcessor.shared.process(originalImage, thickness: 0) { processedImage in
                self.processedImage = processedImage
            }
        }
    }
}

import SwiftUI
struct ManualHeroAnimationView: View {
    // 状态管理
    @State private var selectedId: Int? = nil      // 当前选中的 ID
    @State private var showDetailView = false      // 是否显示浮层
    @State private var isAnimating = false         // 控制动画状态（用于触发 frame 变化）
    
    // 存储所有 Item 的坐标字典 [ID : Frame]
    @State private var itemFrames: [Int: CGRect] = [:]
    
    var body: some View {
        ZStack {
            // MARK: - 1. 列表层
            ScrollView {
                LazyVGrid(columns: Array(repeating: .init(.fixed(60), spacing: 20), count: 3), spacing: 20) {
                    ForEach(0..<15, id: \.self) { index in
                        // 列表 Item
                        CircleItem(index: index)
                            .opacity(showDetailView && selectedId == index ? 0 : 1) // 展开时隐藏列表原本的 Item
                            .onTapGesture {
                                openDetail(id: index)
                            }
                    }
                }
                .padding(.top, 50)
            }
            // 关键：监听子视图的坐标变化
            .onPreferenceChange(ItemFramePreferenceKey.self) { preferences in
                self.itemFrames = preferences
            }
            
            // MARK: - 2. 浮层 (Expanded View)
            if showDetailView, let activeId = selectedId, let sourceRect = itemFrames[activeId] {
                
                // 背景遮罩
                Color.black.opacity(isAnimating ? 0.4 : 0)
                    .ignoresSafeArea()
                    .onTapGesture { closeDetail() }
                
                // 动画主角 View
                // 我们通过计算属性动态决定它应该在哪、多大
                let targetRect = getTargetRect() // 目标位置（屏幕中心）
                let currentRect = isAnimating ? targetRect : sourceRect // 动画插值
                
                Image(systemName: "drop.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(isAnimating ? 40 : 10) // 内部 padding 也可以动画
                    .foregroundColor(.white)
                    .frame(width: currentRect.width, height: currentRect.height) // 手动控制大小
                    .background(Color.blue)
                    .clipShape(Circle())
                    .position(x: currentRect.midX, y: currentRect.midY) // 手动控制位置
                    .onTapGesture {
                        closeDetail()
                    }
                    .ignoresSafeArea() // 如果你想让它全屏，或者避免 Safe Area 干扰坐标
            }
        }
        // 定义坐标空间，确保 GeometryReader 获取的是相对于这个 ZStack 的坐标
        .coordinateSpace(name: "ContainerSpace")
    }
    
    // MARK: - 逻辑方法
    
    // 计算目标位置（屏幕中心的大图）
    func getTargetRect() -> CGRect {
        let screenSize = UIScreen.main.bounds.size
        let targetSize: CGFloat = 250
        return CGRect(
            x: (screenSize.width - targetSize) / 2,
            y: (screenSize.height - targetSize) / 2,
            width: targetSize,
            height: targetSize
        )
    }
    
    // 展开动画流程
    func openDetail(id: Int) {
        // 1. 记录选中的 ID，显示浮层（此时 isAnimating 为 false，浮层位置 = 列表项位置）
        selectedId = id
        showDetailView = true
        
        // 2. 稍微延迟一点点，触发动画变为 true（浮层位置 -> 屏幕中心）
        // 必须让 View 先渲染出来，再做动画，否则没有“飞过去”的效果
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isAnimating = true
            }
        }
    }
    
    // 关闭动画流程
    func closeDetail() {
        // 1. 动画变回 false（浮层位置 -> 列表项位置）
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            isAnimating = false
        }
        
        // 2. 等动画结束后，真正销毁浮层
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            showDetailView = false
            selectedId = nil
        }
    }
    
    // MARK: - 子视图组件
    @ViewBuilder
    func CircleItem(index: Int) -> some View {
        Circle()
            .fill(Color.gray.opacity(0.3))
            .overlay(
                Image(systemName: "drop.fill")
                    .resizable()
                    .padding(10)
                    .foregroundColor(.blue)
            )
            .frame(width: 60, height: 60)
            // 【核心】：利用 background + GeometryReader 捕获坐标
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(
                            key: ItemFramePreferenceKey.self,
                            // 获取相对于 "ContainerSpace" 的坐标
                            value: [index: geo.frame(in: .named("ContainerSpace"))]
                        )
                }
            )
    }
}

#Preview {
    ManualHeroAnimationView()
}

import SwiftUI

// 用于存储每个 Item 的 ID 和它的 Frame
struct ItemFramePreferenceKey: PreferenceKey {
    typealias Value = [Int: CGRect]
    static let defaultValue: [Int: CGRect] = [:]
    
    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}
