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
        ZStack {
            GeometryReader { proxy in
                ZStack {
                    VStack(spacing: .zero) {
                        headerView(proxy)
                        weekDay(spacing: .zero, proxy: proxy)
                        monthListView(proxy: proxy)
                        Spacer()
                    }
                    
                }
            }
            .padding(.horizontal, 20)
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
        }
        .animation(.easeInOut, value: viewModel.showTodayAnswerView)
      
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
    
    @ViewBuilder
    func monthListView(proxy: GeometryProxy) -> some View {
        let columns: Int = 7
        let columnW: CGFloat = proxy.size.width / CGFloat(columns)
        let columnsG = (0 ..< columns).map { _ in GridItem(.fixed(columnW), spacing: .zero, alignment: .center)
        }
       let itemH: CGFloat = 88
        ScrollView(.horizontal) {
            HStack(spacing: .zero) {
                ForEach(viewModel.months) { month in
                     ScrollView(showsIndicators: false) {
                         LazyVGrid(columns: columnsG, alignment: .center, spacing: .zero) {
                             ForEach(month.days, id: \.id) { day in
                                 ClendarItemView(day: day)
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
                         Rectangle()
                             .fill(Color.clear)
                             .frame(height: 200)
                     }
                     .frame(width: proxy.size.width)
                     .id(month.id)
                }
            }
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $viewModel.scrollPostion, anchor: .center)
    }
}

