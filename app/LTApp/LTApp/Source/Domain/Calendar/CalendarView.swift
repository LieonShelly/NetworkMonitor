//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent
import Kingfisher

struct CalendarView: View {
    enum Constants {
        static let itemSize: CGSize = .init(width: 30, height: 30)
        static let maxRowCount: CGFloat = 7
        static let cornorRadius: CGFloat = 4
        static let weekDayBottom: CGFloat = 70
    }
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    @StateObject var viewModel: CalendarViewModel
    let addAction: (() -> Void)
    
    init(viewModel: CalendarViewModel, addAction:  @escaping (() -> Void)) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.addAction = addAction
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: .zero) {
                headerView(proxy)
                weekDay(spacing: .zero, proxy: proxy)
                gridView(proxy: proxy)
                Spacer()
            }
        }
        .padding(.horizontal, 10)
        .defaultBackground()
        .onFirstAppear {
            Task.detached {
                do {
                   await viewModel.generateDay()
                    try await viewModel.fetchData()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    @ViewBuilder func weekDay(spacing: CGFloat, proxy: GeometryProxy) -> some View {
        let count: CGFloat = 7
        let itemW = proxy.size.width / count
        HStack(spacing: spacing) {
            ForEach(viewModel.weekdays, id: \.id) { day in
                Text(day.title)
                    .textStyle(size: 14, color: AppColor.color(hex: 0x323232), fontFamily: .sfProRegular)
                    .frame(width: itemW, height: itemW)
            }
        }
    }
    
    @ViewBuilder
    func gridView(proxy: GeometryProxy) -> some View {
        let columns: Int = 7
        let columnW: CGFloat = proxy.size.width / CGFloat(columns)
        let columnsG = (0 ..< columns).map { _ in GridItem(.fixed(columnW), spacing: .zero, alignment: .center)
        }
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columnsG, alignment: .center, spacing: .zero) {
                ForEach(viewModel.days, id: \.id) { day in
                    HStack {
                        if let currentMonth = viewModel.currentMonth {
                            if day.date.isSameMonth(currentMonth) {
                                if let dripleTransitionData = homeCoordinator.dripleTransitionData, let reflections = day.reflections {
                                    if day.date.isSameDay(dripleTransitionData.date) {
                                        if dripleTransitionData.showCalendarDripple {
                                            dayIcon(day)
                                                .matchedGeometryEffect(id: "dripple", in: dripleTransitionData.drippleAnimationSpace)
                                                .frame(width: 24, height: 24)
                                        } else {
                                            dayIcon(day)
                                        }
                                        
                                        Color.clear.frame(width: .zero, height: .zero)
                                            .onAppear {
                                                homeCoordinator.dripleTransitionData?.showDrippleClose = true
                                            }
                                       
                                    } else {
                                        dayIcon(day)
                                    }
                                } else if let reflections = day.reflections {
                                    dayIcon(day)
                                } else if day.dayType == .today {
                                    addBtn
                                } else {
                                    dot
                                }
                            } else if day.date.isPreviousMonth(currentMonth) {
                                   Text("\(day.date.dayDesc())")
                                       .textStyle(size: 12, color: AppColor.color(hex: 0xCDCDCD), fontFamily: .sfProRegular)
                            } else {
                                dot
                            }
                        } else {
                            dot
                        }
                    }
                    .id(day.id)
                    .frame(width: columnW, height: columnW)
                    .overlay {
                        if day.date.isTheFirstDayInMonth {
                            if let currentMonth = viewModel.currentMonth, day.date.isSameMonth(currentMonth) {
                                Text("\(day.date.monthDesc())")
                                    .textStyle(size: 12, color: AppColor.color(hex: 0x000000), fontFamily: .sfProRegular)
                                    .offset(y: -columnW * 0.35)
                            } else {
                                Text("\(day.date.monthDesc())")
                                    .textStyle(size: 12, color: AppColor.color(hex: 0xCDCDCD), fontFamily: .sfProRegular)
                                    .offset(y: -columnW * 0.35)
                            }
                        }
                    }
                }
            }
            Rectangle()
                .fill(Color.clear)
                .frame(height: 200)
        }
        .scrollPosition(id: $viewModel.scrollPostion, anchor: .top)
        .onScrollGeometryChange(for: CGPoint.self, of: { $0.contentOffset }, action: { oldValue, newValue in
            let rowIndex = Int(newValue.y / columnW)
            guard rowIndex >= 0, !viewModel.days.isEmpty else { return }
            let lastDayIndex = (rowIndex + 1) * columns + (columns - 1)
            let currentDate = viewModel.days[min(lastDayIndex, viewModel.days.count - 1)]
            withAnimation(.easeIn(duration: 0.25)) {
                viewModel.currentMonth = currentDate.date
            }
        })
    }
    
    @ViewBuilder func headerView(_ proxy: GeometryProxy) -> some View {
        let count: CGFloat = 7
        let itemW = proxy.size.width / count
        let btnW: CGFloat = 30
        HStack(spacing: .zero) {
            Button(action: {
                viewModel.goPreviousMonth()
            }) {
                Image(.leftPoly)
                Spacer()
            }
            .contentShape(.rect)
            .frame(width: btnW, height: btnW)
            Spacer()
            VStack(spacing: 10) {
                if let currentMonth = viewModel.currentMonth {
                    Text(currentMonth.monthDesc(isShort: false))
                        .textStyle(size: 36)
                        .transition(.opacity)
                    
                    Text(currentMonth.yearDesc())
                        .textStyle(size: 24)
                        .transition(.opacity)
                }
            }
            Spacer()
            Button(action: {
                viewModel.goNextMonth()
            }) {
                Spacer()
                Image(.rightPloly)
            }
            .contentShape(.rect)
            .frame(width: btnW, height: btnW)
        }
        .padding(.horizontal, itemW * 0.35)
        .padding(.top, 30)
        .padding(.bottom, 30)
        .animation(.easeInOut, value: viewModel.scrollPostion)
    }
    
    @State private var isBreathing = false
    var addBtn: some View {
        Button {
            addAction()
        } label: {
            LinearGradient(
                colors: [
                    AppColor.color(hex: 0x040404),
                    AppColor.color(hex: 0x656565)
                ],
                startPoint: .init(x: 0, y: 0),
                endPoint: .init(x: 1, y: 0.7)
            )
            .cornerRadius(20, corners: .allCorners)
            .blur(radius: 3)
            .frame(width: 40, height: 40)
            .overlay {
                Image(.smallAdd)
                    .resizable()
                    .frame(width: 16, height: 16)
            }
            .scaleEffect(isBreathing ? 1.2 : 1.0)
            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true),
                       value: isBreathing
            )
            .task {
                isBreathing = true
            }
        }
       
    }
    
    var dot: some View {
        Circle()
            .fill(AppColor.color(hex: 0xCDCDCD))
            .frame(width: 8, height: 8)
    }
    
    @ViewBuilder
    func dayIcon(_ day: CalendarDay) -> some View {
        if let reflections = day.reflections?.reflections, !reflections.isEmpty {
            let reflection = reflections.last
            if reflections.count == 1 {
                
                if day.dayType == .today {
                    toDayIconView(reflection?.icon)
                        .onTapGesture {
                            if let reflection {
                                homeCoordinator.push(HomeRoute.answerDetail(reflection))
                            }
                        }
                } else {
                    iconView(reflection?.icon)
                        .onTapGesture {
                            if let reflection {
                                homeCoordinator.push(HomeRoute.answerDetail(reflection))
                            }
                        }
                }
            } else {
                if let icon = reflection?.icon {
                    if day.dayType == .today {
                        toDayIconView(icon)
                            .onTapGesture {
                                if let reflection {
                                    homeCoordinator.push(HomeRoute.answerDetail(reflection))
                                }
                            }
                    } else {
                        iconView(icon)
                            .onTapGesture {
                                if let reflection {
                                    homeCoordinator.push(HomeRoute.answerDetail(reflection))
                                }
                            }
                    }
                } else {
                    placeholderIcon
                }
            }
        }
    
    }
    
    var placeholderIcon: some View {
        Circle()
            .fill(Color.clear)
            .overlay(content: {
                Image(.calendarDripper)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            })
            .frame(width: 24, height: 24)
    }
    
    @ViewBuilder
    func iconView(_ icon: IconData?) -> some View {
        if let icon {
            switch icon.status {
            case .pending:
                Image(.lock)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            case .generated:
                if let url = icon.url {
                    ThumbnailIconImageView(url: url) {
                        placeholderIcon
                    }
                    .frame(width: 24, height: 24)
                }
            case .failed:
                Image(.lock)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            }
        } else {
            placeholderIcon
        }
    }
    
    
    @ViewBuilder
    func toDayIconView(_ icon: IconData?) -> some View {
        if let icon {
            switch icon.status {
            case .pending:
                Image(.lock)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            case .generated:
                if let url = icon.url {
                    ThumbnailIconImageView(url: url) {
                        placeholderIcon
                    }
                    .frame(width: 24, height: 24)
                }
            case .failed:
                Image(.lock)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            }
        } else {
            placeholderIcon
        }
    }
}
