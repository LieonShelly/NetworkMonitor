//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct CalendarView: View {
    enum Constants {
        static let itemSize: CGSize = .init(width: 30, height: 30)
        static let spacing: CGFloat = 10
        static let maxRowCount: CGFloat = 7
        static let cornorRadius: CGFloat = 4
    }
    @StateObject var viewModel: CalendarViewModel = .init()
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: Constants.spacing) {
               weekDay()
                    .frame(width: proxy.size.width, height: Constants.itemSize.height)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: .zero) {
                        ForEach(viewModel.monthList, id: \.id) { month in
                            moth(days: month.days)
                                .frame(width: proxy.size.width)
                        }
                    }
                }
                .scrollTargetBehavior(.paging)
            }
            .frame(height: Constants.maxRowCount * Constants.itemSize.height + (Constants.maxRowCount) * Constants.spacing)
            
        }
        
    }
    
    @ViewBuilder
    func moth(days: [CalendarDay]) -> some View {
        let itemWidth: CGFloat = Constants.itemSize.width
        let columns = Array(repeating: GridItem(.fixed(itemWidth), spacing: Constants.spacing), count: 7)
        LazyVGrid(
            columns: columns,
            spacing: Constants.spacing,
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
    
   @ViewBuilder func weekDay() -> some View {
       let itemW: CGFloat = Constants.itemSize.width
        let spacing = Constants.spacing
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

#Preview(body: {
    HStack {
        CalendarView()
    }
    .padding()
})
