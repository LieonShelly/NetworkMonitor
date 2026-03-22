//
//  ReadyToPrintView.swift
//  LTApp
//
//  Created by Renjun Li on 2026/3/17.
//

import SwiftUI
import UIComponent
import SpriteKit
import Kingfisher

struct ReadyToPrintView: View, ImageCacheKeyType {
    enum Constants {
        static let rpPadding: CGFloat = 12 + 20 + 28
    }
    @StateObject var viewModel: InsightsViewModel
    var processorId: String = "metal.icon.processor.v3_thickness_2"
    @State private var scene: CoinScene?
    @State private var started: Bool = false
    @State private var sceneSize: CGSize = .zero
    
    init(viewModel: InsightsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            iconListView
            rpView
            startView
        }
        .defaultBackground()
        .task {
            try? await viewModel.fetchReadyToPrintData()
        }
    }
    
    @ViewBuilder
    var iconListView: some View {
        HStack(spacing: .zero) {
            HStack(spacing: .zero) {
                Text("YOUR COINS")
                    .textStyle(size: 12, fontFamily: .poppinsRegular)
                
                Image(.rightPloly)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .padding(.leading, 4)
                
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 12)
            .overlay {
                Rectangle()
                    .stroke(AppColor.color(hex: 0x000000), lineWidth: 1)
            }
            .padding(.vertical, 16)
            .padding(.leading, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    let icons = viewModel.weeklyIcons
                    ForEach(0 ..< icons.count, id: \.self) { index in
                        let icon = icons[index]
                        switch icon {
                        case .normal(let iconData):
                            let url = iconData.url
                          CoinIconView(url: url, processorId: processorId)
                        case .empty:
                            Circle()
                                .fill(Color.clear)
                                .stroke(AppColor.color(hex: 0x000000), style: .init(lineWidth: 1, lineCap: .square, lineJoin: .round, miterLimit: 0, dash: [4, 4], dashPhase: .zero))
                                .frame(width: 28, height: 28)
                        case .plus:
                            EmptyView()
                        }
                      
                    }
                }
                .padding(.vertical, 10)
            }
            .padding(.leading, 15)
            .padding(.trailing, 11)
            
        }
        .overlay(content: {
            Rectangle()
                .stroke(AppColor.color(hex: 0x000000), lineWidth: 1)
        })
        .padding(.horizontal, 16)
        
        Trapezoid(padding: 20, direction: .bottom)
            .stroke(AppColor.color(hex: 0x000000), lineWidth: 1)
            .frame(height: 30)
            .padding(.horizontal, 16)
        
    }
    
    var rpView: some View {
        GeometryReader { geometry in
            ZStack {
                if let scene = scene {
                    iconLoadingView(scene: scene).opacity(started ? 1 : 0)
                }
                if !started {
                    switch viewModel.printUIState {
                    case .readyToPrint:
                        rpIdleView
                    case .unread:
                        unreadView
                    case .empty:
                        emptyView
                    }
                }
            }
            .animation(.easeInOut, value: started)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColor.color(hex: 0x000000), lineWidth: 1)
            }
            .padding(.vertical, 32)
            .padding(.horizontal, 28)
            .overlay {
                Rectangle()
                    .stroke(AppColor.color(hex: 0x000000), lineWidth: 1)
            }
            .padding(.horizontal, 12 + 20)
            .onFirstAppear {
                let width = geometry.size.width - Constants.rpPadding * 2
                let height = geometry.size.height - 64 // 减去 vertical padding
                sceneSize = CGSize(width: width, height: height)
                
                let newScene = CoinScene(size: sceneSize)
                newScene.scaleMode = .fill
                newScene.backgroundColor = .clear
                scene = newScene
            }
        }
        .frame(maxHeight: .infinity)
    }
    
    var startView: some View {
        HStack(spacing: .zero) {
            HStack(alignment: .bottom, spacing: .zero) {
                JoyStickView()
                    .frame(width: 48, height: 123)
                    
                
                Image(.rpBtn)
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 30)
                    .offset(y: -30)
                
            
                Image(.rpBtn)
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 30)
            }
            .padding(.leading, 45)
            .offset(y: -35)
            Spacer()
            Button {
                guard let scene = scene, let icons = viewModel.currentIcons?.icons else { return }
                let paths = icons.map { cacheKey($0.url)}
                    .map { KingfisherManager.shared.cache.cachePath(forKey: $0, processorIdentifier: processorId) }
                scene.dropCoinsBatch(localPaths: paths , count: paths.count) {
                    Task {
                        try? await viewModel.generateReport()
                    }
                }
                started = true
            } label: {
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColor.color(hex: 0x000000))
                    .frame(width: 155, height: 52)
                    .overlay {
                        Image(.startReport)
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 95, height: 32)
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColor.color(hex: 0x000000), lineWidth: 1)
                            .offset(x: 3, y: 6)
                    }
            }
            .padding(.top, 15)
            .padding(.bottom, 20)
            .padding(.trailing, 36)

        }
        .background {
            Trapezoid(padding: 12 + 20, direction: .top)
                .stroke(AppColor.color(hex: 0x000000), lineWidth: 1)
        }
    }
    
    
    func iconLoadingView(scene: CoinScene) -> some View {
        SpriteView(scene: scene, options: [.allowsTransparency, .shouldCullNonVisibleNodes])
    }
    
    var rpIdleView: some View {
        VStack(spacing: .zero) {
            Image(.invader)
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .padding(.bottom, 8)
            
            Image(.rtp)
                .resizable()
                .scaledToFit()
                .aspectRatio(contentMode: .fit)
                .frame(height: 40)
                .padding(.horizontal, 14)
        }
    }
    
   @ViewBuilder var unreadView: some View {
       let onRowH: CGFloat = (84.0 + 16 * 2)
       let towRowH: CGFloat = (84 * 2.0 + 16 * 2 + 12)
        VStack(spacing: .zero) {
            Text("\(viewModel.unreadHisotrys.count) UNREAD")
                .textStyle(size: 12, fontFamily: .poppinsRegular)
                
            
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.unreadHisotrys, id: \.id) { history in
                        HStack {
                            Text("\(history.periodStart.yyyymmdd) - \(history.periodEnd.yyyymmdd)")
                                .textStyle(size: 13, fontFamily: .ibmPlexMonoRegular)
                        }
                        .frame(height: 84)
                        .frame(maxWidth: .infinity)
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColor.color(hex: 0x000000), lineWidth: 1)
                        }
                        .onTapGesture {
                            Task {
                                try await viewModel.didTapHistoryItem(history)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .frame(height: viewModel.unreadHisotrys.count >= 2 ? towRowH : onRowH)
        }
    }
    
    
    var emptyView: some View {
        VStack(spacing: .zero) {
            Image(.emptyFace)
                .resizable()
                .scaledToFit()
                .frame(width: 151, height: 148)
            
            Text("not enough tokens".uppercased())
                .multilineTextAlignment(.center)
                .textStyle(size: 36, fontFamily: .poppinsRegular)
                .padding(.top, 27)
            
        }
    }
}
