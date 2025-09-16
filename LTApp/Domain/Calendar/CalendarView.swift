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
        VStack(spacing: .zero) {
            titleView
            calendarContentView
            Spacer()
        }
        .defaultBackground()
        
    }
    
    var titleView: some View {
        Text("The Little Things")
            .textStyle(size: 36)
            .padding(.top, 35)
    }
    
    var mothTitleView: some View {
        Text("September")
            .textStyle(size: 18, fontFamily: .sfProMedium)
            .padding(.bottom, 26)
            .padding(.leading, Constants.itemSize.width * 0.3)
        
    }
    
    var calendarContentView: some View {
        GeometryReader { proxy in
            let itemSpacing = (proxy.size.width - 7 * Constants.itemSize.width) / 8.0
            VStack(spacing: .zero) {
                weekDay(spacing: itemSpacing)
                .frame(width: proxy.size.width)
                .padding(.bottom, Constants.weekDayBottom)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: .zero) {
                        ForEach(viewModel.monthList, id: \.id) { month in
                            monthView(days: month.days, spacing: itemSpacing)
                                .frame(width: proxy.size.width)
                        }
                    }
                }
                .scrollTargetBehavior(.paging)
                
                .frame(height: Constants.itemSize.height * 6 + itemSpacing * 5)
            }
        }
            .padding(.top, 65)
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
    
    @ViewBuilder func weekDay(spacing: CGFloat) -> some View {
       let itemW: CGFloat = Constants.itemSize.width
       VStack(alignment: .leading) {
           mothTitleView
           HStack(spacing: spacing) {
               ForEach(viewModel.weekdays, id: \.self) { day in
                   Text(day)
                       .textStyle(size: 14, color: AppColor.color(hex: 0x323232), fontFamily: .sfProRegular)
                       .frame(width: itemW, height: itemW)
               }
           }
           .frame(height: Constants.itemSize.height)
       }
    
      
    }
}

#Preview(body: {
    CalendarView()
})
