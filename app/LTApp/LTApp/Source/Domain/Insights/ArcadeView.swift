//
//  ArcadeView.swift
//  LTApp
//
//  Created by 李仁军 on 2026/4/19.
//

import SwiftUI
import UIComponent
import SpriteKit
import Kingfisher

struct ArcadeView: View, ImageCacheKeyType {
    @ObservedObject var viewModel: InsightsViewModel
    private let processorId = "metal.icon.processor.v3_thickness_2"
    @State private var scene: CoinScene?
    @State private var sceneSize: CGSize = .zero
    @State private var started: Bool = false
    
    enum Constants {
        static let rpPadding: CGFloat = 12 + 20 + 28
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            tokenHeader
            screen
            controlPanel
        }
        .onFirstAppear {
            Task {
                try? await viewModel.fetchHistoryHeaderCurrentWeekIcons()
                try? await viewModel.fetchHistory()
                await viewModel.refreshArcadeState()
            }
        }
    }
    
    var tokenHeader: some View {
        ZStack(alignment: .bottom) {
            HStack(spacing: 0) {
                iconCountView
                iconRow
            }
            .padding(.leading, 48)
            .padding(.trailing, 10)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background {
                Image(.tokenBg)
                    .resizable()
            }
            .padding(.bottom, 26)
            
            HStack(spacing: .zero) {
                Image(.vector128)
                    .resizable()
                    .frame(width: 12, height: 28)
                Spacer()
                Image(.vector129)
                    .resizable()
                    .frame(width: 12, height: 28)
            }
        }
        .padding(.horizontal, 8)
    }
    
    private var iconCountView: some View {
        HStack(spacing: 10) {
            Text(iconCountText)
                .textStyle(size: 20, fontFamily: .dsDigital)
                .textCase(.uppercase)
            
            Image(systemName: "arrowtriangle.right.fill")
                .resizable()
                .frame(width: 10, height: 10)
                .foregroundStyle(Color.black)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Image(.rectangle53)
                .resizable()
        )
        .padding(.trailing, 24)
    }
    
    private var iconCountText: String {
        guard let currentIcons = viewModel.currentIcons else { return "0 / 0" }
        let count = currentIcons.icons.count
        let total = currentIcons.minAnswersToGenerateReport
        return "\(count) / \(total)"
    }
    
    @ViewBuilder
    private var iconRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(0..<viewModel.weeklyIcons.count, id: \.self) { index in
                    let iconStyle = viewModel.weeklyIcons[index]
                    switch iconStyle {
                    case .normal(let icon):
                        CoinIconView(url: icon.url, processorId: processorId)
                    case .empty, .plus:
                        Circle()
                            .fill(Color.clear)
                            .stroke(
                                AppColor.black,
                                style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                            )
                            .frame(width: 28, height: 28)
                    }
                }
            }
            .padding(.vertical, 10)
        }
    }
    
    var screen: some View {
        ZStack(alignment: .top) {
            historyAndMoreStrampsSection
            Rectangle()
                .fill(AppColor.backgroundPage)
                .frame(height: 5)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .allowsHitTesting(false)
            
            Rectangle()
                .fill(Color.clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(
                    Image(.screen)
                        .resizable()
                )
                .padding(.horizontal, 18)
                .offset(y: -2)
                .allowsHitTesting(false)
        }
     
    }
    
    private var moreStampsCount: Int {
        guard let currentIcons = viewModel.currentIcons else { return 0 }
        return max(0, currentIcons.minAnswersToGenerateReport - currentIcons.icons.count)
    }
    
    @ViewBuilder
    var readHistoryView: some View {
        let allItems: [WeeklyReportSummary] = viewModel.readHisotrys
        
        HStack {
            Spacer()
            Image(.rightPloly)
                .resizable()
                .frame(width: 15, height: 15)
            Text(allItems.isEmpty ? "NO HISTORY" : "HISTORY")
                .textStyle(font: .annotation, color: AppColor.black)
                .padding(.horizontal, 16)
            Image(.leftPoly)
                .resizable()
                .frame(width: 15, height: 15)
            Spacer()
        }
        .padding(.bottom, 12)
        
        LazyVStack(spacing: 12) {
            ForEach(Array(viewModel.readHisotrys.enumerated()), id: \.element.id) { index, item in
                NewHistoryItemRow(history: item)
                    .contentShape(.rect)
                    .onTapGesture {
                        Task {
                            try? await viewModel.didTapHistoryItem(item)
                        }
                    }
                    .onAppear {
                        if item.id == allItems.last?.id {
                            Task { await viewModel.loadMoreHistory() }
                        }
                    }
            }
        }
        .padding(.bottom, 26 + 12)
    }
    
    
    
    @ViewBuilder
    var unReadHistoryView: some View {
        LazyVStack(spacing: 12) {
            ForEach(Array(viewModel.unreadHisotrys.enumerated()), id: \.element.id) { index, item in
                NewHistoryUnReadItemRow(history: item)
                    .contentShape(.rect)
                    .onTapGesture {
                        Task {
                            try? await viewModel.didTapHistoryItem(item)
                        }
                    }
            }
        }
        .padding(.bottom, 42)
    }
    
    var moreStampsView: some View {
        VStack(spacing: .zero) {
            Text("\(moreStampsCount)")
                .textStyle(size: 64, color: AppColor.greyDark, fontFamily: .dsDigital)
            
            Text("more stamps")
                .textStyle(size: 31, color: AppColor.greyDark, fontFamily: .dsDigital)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private var historyAndMoreStrampsSection: some View {
        let containerVP: CGFloat = 28
        let rowHeight: CGFloat = 80
        let rowSpacing: CGFloat = 12
        let historyHeaderHeight: CGFloat = 27 + 12 
        let visibleListHeight: CGFloat = historyHeaderHeight + rowHeight + rowSpacing + rowHeight * 0.2 + containerVP * 2
        
        GeometryReader { geo in
            let topHeight = max(0, geo.size.height - visibleListHeight)
            
            
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: .zero) {
                    switch viewModel.arcadeState {
                    case .countingDown:
                        CountingDownView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .frame(height: topHeight)
                        readHistoryView
                  
                    case .readyToPrint:
                        ZStack {
                            if let scene = scene {
                                iconLoadingView(scene: scene)
                                    .opacity(started ? 1 : 0)
                                    .frame(height: geo.size.height)
                            }
                            if !started {
                                rpIdleView
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .frame(height: geo.size.height)
                            }
                        }
                        .frame(height: geo.size.height)
                        .padding(.horizontal, 40)
                        .animation(.easeInOut, value: started)
                    case .unread:
                        unReadCountView
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .frame(height: topHeight)
                        unReadHistoryView
                            .padding(.horizontal, 56)
                        readHistoryView
                            .padding(.horizontal, 56)
                    case .unFull:
                        moreStampsView
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .frame(height: topHeight)
                        readHistoryView
                            .padding(.horizontal, 56)
                    }
                }
                .frame(maxWidth: .infinity)
              
            }
            .onFirstAppear {
                let width = geo.size.width - 40 * 2
                let height = geo.size.height - 28 * 2
                sceneSize = CGSize(width: width, height: height)
                
                let newScene = CoinScene(size: sceneSize)
                newScene.scaleMode = .aspectFit
                newScene.backgroundColor = .clear
                scene = newScene
            }
        }
    }
    
    var unReadCountView: some View {
        VStack(spacing: .zero) {
            Text("\(viewModel.unreadHisotrys.count)")
                .textStyle(size: 64, color: AppColor.greyDark, fontFamily: .dsDigital)
            
            Text("unread")
                .textStyle(size: 31, color: AppColor.greyDark, fontFamily: .dsDigital)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            
            Text("READY TO PRINT".uppercased())
                .multilineTextAlignment(.center)
                .textStyle(size: 40, fontFamily: .dsDigital)
            
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
                    .fill(AppColor.black)
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
                            .stroke(AppColor.black, lineWidth: 1)
                            .offset(x: 3, y: 6)
                    }
            }
            .padding(.top, 55)
        }
        .frame(maxWidth: .infinity)
    }
    
    var controlPanel: some View {
        ZStack(alignment: .bottom) {
            HStack(spacing: .zero) {
                Image(.vector130)
                    .resizable()
                    .frame(width: 20, height: 69)
                Spacer()
                controlbtns
                Spacer()
                Image(.vector131)
                    .resizable()
                    .frame(width: 20, height: 69)
                    .offset(x: -1)
            }
            
            WavyLine(segmentCount: 200, seed: 200, axis: .horizontal)
                .stroke(style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                .foregroundColor(AppColor.black)
                .frame(height: 1)
        }
        .offset(y: -12)
        .frame(height: 85)
    }
    
    var controlbtns: some View {
        HStack(spacing: .zero) {
            machineBtn
            Spacer()
            HStack(spacing: .zero) {
                tickerbtn
                    .offset(x: 10)
                tickerbtn
                    .offset(y: 20)
                tickerbtn
                    .offset(x: -10)
            }
            .frame(width: 40 * 3)
            .padding(.trailing,  50)
            .offset(y: -10)
        }
        .overlay(content: {
            joystickerView
                .frame(maxWidth: .infinity, alignment: .trailing)
                .offset(y: -50)
                .padding(.trailing,  10)
            
        })
        .frame(height: 70)
    }
    
    var machineBtn: some View {
        Image(.ticketMachine)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 103, height: 25)
    }
    
    var tickerbtn: some View {
        Image(.tickerButton)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 40, height: 25)
    }
    
    var joystickerView: some View {
        VStack(spacing: .zero) {
            Image(.joystickTop)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48, height: 106)
                .offset(y: 10)
                .zIndex(2)
            
            Image(.joystickBottom)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48, height: 25)
                .zIndex(1)
            
        }
    }

}
