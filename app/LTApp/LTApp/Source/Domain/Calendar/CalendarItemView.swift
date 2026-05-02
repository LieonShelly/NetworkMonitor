//
//  ClendarItemView.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/22.
//

import UIComponent
import SwiftUI

struct CalendarItemView: View {
    let day: CalendarDay
    let addAction: (() -> Void)
    let didTapIcon: ((Answer) -> Void)
    
    
    init(day: CalendarDay, addAction: @escaping () -> Void, didTapIcon: @escaping (Answer) -> Void, isBreathing: Bool = false) {
        self.day = day
        self.addAction = addAction
        self.didTapIcon = didTapIcon
        self.isBreathing = isBreathing
    }
    
    enum Constants {
        static let iconViewTop: CGFloat = 23
        static let iconViewBotton: CGFloat = 8
        static let fourIconHSp: CGFloat = 2
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(content: {
                VStack {
                    if day.isCurrentMonth, let answers = day.reflections?.reflections, !answers.isEmpty {
                        switch answers.count {
                        case 1:
                            oneIcon(answers.first!, proxy: proxy)
                        case 2:
                            twoIcon(answers, proxy: proxy)
                        case 3:
                            threeIcon(answers, proxy: proxy)
                        default:
                            fourIcon(answers, proxy: proxy)
                        }
                    } else if day.isToday {
                        addBtn
                    } else if day.isAbsent && day.dayType != .future {
                        slashLine
                    }
                }
                dateView
            })
        }
    }
    
    var dateView: some View {
        HStack {
            VStack {
                Text(day.date.dayDesc())
                    .textStyle(font: .subSection,
                               color: dateTextColor(day))
                    .background {
                        if day.isToday, day.reflections == nil {
                            Image(.brushCycle)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                        }
                    }
                    .padding(.top, 4)
                Spacer()
            }
            Spacer()
        }
        .padding(.leading, 4)
        .padding(.top, 4)
        .opacity(day.isCurrentMonth ? 1 : 0)
    }
    
    func dateTextColor(_ day: CalendarDay) -> Color {
        switch day.dayType {
        case .past:
            if day.reflections == nil {
                return AppColor.greyNeutral
            }
        case .today:
            if day.reflections == nil {
                return AppColor.greyNeutral
            }
        case .future:
            break
        }
      return  AppColor.greyDark
    }
    
    @ViewBuilder
    func oneIcon(_ answer: Answer, proxy: GeometryProxy) -> some View {
        let top: CGFloat = 23
        let bottom: CGFloat = 8
        VStack {
            Spacer()
            iconView(answer)
             
        }
        .padding(.top, top)
        .padding(.bottom, bottom)
        .onTapGesture {
            if answer.icon?.readAt != nil {
                didTapIcon(answer)
            }
        }
    }
    
    @ViewBuilder
    func twoIcon(_ answers: [Answer], proxy: GeometryProxy) -> some View {
        let top: CGFloat = 23
        let horizontalPadding: CGFloat = 6
        let bottom: CGFloat = 6
        let contentWidth = max(proxy.size.width - horizontalPadding * 2, 0)
        let contentHeight = max(proxy.size.height - top - bottom, 0)
        let vspacing = max(contentHeight * 0.04, 2)
        let iconSize = min(contentWidth * 0.64, max((contentHeight - vspacing) / 2, 0))
        let xOffset = min(contentWidth * 0.16, iconSize * 0.45)
        
        VStack {
            VStack(spacing: vspacing) {
                if let answer = answers.first {
                    iconView(answer, size: .init(width: iconSize, height: iconSize))
                        .offset(x: xOffset)
                        .onTapGesture {
                            if answer.icon?.readAt != nil {
                                didTapIcon(answer)
                            }
                        }
                }
                if let answer = answers.last {
                    iconView(answer, size: .init(width: iconSize, height: iconSize))
                        .offset(x: -xOffset)
                        .onTapGesture {
                            if answer.icon?.readAt != nil {
                                didTapIcon(answer)
                            }
                        }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .padding(.top, top)
        .padding(.horizontal, horizontalPadding)
        .padding(.bottom, bottom)
        .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
    }
    
    @ViewBuilder
    func threeIcon(_ answers: [Answer], proxy: GeometryProxy) -> some View {
        let top: CGFloat = 23
        let horizontalPadding: CGFloat = 6
        let bottom: CGFloat = 6
        let contentWidth = max(proxy.size.width - horizontalPadding * 2, 0)
        let contentHeight = max(proxy.size.height - top - bottom, 0)
        let vspacing = max(contentHeight * 0.04, 2)
        let iconSize = min(contentWidth * 0.62, max((contentHeight - vspacing * 2) / 3, 0))
        let xOffset = min(contentWidth * 0.16, iconSize * 0.45)
        
        VStack {
            VStack(spacing: vspacing) {
                if let answer = answers.first {
                    iconView(answer, size: .init(width: iconSize, height: iconSize))
                        .offset(x: xOffset)
                        .onTapGesture {
                            if answer.icon?.readAt != nil {
                                didTapIcon(answer)
                            }
                        }
                }
                iconView(answers[1], size: .init(width: iconSize, height: iconSize))
                    .offset(x: -xOffset)
                    .onTapGesture {
                        if answers[1].icon?.readAt != nil {
                            didTapIcon(answers[1])
                        }
                    }
                if let answer = answers.last {
                    iconView(answer, size: .init(width: iconSize, height: iconSize))
                        .offset(x: xOffset)
                        .onTapGesture {
                            if answer.icon?.readAt != nil {
                                didTapIcon(answer)
                            }
                        }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .padding(.top, top)
        .padding(.horizontal, horizontalPadding)
        .padding(.bottom, bottom)
        .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
    }
    
    @ViewBuilder
    func fourIcon(_ answers: [Answer], proxy: GeometryProxy) -> some View {
        let top: CGFloat = 23
        let horizontalPadding: CGFloat = 6
        let bottom: CGFloat = 6
        let contentWidth = max(proxy.size.width - horizontalPadding * 2, 0)
        let contentHeight = max(proxy.size.height - top - bottom, 0)
        let vspacing = max(contentHeight * 0.04, 2)
        let iconSize = min(contentWidth * 0.52, max((contentHeight - vspacing * 2) / 3, 0))
        let hPadding = max((contentWidth - iconSize * 2) * 0.5, 0)
        let textRP = 0.0
        
        VStack {
            VStack(spacing: vspacing) {
                if let answer = answers.first {
                    HStack {
                        iconView(answer, size: .init(width: iconSize, height: iconSize))
                            .padding(.leading, hPadding)
                        Spacer()
                    }
                    .onTapGesture {
                        if answer.icon?.readAt != nil {
                            didTapIcon(answer)
                        }
                    }
                }
                HStack {
                    Spacer()
                    iconView(answers[1], size: .init(width: iconSize, height: iconSize))
                        .padding(.trailing, hPadding)
                }
                .onTapGesture {
                    if answers[1].icon?.readAt != nil {
                        didTapIcon(answers[1])
                    }
                }
                if let answer = answers.last {
                    ZStack(alignment: .trailing) {
                        HStack {
                            iconView(answer, size: .init(width: iconSize, height: iconSize))
                                .padding(.leading, hPadding)
                            Spacer()
                        }
                        .onTapGesture {
                            if answer.icon?.readAt != nil {
                                didTapIcon(answer)
                            }
                        }
                        
                        Text("\(answers.count - 3)+")
                            .textStyle(size: 8, color: AppColor.color(hex: 0x000000), fontFamily: .poppinsMediumItalic)
                            .padding(.trailing, textRP)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .padding(.top, top)
        .padding(.horizontal, horizontalPadding)
        .padding(.bottom, bottom)
        .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
    }
    
    @ViewBuilder
    func iconView(_ answer: Answer, size: CGSize = .init(width: 24, height: 24)) -> some View {
        IconView(iconData: answer.icon, size: size) {
            didTapIcon(answer)
        }
    }
    
    
    @State private var isBreathing = false
    @ViewBuilder
    var addBtn: some View {
        Spacer()
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
            .frame(width: 26, height: 26)
            .overlay {
                Image(.smallAdd)
                    .resizable()
                    .frame(width: 10, height: 10)
            }
            .scaleEffect(isBreathing ? 1.2 : 1.0)
            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true),
                       value: isBreathing
            )
            .task {
                isBreathing = true
            }
        }
        .padding(.bottom, 8)
        
    }
    
    @ViewBuilder
    var slashLine: some View {
        Spacer()
        CalendarSlashLine()
            .frame(width: 20, height: 15)
            .padding(.bottom, 15)
            .opacity(day.isCurrentMonth ? 1 : 0)
    }
}
