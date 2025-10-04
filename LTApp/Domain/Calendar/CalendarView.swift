//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct CalendarView: View {
    enum Constants {
        static let itemSize: CGSize = .init(width: 30, height: 30)
        static let maxRowCount: CGFloat = 7
        static let cornorRadius: CGFloat = 4
        static let weekDayBottom: CGFloat = 70
    }
    @StateObject var viewModel: CalendarViewModel = .init()
    @State var scrollPostion: UUID? = nil
    @Namespace var animationSpace
    
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
    }
    
    @ViewBuilder func weekDay(spacing: CGFloat, proxy: GeometryProxy) -> some View {
        let count: CGFloat = 7
        let itemW = proxy.size.width / count
        HStack(spacing: spacing) {
            ForEach(viewModel.weekdays, id: \.self) { day in
                Text(day)
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
                        switch day.dayType {
                        case .future:
                            Circle()
                                .fill(AppColor.color(hex: 0xCDCDCD))
                                .frame(width: 8, height: 8)
                        case .today:
                            Image(.calendarDripper)
                                .resizable()
                                .frame(width: 21, height: 26)
                        case .past:
                            Circle()
                                .fill(AppColor.color(hex: 0x000000))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .id(day.id)
                    .frame(width: columnW, height: columnW)
                    .overlay {
                        if day.date.isTheFirstDayInMonth {
                            switch day.dayType {
                            case .future:
                                Text("\(day.date.monthDesc())")
                                    .textStyle(size: 12, color: AppColor.color(hex: 0xCDCDCD), fontFamily: .sfProRegular)
                                    .offset(y: -columnW * 0.35)
                            case .today:
                                Image(.calendarDripper)
                                    .resizable()
                                    .frame(width: 21, height: 26)
                            case .past, .today:
                                Text("\(day.date.monthDesc())")
                                    .textStyle(size: 12, color: AppColor.color(hex: 0x000000), fontFamily: .sfProRegular)
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
        .scrollPosition(id: $scrollPostion)
        .onScrollGeometryChange(for: CGPoint.self, of: { $0.contentOffset }, action: { oldValue, newValue in
            let rowIndex = Int(newValue.y / columnW)
            guard rowIndex >= 0 else { return }
            let lastDayIndex = rowIndex * columns + (columns - 1)
            let currentDate = viewModel.days[min(lastDayIndex, viewModel.days.count - 1)]
            viewModel.currentMonth = currentDate.date
        })
        .animation(.easeInOut, value: viewModel.currentMonth)
        
    }
    
    @ViewBuilder  func headerView(_ proxy: GeometryProxy) -> some View {
        let count: CGFloat = 7
        let itemW = proxy.size.width / count
        let btnW: CGFloat = 30
        HStack(spacing: .zero) {
            Button(action: {}) {
                Image(.leftPoly)
                Spacer()
            }
            .contentShape(.rect)
            .frame(width: btnW, height: btnW)
            Spacer()
            VStack(spacing: 10) {
                Text(viewModel.currentMonth?.monthDesc(isShort: false) ?? "")
                    .textStyle(size: 36)
                
                Text(viewModel.currentMonth?.yearDesc() ?? "")
                    .textStyle(size: 24)
                
            }
            Spacer()
            Button(action: {}) {
                Spacer()
                Image(.rightPloly)
            }
            .contentShape(.rect)
            .frame(width: btnW, height: btnW)
        }
        .padding(.horizontal, itemW * 0.35)
        .padding(.top, 30)
        .padding(.bottom, 30)
    }
}

