//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI
import UIComponent
import Kingfisher

struct CalendarView: View {
    enum Constants {
        static let maxRowCount: CGFloat = 7
        static let cornorRadius: CGFloat = 4
        static let weekDayBottom: CGFloat = 70
        static let hP: CGFloat = 24
        static let qotBottom: CGFloat = 10
    }
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    @StateObject var viewModel: CalendarViewModel
    @State var showMonthList: Bool = false
    let addAction: (([Question]) -> Void)?
    let onTapAnswerAction: ((TodayAnswerSubmittedViewModel?) -> Void)?
    
    init(viewModel: CalendarViewModel,
         addAction: (([Question]) -> Void)?,
         onTapAnswerAction: ((TodayAnswerSubmittedViewModel?) -> Void)?,
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.addAction = addAction
        self.onTapAnswerAction = onTapAnswerAction
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                VStack(spacing: .zero) {
                    headerView(proxy)
                    weekDay(spacing: .zero, proxy: proxy)
                    monthListView(proxy: proxy)
                }
                
                if let head = viewModel.todayQuestions.first, viewModel.showTodayQuestion {
                    TodayQuestionView(question: head) {
                        addAction?(viewModel.organize())
                    }
                    .offset(y: -(AppTabbar.Constants.tabbarTotalH))
                    .padding(.horizontal, 40)
                    .padding(.bottom, Constants.qotBottom)
                    .transition(.opacity.animation(.easeInOut))
                }
            }
        }
        .defaultBackground()
        .onFirstAppear {
            Task.detached {
                await viewModel.generateMonths()
                await viewModel.scrollToCurrentMonth(animated: false)
                try? await viewModel.fetchData()
                try? await viewModel.fetchDataTodayQuestions()
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
                    .textStyle(font: .section, color: isFutureMonth ? AppColor.greyNeutral : AppColor.greyDark)
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
                                .textStyle(font: .heading)
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
                            .textStyle(size: 12, fontFamily: .littleThing)
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
                        .textStyle(font: .section)
                        .transition(.opacity)
                        .padding(.top, 8)
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
        GeometryReader { geo in
            ScrollView(.horizontal) {
                LazyHStack(spacing: .zero) {
                    ForEach(months) { month in
                        oneMonthView(month: month, proxy: proxy, containerHeight: geo.size.height)
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
        }
        .padding(.horizontal, Constants.hP)
        .padding(.vertical, 24)
    }
    
    @ViewBuilder
    func oneMonthView(month: CalendarMonth, proxy: GeometryProxy, containerHeight: CGFloat) -> some View {
        let maxQoTH: CGFloat = 120
        let innerContainerH = containerHeight - AppTabbar.Constants.tabbarTotalH - Constants.qotBottom - maxQoTH
        let parentWith = proxy.size.width - Constants.hP * 2
        let columns: Int = 7
        let columnW: CGFloat = parentWith / CGFloat(columns)
        let columnsG = (0 ..< columns).map { _ in GridItem(.fixed(columnW), spacing: .zero, alignment: .center)}
        let rowCount = CGFloat(max(1, (month.days.count + 6) / 7))
        let itemH: CGFloat = max(innerContainerH / rowCount, 1)
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columnsG, alignment: .center, spacing: .zero) {
                ForEach(month.days, id: \.id) { day in
                    CalendarItemView(
                        day: day,
                        addAction: {
                            addAction?(viewModel.organize())
                        }, didTapIcon: { answer in
                            onTapAnswerAction?(viewModel.generateAnswerDetailViewModel(answer))
                            viewModel.markIconAsRead(answer)
                        }
                    )
                    .frame(height: itemH)
                }
            }
            .overlay(
               CalendarGridLines(
                   columns: columns,
                   rowHeight: itemH,
                   color: AppColor.greyNeutral
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
    
    func footerView(momth: CalendarMonth) -> some View {
        let today = Date()
        let text: String
        if momth.date.isSameMonth(today) {
            if today.isSameDay(today.endOfMonth()) {
                text = "\(momth.iconCount) stamps collected so far \n take your time today"
            } else {
                text = "\(momth.iconCount) stamps collected so far \n take your time with the  \(momth.moreDaysTogo) days ahead"
            }
        } else {
            text = "\(momth.iconCount) stamps collected this month"
        }
        return Text(text)
            .multilineTextAlignment(.center)
            .textStyle(font: .section, color: AppColor.black)
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
                            .textStyle(font: .section,
                                       color: isCurrentMonth(month: month) ? AppColor.white : AppColor.black)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 12)
                            .background {
                                if isCurrentMonth(month: month) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AppColor.greyDark)
                                } else {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(style: .init(lineWidth: 1))
                                        .foregroundStyle(AppColor.greyDark)
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
                                font: .section,
                                color: AppColor.black,
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
                    font: .title,
                    color: AppColor.black
                )
        }
    }
}
