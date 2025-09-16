//
//  LTApp, This code is protected by intellectual property rights.
//

import SwiftUI

struct ThreadView: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: .zero) {
                VStack(spacing: .zero) {
                    questionRow("lil things that make you happy")
                    
                    VStack(spacing: .zero) {
                        answerRow("High school friend brought me a new coffee dripper from California, and I’m so happy to continue my morning coffee routine with that.", icon: .calendarDripper)
                        
                        answerRow("")
                        answerRow("")
                        answerRow("")
                        Spacer()
                    }
                    .frame(height: 120)
                    .padding(.top, 10)
                }
                .overlay(alignment: .leading) {
                    line()
                }
                VStack(spacing: .zero) {
                    questionRow("lil things that make you proud")
                    
                    VStack(spacing: .zero) {
                        answerRow("High school friend brought me a new coffee dripper from California, and I’m so happy to continue my morning coffee routine with that.")
                        answerRow("")
                        answerRow("")
                        answerRow("")
                        Spacer()
                    }
                    .frame(height: 120)
                    .padding(.top, 10)
                }
                .overlay(alignment: .leading) {
                    line()
                }
                
                VStack(spacing: .zero) {
                    questionRow("Did you spend enough time with your SO this week?")
                    
                    VStack(spacing: .zero) {
                        answerRow("High school friend brought me a new coffee dripper from California, and I’m so happy to continue my morning coffee routine with that.")
                        answerRow("")
                        answerRow("")
                        answerRow("")
                        Spacer()
                    }
                    .frame(height: 120)
                    .padding(.top, 10)
                }
                .overlay(alignment: .leading) {
                    line()
                }
                
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 100)
                    .overlay(alignment: .leading) {
                        line(true)
                    }
                
            }
           
        }
        .padding(.leading, 40)
        .padding(.trailing, 20)
    }
    
    func answerRow(_ value: String, icon: ImageResource? = nil) -> some View {
        HStack(spacing: .zero) {
            Rectangle()
                .fill(Color.clear)
                .frame(width: 30, height: 30)
                .overlay {
                    if let icon {
                        Image(icon)
                    } else {
                        Circle()
                            .fill(AppColor.color(hex: 0x848484))
                            .frame(width: 4, height: 4)
                    }
                }
                .padding(.trailing, 24)
               
            Text(value)
                .lineLimit(1)
                .textStyle(size: 12, color: AppColor.color(hex: 0x6f6f6f), fontFamily: .poppinsRegular)
            Spacer()
        }
    }
    
    func questionRow(_ value: String) -> some View {
        HStack {
            Text(value)
                .lineLimit(5)
                .textStyle(size: 20)
            Spacer()
        }
        .padding(.leading, 51)
    }
    
    func line(_ showball: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            WavyLine(segmentCount: 40, seed: 100)
                .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .foregroundColor(AppColor.color(hex: 0x000000))
                .frame(width: 2)
                .padding(.leading, 40)
            if showball {
                Image(.union)
                    .padding(.leading, 30)
                    .offset(y: -14)
            }
            
        }
      
    }
}


#Preview {
    ThreadView()
}

