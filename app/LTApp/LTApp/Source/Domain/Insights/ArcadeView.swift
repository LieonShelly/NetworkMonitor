//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
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
    @State private var joystickAngle: Double = 0
    @State private var tickerPressed: [Bool] = [false, false, false]
    @State private var contentWidth: CGFloat = 0
    
    enum Constants {
        static let rpPadding: CGFloat = 12 + 20 + 28
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            tokenHeader
            screen
            controlPanel
        }
        .onAppear {
            Task.detached {
                try? await viewModel.fetchHistoryHeaderWeekIcons()
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
            .padding(.leading, 24)
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
    }
    
    private var iconCountText: String {
        guard let currentIcons = viewModel.currentIcons else { return "0 / 0" }
        return currentIcons.minAnswersToGenerateReport <= currentIcons.icons.count ? "FULL" : "\(currentIcons.icons.count)/\(currentIcons.minAnswersToGenerateReport)"
    }
    
    private var isFull: Bool {
        guard let currentIcons = viewModel.currentIcons else { return false }
        return currentIcons.minAnswersToGenerateReport <= currentIcons.icons.count
    }
    
    @ViewBuilder
    private var iconContent: some View {
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
        .background(
            GeometryReader { contentGeo in
                Color.clear
                    .onAppear { contentWidth = contentGeo.size.width }
                    .onChange(of: contentGeo.size.width) { oldValue, newValue in contentWidth = newValue }
            }
        )
    }

    @ViewBuilder
    private var iconRow: some View {
        GeometryReader { geo in
            let isScrollable = (contentWidth + 14) > geo.size.width
            let shouldAutoPlay = isFull && isScrollable
            
            Group {
                if shouldAutoPlay {
                    InfiniteMarqueeView(
                        contentWidth: contentWidth,
                        spacing: 6,
                        paddingLeading: 14, paddingVertical: 10
                    ) {
                        iconContent
                    }
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        iconContent
                            .padding(.leading, 14)
                            .padding(.vertical, 10)
                    }
                }
            }
        }
        .clipped()
        .frame(height: 48)
        .padding(.horizontal, 10)
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
        if !viewModel.unreadHisotrys.isEmpty {
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
                            .padding(.horizontal, 56)
                  
                    case .readyToPrint:
                        ZStack {
                            if let scene = scene {
                                iconLoadingView(scene: scene)
                                    .opacity(viewModel.startedReadyToPrint ? 1 : 0)
                                    .frame(height: geo.size.height)
                            }
                            if !viewModel.startedReadyToPrint {
                                rpIdleView
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .frame(height: geo.size.height)
                            }
                        }
                        .frame(height: geo.size.height)
                        .padding(.horizontal, 40)
                        .animation(.easeInOut, value: viewModel.startedReadyToPrint)
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
            .scrollDisabled(viewModel.arcadeState == .readyToPrint)
            .refreshable {
               await refresh()
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
            .onChange(of: viewModel.startedReadyToPrint) { oldValue, newValue in
                scene?.removeAllChildren()
            }
        }
    }
    
    func refresh() async {
        try? await viewModel.fetchHistoryHeaderWeekIcons()
        try? await viewModel.fetchHistory()
        await viewModel.refreshArcadeState()
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
                viewModel.startedReadyToPrint = true
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
                        Image(.rectangle52)
                            .resizable()
                            .frame(width: 157, height: 60)
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
                tickerbtn(index: 0)
                    .offset(x: 10)
                tickerbtn(index: 1)
                    .offset(y: 20)
                tickerbtn(index: 2)
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
    
    func tickerbtn(index: Int) -> some View {
        Image(.tickerButton)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 40, height: 25)
            .scaleEffect(tickerPressed[index] ? 0.85 : 1.0)
            .offset(y: tickerPressed[index] ? 2 : 0)
            .animation(.easeInOut(duration: 0.08), value: tickerPressed[index])
            .onTapGesture {
                tickerPressed[index] = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    tickerPressed[index] = false
                }
            }
    }
    
    var joystickerView: some View {
        let maxAngle: Double = 25
        
        return VStack(spacing: .zero) {
            Image(.joystickTop)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48, height: 106)
                .rotation3DEffect(
                    .degrees(joystickAngle),
                    axis: (x: 1, y: 1, z: 1),
                    anchor: .bottom,
                    perspective: 0
                )
                .offset(y: 10)
                .zIndex(2)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let angle = Double(value.translation.width) * 0.5
                            joystickAngle = min(max(angle, -maxAngle), maxAngle)
                        }
                        .onEnded { _ in
                            withAnimation(.interpolatingSpring(stiffness: 300, damping: 12)) {
                                joystickAngle = 0
                            }
                        }
                )
            
            Image(.joystickBottom)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48, height: 25)
                .zIndex(1)
        }
    }

}
