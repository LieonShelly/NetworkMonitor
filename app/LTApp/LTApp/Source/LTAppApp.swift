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
//            coordinator.rootView()
            MetalSmartIconView(originalImage: UIImage(resource: .chick))
//            VStack(spacing: 20) {
//                Text("原图 (留白大):")
//                Image(.chick) // 假设这是 Assets 里的原图
//                    .resizable()
//                    .frame(width: 24, height: 24)
//                    .border(Color.red)
//                
//                Text("自动去留白后:")
//                // 假设这里的 UIImage(named: "chick") 是你从服务端拿到的
//                SmartIconView(originalImage: UIImage(resource: .chick))
//                    .border(Color.green)
//            }
        }
        .environmentObject(homeCoordinator)
        .environmentObject(coordinator)
        .environmentObject(preHomeCoordinator)
    }
}


import SwiftUI

struct MatchedGeometryExampleView: View {
    @Namespace private var animationSpace
    @State private var isExpanded = true

    var body: some View {
        VStack {
            Spacer()

            if isExpanded {
                // viewA - 中间的大圆
                Circle()
                    .fill(Color.clear)
                    .overlay(content: {
                        Image(.dripper)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    })
                    .matchedGeometryEffect(id: "circle", in: animationSpace)
                    .frame(width: 100, height: 100)
                   
            } else {
                Spacer()
                // viewB - 底部的小圆
                Circle()
                    .fill(Color.clear)
                    .overlay(content: {
                        Image(.calendarDripper)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    })
                    .matchedGeometryEffect(id: "circle", in: animationSpace)
                    .frame(width: 20, height: 20)
                    .padding(.bottom, 50)
                    
            }

            Spacer()

            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }) {
                Text("Toggle")
                    .font(.headline)
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}
