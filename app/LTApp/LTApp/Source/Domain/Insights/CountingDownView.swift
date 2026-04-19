//
//  CountingDownView.swift
//  LTApp
//
//  Created by 李仁军 on 2026/4/19.
//

import SwiftUI
import UIComponent


struct CountingDownView: View {
    @State private var timeRemaining: TimeInterval = 0
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 8) {
            
            Text(formattedTime)
                .textStyle(size: 64, color: AppColor.greyDark, fontFamily: .dsDigital)
                .monospacedDigit()
            
            Text("Your time receipt will be ready to collect Sunday ")
                .textStyle(font: .annotation, color: AppColor.greyDark)
                .multilineTextAlignment(.center)
                .frame(width: 209)
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            updateTimeRemaining()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                updateTimeRemaining()
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private var formattedTime: String {
        guard timeRemaining > 0 else { return "00:00:00" }
        
        let totalSeconds = Int(timeRemaining)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func updateTimeRemaining() {
        let calendar = AppCalendar.current
        let now = Date()
        let weekday = calendar.component(.weekday, from: now)
        let daysUntilSunday = (8 - weekday) % 7 // 如果今天是周日则为 0
        
        guard let nextSunday = calendar.date(byAdding: .day, value: daysUntilSunday == 0 ? 7 : daysUntilSunday, to: now) else {
            timeRemaining = 0
            return
        }
        
        // 周日 0:00:00
        let sundayMidnight = calendar.startOfDay(for: nextSunday)
        
        timeRemaining = max(0, sundayMidnight.timeIntervalSince(now))
    }
}
