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
                do {
                    await viewModel.generateMonthForYear(2025)
                    try await viewModel.fetchData()
                    await viewModel.scrollToCurrentMonth()
                } catch {
                    print(error)
                }
            }
        }
        .animation(.easeInOut, value: viewModel.showTodayAnswerView)
      
    }
    
    @ViewBuilder func weekDay(spacing: CGFloat, proxy: GeometryProxy) -> some View {
        let count: CGFloat = 7
        let parentWidth = proxy.size.width - Constants.hP * 2
        let itemW = parentWidth / count
        HStack(spacing: spacing) {
            ForEach(viewModel.weekdays, id: \.id) { day in
                Text(day.title)
                    .textStyle(size: 16, color: AppColor.color(hex: 0x323232), fontFamily: .feltTipSeniorRegular)
                    .frame(width: itemW, height: 18)
            }
        }
        .padding(.horizontal, Constants.hP)
    }

    @ViewBuilder func headerView(_ proxy: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if let currentMonth = viewModel.currentMonth {
                HStack(spacing: .zero) {
                    Text(currentMonth.monthDesc(isShort: false))
                        .textStyle(size: 36, fontFamily: .feltTipSeniorRegular)
                        .transition(.opacity)
                    
                    Button(action: {
                        viewModel.goPreviousMonth()
                    }) {
                        Image(.downFillArrow)
                        Spacer()
                    }
                    .contentShape(.rect)
                    .frame(width: 24, height: 24)
                    
                    Spacer()
                    
                    Text(currentMonth.dayDesc())
                        .textStyle(size: 18, fontFamily: .feltTipSeniorRegular)
                        .transition(.opacity)

                }
                .padding(.horizontal, Constants.hP)
                Text(currentMonth.yearDesc())
                    .textStyle(size: 24, fontFamily: .feltTipSeniorRegular)
                    .transition(.opacity)
                    .padding(.top, 2)
                    .padding(.horizontal, Constants.hP)
               
            }
            
            monthView
        }
    }
    
    @ViewBuilder
    func monthListView(proxy: GeometryProxy) -> some View {
        let parentWith = proxy.size.width - Constants.hP * 2
        let columns: Int = 7
        let columnW: CGFloat = parentWith / CGFloat(columns)
        let columnsG = (0 ..< columns).map { _ in GridItem(.fixed(columnW), spacing: .zero, alignment: .center)
        }
       let itemH: CGFloat = 88
        ScrollView(.horizontal) {
            HStack(spacing: .zero) {
                ForEach(viewModel.months) { month in
                     ScrollView(showsIndicators: false) {
                         LazyVGrid(columns: columnsG, alignment: .center, spacing: .zero) {
                             ForEach(month.days, id: \.id) { day in
                                 ClendarItemView(day: day, addAction: {
                                     addAction()
                                 })
                                     .frame(height: itemH)
                             }
                         }
                         .overlay(
                            CalendarGridLines(
                                columns: columns,
                                rowHeight: itemH,
                                color: AppColor.color(hex: 0xcdcdcd)
                            )
                         )
                         footerView(momth: month)
                         Rectangle()
                             .fill(Color.clear)
                             .frame(height: 200)
                     }
                     .frame(width: parentWith)
                     .id(month.id)
                }
            }
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $viewModel.scrollPostion, anchor: .center)
        .padding(.horizontal, Constants.hP)
        .padding(.vertical, 24)
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
                }
            }
            .padding(.horizontal, Constants.hP)
        }
        .frame(height: 42)
        .padding(.vertical, 12)
        .scrollPosition(id: $viewModel.scrollPostion, anchor: .center)
    }
    
    func isCurrentMonth(month: CalendarMonth) -> Bool {
        var selected = false
        if let currentMonth = viewModel.currentMonth, month.date.isSameMonth(currentMonth) {
            selected = true
        }
        return selected
    }
}
