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
                    } else {
                        Rectangle()
                            .fill(Color.clear)
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
                
            }
            if let answer = answers.last {
                HStack {
                    iconView(answer, size: .init(width: iconW, height: iconH))
                        .padding(.leading, hPadding)
                    Spacer()
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
                
            }
            HStack {
                iconView(answers[1], size: .init(width: iconW, height: iconH))
                    .padding(.leading, hPadding)
                Spacer()
            }
            if let answer = answers.last {
                HStack {
                    Spacer()
                    iconView(answer, size: .init(width: iconW, height: iconH))
                        .padding(.trailing, hPadding)
                }
            }
        }
        .padding(.top, top)
        .padding(.bottom, bottom)
    }
    
    @ViewBuilder
    func fourIcon(_ answers: [Answer], proxy: GeometryProxy) -> some View {
        let horizontal: CGFloat = 4
        let vertical: CGFloat = .zero
        let iconW = (proxy.size.width - horizontal * 3) / 2
        let iconH = (proxy.size.height - vertical - Constants.iconViewTop - Constants.iconViewBotton) / 2
        VStack(spacing: vertical) {
            HStack(spacing: horizontal) {
                iconView(answers[0], size: .init(width: iconW , height: iconH))
                iconView(answers[1], size: .init(width: iconW , height: iconH))
            }
            
            HStack(spacing: 2) {
                iconView(answers[2], size: .init(width: iconW, height: iconH))
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: iconW, height: iconH)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppColor.color(hex: 0x323232))
                            .frame(width: 16, height: 16)
                            .overlay {
                                Text("\(answers.count - 3)+")
                                    .textStyle(size: 8, color: AppColor.color(hex: 0xffffff), fontFamily: .poppinsRegular)
                            }
                    }
            }
        }
        .padding(.horizontal, horizontal)
        .padding(.top, Constants.iconViewTop)
        .padding(.bottom, Constants.iconViewBotton)
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
}
