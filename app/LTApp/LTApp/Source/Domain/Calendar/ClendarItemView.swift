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
    
    var body: some View {
        VStack {
            if let answers = day.reflections?.reflections, !answers.isEmpty {
                switch answers.count {
                case 1:
                    oneIcon(day.reflections!.reflections.first!)
                case 2:
                    twoIcon(day.reflections!.reflections)
                default:
                    threeIcon(answers)
                }
            } else {
                Rectangle()
                    .fill(Color.clear)
            }
        }
        .padding(.horizontal, 2)
        
    }
    
    var dateView: some View {
        Text(day.date.dayDesc())
            .textStyle(size: 14, color: AppColor.color(hex: 0x323232), fontFamily: .feltTipSeniorRegular)
    }
    
    @ViewBuilder
    func oneIcon(_ answer: Answer) -> some View {
        VStack {
            Spacer()
            iconView(answer)
                .frame(width: 24, height: 24)
                .padding(.bottom, 8)
        }
    }
    
    @ViewBuilder
    func twoIcon(_ answers: [Answer]) -> some View {
        VStack(spacing: .zero) {
            if let answer = answers.first {
                HStack {
                    Spacer()
                    iconView(answer)
                    .frame(width: 24, height: 24)
                  
                }
               
            }
            
            if let answer = answers.last {
                HStack {
                    
                    iconView(answer)
                    .frame(width: 24, height: 24)
                    Spacer()
                }
            }
        }
        .padding(.bottom, 4)
    }
    
    @ViewBuilder
    func threeIcon(_ answers: [Answer]) -> some View {
        VStack(spacing: .zero) {
            if let answer = answers.first {
                HStack {
                    Spacer()
                    iconView(answer)
                    .frame(width: 24, height: 24)
                }
               
            }
            HStack {
                iconView(answers[1])
                .frame(width: 24, height: 24)
                Spacer()
            }
            if let answer = answers.last {
                HStack {
                    Spacer()
                    iconView(answer)
                    .frame(width: 24, height: 24)
                }
            }
        }
    }
    
    @ViewBuilder
    func fourIcon(_ answers: [Answer]) -> some View {
        VStack(spacing: .zero) {
            HStack(spacing: .zero) {
                ThumbnailIconImageView(url: answers[0].icon?.url ?? "") {
                    placeholderIcon
                }
                .frame(width: 24, height: 24)
                Spacer()
                ThumbnailIconImageView(url: answers[1].icon?.url ?? "") {
                    placeholderIcon
                }
            }
            
            HStack(spacing: .zero) {
                ThumbnailIconImageView(url: answers[2].icon?.url ?? "") {
                    placeholderIcon
                }
                .frame(width: 24, height: 24)
                Spacer()
                Rectangle()
                    .fill(Color.clear)
                .frame(width: 24, height: 24)
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
            .padding(.top, 8)
        }
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
    func iconView(_ answer: Answer) -> some View {
        if let url = answer.icon?.url {
            ThumbnailIconImageView(url: url) {
                placeholderIcon
            }
        }
    }
}
