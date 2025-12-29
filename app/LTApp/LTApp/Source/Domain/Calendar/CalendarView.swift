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
        static let hP: CGFloat = 24
    }
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    @StateObject var viewModel: CalendarViewModel
    @State var showMonthList: Bool = false
    let addAction: (() -> Void)
    let onTapAnswerAction: ((TodayAnswerSubmittedViewModel?) -> Void)?
    
    init(viewModel: CalendarViewModel,
         addAction:  @escaping (() -> Void),
         onTapAnswerAction: ((TodayAnswerSubmittedViewModel?) -> Void)?,
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.addAction = addAction
        self.onTapAnswerAction = onTapAnswerAction
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: .zero) {
                headerView(proxy)
                weekDay(spacing: .zero, proxy: proxy)
                monthListView(proxy: proxy)
            }
        }
        .defaultBackground()
        .onFirstAppear {
            Task.detached {
                await viewModel.generateMonths()
                await viewModel.scrollToCurrentMonth()
            }
        }
    }
    
    @ViewBuilder func weekDay(spacing: CGFloat, proxy: GeometryProxy) -> some View {
        let count: CGFloat = 7
        let parentWidth = proxy.size.width - Constants.hP * 2
        let itemW = parentWidth / count
        let isFutureMonth = viewModel.currentMonth?.isFuture ?? false
        HStack(spacing: spacing) {
            ForEach(viewModel.weekdays, id: \.id) { day in
                Text(day.title)
                    .textStyle(size: 16, color: AppColor.color(hex: isFutureMonth ? 0xcdcdcd : 0x323232), fontFamily: .feltTipSeniorRegular)
                    .frame(width: itemW, height: 18)
            }
        }
        .padding(.horizontal, Constants.hP)
        .padding(.top, showMonthList ? 0 : 24)
    }

    @ViewBuilder func headerView(_ proxy: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                if let currentMonth = viewModel.currentMonth {
                    HStack(spacing: .zero) {
                        HStack(spacing: .zero) {
                            Text(currentMonth.date.monthDesc(isShort: false))
                                .textStyle(size: 36, fontFamily: .feltTipSeniorRegular)
                                .transition(.opacity)
                            Image(.downFillArrow)
                                .rotationEffect(.init(degrees: showMonthList ? -180 : 0))
                        }.onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showMonthList = !showMonthList
                            }
                        }
                      
                        Spacer()
                        Text(Date().dayDesc())
                            .textStyle(size: 18, fontFamily: .feltTipSeniorRegular)
                            .transition(.opacity)
                            .background(
                                Image(.brushCycle)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 29, height: 29)
                            )
                            .onTapGesture {
                                viewModel.scrollToCurrentMonth()
                            }

                    }
                    .padding(.horizontal, Constants.hP)
                   
                    Text(currentMonth.date.yearDesc())
                        .textStyle(size: 24, fontFamily: .feltTipSeniorRegular)
                        .transition(.opacity)
                        .padding(.top, 2)
                        .padding(.horizontal, Constants.hP)
                   
                }
            }
            monthView
        }
    }
    
    @ViewBuilder
    func monthListView(proxy: GeometryProxy) -> some View {
        let parentWith = proxy.size.width - Constants.hP * 2
        let months = viewModel.months.filter { $0.isValildMonth }
        ScrollView(.horizontal) {
            LazyHStack(spacing: .zero) {
                ForEach(months) { month in
                    oneMonthView(month: month, proxy: proxy)
                }
            }
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $viewModel.contentScrollPostion, anchor: .center)
        .onScrollGeometryChange(for: CGFloat.self, of: { $0.contentOffset.x}, action: { oldValue, newValue in
            let index = newValue / parentWith
            viewModel.onMonthContentScroll(index)
        })
        .onScrollPhaseChange({ oldPhase, newPhase in
            switch newPhase {
            case .idle:
                Task {
                    try? await viewModel.fetchData()
                }
            default: break
            }
        })
        .padding(.horizontal, Constants.hP)
        .padding(.vertical, 24)
    }
    
    @ViewBuilder
    func oneMonthView(month: CalendarMonth, proxy: GeometryProxy) -> some View {
        let parentWith = proxy.size.width - Constants.hP * 2
        let columns: Int = 7
        let columnW: CGFloat = parentWith / CGFloat(columns)
        let columnsG = (0 ..< columns).map { _ in GridItem(.fixed(columnW), spacing: .zero, alignment: .center)}
        let itemH: CGFloat = 88
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columnsG, alignment: .center, spacing: .zero) {
                ForEach(month.days, id: \.id) { day in
                    ClendarItemView(
                        day: day,
                        addAction: {
                            addAction()
                        }, didTapIcon: { answer in
                            onTapAnswerAction?(viewModel.generateAnswerDetailViewModel(answer))
                        }
                    )
                    .frame(height: itemH)
                }
            }
            .overlay(
               CalendarGridLines(
                   columns: columns,
                   rowHeight: itemH,
                   color: AppColor.color(hex: 0xcdcdcd)
               )
               .overlay(content: {
                   if month.isFuture {
                       monthLockView
                   }
               })
            )
            footerView(momth: month)
            Rectangle()
                .fill(Color.clear)
                .frame(height: 200)
        }
        .refreshable {
            try? await viewModel.fetchData()
        }
    }
    
    @ViewBuilder
    func footerView(momth: CalendarMonth) -> some View {
        Text("\(momth.iconCount) icons created this month \n \(momth.moreDaysTogo) more days to go!")
            .multilineTextAlignment(.center)
            .textStyle(size: 18, color: AppColor.color(hex: 0x000000), fontFamily: .feltTipSeniorRegular)
            .padding(.bottom, 50)
            .padding(.top, 20)
    }
    
    @ViewBuilder
    var monthView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.months, id: \.id) { month in
                    switch month.itemType {
                    case .normal:
                        Text("\(month.date.monthDesc(isShort: true))")
                            .textStyle(size: 20,
                                       color: isCurrentMonth(month: month) ? AppColor.color(hex: 0xffffff) : AppColor.color(hex: 0x000000),
                                       fontFamily: .feltTipSeniorRegular)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 12)
                            .background {
                                if isCurrentMonth(month: month) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AppColor.color(hex: 0x323232))
                                } else {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(style: .init(lineWidth: 1))
                                        .foregroundStyle(AppColor.color(hex: 0x323232))
                                }
                            }
                            .padding(.vertical, 6)
                            .id(month.id)
                            .onTapGesture {
                                Task {
                                   viewModel.didTapMonth(month)
                                }
                            }
                    case .yearPlaceholder:
                        Text("\(month.date.yearDesc())")
                            .textStyle(
                                size: 20,
                                color: AppColor.color(hex: 0x000000),
                                fontFamily: .feltTipSeniorRegular
                            )
                    }
                }
            }
            .padding(.horizontal, Constants.hP)
        }
        .scrollPosition(id: $viewModel.monthScrollPostion, anchor: .center)
        .frame(height: showMonthList ? 42 : 0)
        .padding(.vertical, showMonthList ? 12 : 0)
        .scaleEffect(.init(width: 1, height: showMonthList ? 1 : 0))
    }
    
    func isCurrentMonth(month: CalendarMonth) -> Bool {
        var selected = false
        if let currentMonth = viewModel.currentMonth, month.date.isSameMonth(currentMonth.date) {
            selected = true
        }
        return selected
    }
    
    var monthLockView: some View {
        VStack(spacing: .zero) {
            Image(.monthLock)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 42, height: 42)
            
            Text("The best is \n yet to come")
                .textStyle(
                    size: 36,
                    color: AppColor.color(hex: 0x000000),
                    fontFamily: .feltTipSeniorRegular
                )
        }
    }
}
