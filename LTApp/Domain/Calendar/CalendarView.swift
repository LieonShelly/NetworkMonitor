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
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: .zero) {
                weekDay(spacing: .zero, proxy: proxy)
                gridView(proxy: proxy)
                Spacer()
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 65)
        .defaultBackground()
    }
    
    @ViewBuilder
    func monthView(days: [CalendarDay], spacing: CGFloat) -> some View {
        let itemWidth: CGFloat = Constants.itemSize.width
        let columns = Array(repeating: GridItem(.fixed(itemWidth), spacing: spacing), count: 7)
        LazyVGrid(
            columns: columns,
            spacing: spacing,
            content: {
                ForEach(days) { day in
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: itemWidth, height: itemWidth)
                        .overlay {
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
                             
                                Text("\(Calendar.current.component(.day, from: day.date))")
                                    .textStyle(size: 12, color: AppColor.color(hex: 0xCDCDCD), fontFamily: .sfProRegular)
                            }
                        }
                }
            })
      
    }
    
    @ViewBuilder func weekDay(spacing: CGFloat, proxy: GeometryProxy) -> some View {
        let count: CGFloat = 7
        let itemW = proxy.size.width / count
        VStack(alignment: .leading, spacing: .zero) {
            Text("September")
                .textStyle(size: 18, fontFamily: .sfProMedium)
                .padding(.leading, itemW * 0.35)
                .padding(.bottom, itemW * 0.35)
            
            HStack(spacing: spacing) {
                ForEach(viewModel.weekdays, id: \.self) { day in
                    Text(day)
                        .textStyle(size: 14, color: AppColor.color(hex: 0x323232), fontFamily: .sfProRegular)
                        .frame(width: itemW, height: itemW)
                }
            }
        }
      
    }
    
    @ViewBuilder
    func gridView(proxy: GeometryProxy) -> some View {
        ScrollView(showsIndicators: false) {
            let columns: Int = 7
            let columnW: CGFloat = proxy.size.width / CGFloat(columns)
            let columnsG = (0 ..< columns).map { _ in GridItem(.fixed(columnW), spacing: .zero, alignment: .center)
            }
            LazyVGrid(columns: columnsG, alignment: .center, spacing: .zero) {
                ForEach(viewModel.days, id: \.id) { day in
                    HStack {
                        Text("\(Calendar.current.component(.day, from: day.date))")
                            .textStyle(size: 12, color: AppColor.color(hex: 0xCDCDCD), fontFamily: .sfProRegular)
                           
                    }
                    .frame(width: columnW, height: columnW)
                    .overlay {
                        if day.date.isTheFirstDayInMonth {
                            Text("\(day.date.monthDesc())")
                                .textStyle(size: 12, color: Color.red, fontFamily: .sfProRegular)
                                .offset(y: -columnW * 0.35)
                        }
                    }
                }
            }
            Spacer()
        }
       
    }
}

#Preview(body: {
    CalendarView()
})
