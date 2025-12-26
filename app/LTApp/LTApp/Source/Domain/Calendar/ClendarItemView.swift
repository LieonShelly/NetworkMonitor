//
//  ClendarItemView.swift
//  LTApp
//
//  Created by Renjun Li on 2025/12/22.
//

import UIComponent
import SwiftUI

struct ClendarItemView: View {
    let day: CalendarDay
    let addAction: (() -> Void)
    let didTapIcon: ((Answer) -> Void)
    
    enum Constants {
        static let iconViewTop: CGFloat = 23
        static let iconViewBotton: CGFloat = 8
        static let fourIconHSp: CGFloat = 2
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(content: {
                VStack {
                    if let answers = day.reflections?.reflections, !answers.isEmpty {
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
                    } else if day.isConsecutive {
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
                    .textStyle(size: 14,
                               color: AppColor.color(hex: 0x323232),
                               fontFamily: .feltTipSeniorRegular)
                Spacer()
            }
            Spacer()
        }
        .padding(.leading, 4)
        .padding(.top, 4)
        .opacity(day.isCurrentMonth ? 1 : 0)
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
            didTapIcon(answer)
        }
    }
    
    @ViewBuilder
    func twoIcon(_ answers: [Answer], proxy: GeometryProxy) -> some View {
        let top: CGFloat = 23
        let bottom: CGFloat = 8
        let vspacing: CGFloat = 10
     
        let iconH: CGFloat = 20
        let iconW: CGFloat = 20
        let overlayW: CGFloat = 4
        let iconTotalW = iconW * 2 - overlayW * 2
        let hPadding: CGFloat = (proxy.size.width - iconTotalW) * 0.5
        VStack(spacing: vspacing) {
            if let answer = answers.first {
                HStack {
                    Spacer()
                    iconView(answer, size: .init(width: iconW, height: iconH))
                        .padding(.trailing, hPadding)
                }
                .onTapGesture {
                    didTapIcon(answer)
                }
                
            }
            if let answer = answers.last {
                HStack {
                    iconView(answer, size: .init(width: iconW, height: iconH))
                        .padding(.leading, hPadding)
                    Spacer()
                }
                .onTapGesture {
                    didTapIcon(answer)
                }
            }
        }
        .padding(.top, top)
        .padding(.bottom, bottom)
    }
    
    @ViewBuilder
    func threeIcon(_ answers: [Answer], proxy: GeometryProxy) -> some View {
        let top: CGFloat = 23
        let bottom: CGFloat = 8
        let vspacing: CGFloat = 4
        let hPadding: CGFloat = 2
        let iconH = (proxy.size.height - top - bottom - vspacing * 2) / 3
        let iconW: CGFloat = proxy.size.width * 0.5
        VStack(spacing: vspacing) {
            if let answer = answers.first {
                HStack {
                    Spacer()
                    iconView(answer, size: .init(width: iconW, height: iconH))
                        .padding(.trailing, hPadding)
                }
                .onTapGesture {
                    didTapIcon(answer)
                }
                
            }
            HStack {
                iconView(answers[1], size: .init(width: iconW, height: iconH))
                    .padding(.leading, hPadding)
                Spacer()
            }
            .onTapGesture {
                didTapIcon(answers[1])
            }
            if let answer = answers.last {
                HStack {
                    Spacer()
                    iconView(answer, size: .init(width: iconW, height: iconH))
                        .padding(.trailing, hPadding)
                }
                .onTapGesture {
                    didTapIcon(answer)
                }
            }
        }
        .padding(.top, top)
        .padding(.bottom, bottom)
    }
    
    @ViewBuilder
    func fourIcon(_ answers: [Answer], proxy: GeometryProxy) -> some View {
        let top: CGFloat = 23
        let bottom: CGFloat = 8
        let vspacing: CGFloat = 4
        let hPadding: CGFloat = 2
        let iconH = (proxy.size.height - top - bottom - vspacing * 2) / 3
        let iconW: CGFloat = proxy.size.width * 0.5
        let textRP: CGFloat = hPadding * 4
        VStack(spacing: vspacing) {
            if let answer = answers.first {
                HStack {
                    iconView(answer, size: .init(width: iconW, height: iconH))
                        .padding(.leading, hPadding)
                    Spacer()
                }
                .onTapGesture {
                    didTapIcon(answer)
                }
                
            }
            HStack {
                Spacer()
                iconView(answers[1], size: .init(width: iconW, height: iconH))
                    .padding(.trailing, hPadding)
               
            }
            .onTapGesture {
                didTapIcon(answers[1])
            }
            if let answer = answers.last {
                ZStack(alignment: .trailing) {
                    HStack {
                        iconView(answer, size: .init(width: iconW, height: iconH))
                            .padding(.leading, hPadding)
                        Spacer()
                    }
                    .onTapGesture {
                        didTapIcon(answer)
                    }
                    
                    Text("\(answers.count - 3)+")
                        .textStyle(size: 8, color: AppColor.color(hex: 0x000000), fontFamily: .poppinsMediumItalic)
                        .padding(.trailing, textRP)
                }
            
            }
        }
        .padding(.top, top)
        .padding(.bottom, bottom)
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
    func iconView(_ answer: Answer, size: CGSize = .init(width: 24, height: 24)) -> some View {
        if let url = answer.icon?.url {
            ThumbnailIconImageView(url: url) {
                placeholderIcon
            }
            .frame(width: size.width, height: size.height)
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
    }
}
