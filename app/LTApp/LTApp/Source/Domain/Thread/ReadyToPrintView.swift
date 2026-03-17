//
//  ReadyToPrintView.swift
//  LTApp
//
//  Created by Renjun Li on 2026/3/17.
//

import SwiftUI
import UIComponent

struct ReadyToPrintView: View {
    var body: some View {
        VStack(spacing: .zero) {
            iconListView
            rpView
            startView
        }
        .defaultBackground()
    }
    
    @ViewBuilder
    var iconListView: some View {
        HStack(spacing: .zero) {
            HStack(spacing: .zero) {
                Text("YOUR COINS")
                    .textStyle(size: 12, fontFamily: .poppinsRegular)
                
                Image(.rightPloly)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .padding(.leading, 4)
                
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 12)
            .overlay {
                Rectangle()
                    .stroke(AppColor.color(hex: 0x000000), lineWidth: 1)
            }
            .padding(.vertical, 16)
            .padding(.leading, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(0 ..< 10) { _ in
                        Circle()
                            .fill(Color.random)
                            .frame(width: 25, height: 25)
                            .background {
                                Circle()
                                    .fill(Color.black)
                                    .offset(x: 2, y: 2)
                            }
                    }
                }
                .padding(.vertical, 10)
            }
            .padding(.leading, 15)
            .padding(.trailing, 11)
            
        }
        .overlay(content: {
            Rectangle()
                .stroke(AppColor.color(hex: 0x000000), lineWidth: 1)
        })
        .padding(.horizontal, 16)
        
        Trapezoid(padding: 20, direction: .bottom)
            .stroke(AppColor.color(hex: 0x000000), lineWidth: 1)
            .frame(height: 30)
            .padding(.horizontal, 16)
        
        VStack(spacing: .zero) {
            
        }
        
        
    }
    
    
    var rpView: some View {
        VStack(spacing: .zero) {
            Image(.invader)
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .padding(.bottom, 8)
            
            Image(.rtp)
                .resizable()
                .scaledToFit()
                .aspectRatio(contentMode: .fit)
                .frame(height: 40)
                .padding(.horizontal, 14)
        }
        .frame(height: 320)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColor.color(hex: 0x000000), lineWidth: 1)
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 28)
        .overlay {
            Rectangle()
                .stroke(AppColor.color(hex: 0x000000), lineWidth: 1)
        }
        .padding(.horizontal, 16 + 20)
    }
    
    var startView: some View {
        HStack(spacing: .zero) {
            HStack(alignment: .bottom, spacing: .zero) {
                JoyStickView()
                    .frame(width: 48, height: 123)
                    
                
                Image(.rpBtn)
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 30)
                    .offset(y: -30)
                
            
                Image(.rpBtn)
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 30)
            }
            .padding(.leading, 45)
            .offset(y: -35)
            Spacer()
            Button {
                
            } label: {
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColor.color(hex: 0x000000))
                    .frame(width: 155, height: 52)
                    .overlay {
                        Image(.startReport)
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 95, height: 32)
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColor.color(hex: 0x000000), lineWidth: 1)
                            .offset(x: 3, y: 6)
                    }
            }
            .padding(.top, 15)
            .padding(.bottom, 20)
            .padding(.trailing, 36)

        }
        .background {
            Trapezoid(padding: 16 + 20, direction: .top)
                .stroke(AppColor.color(hex: 0x000000), lineWidth: 1)
        }
    }
}

struct JoyStickView: View {
    var body: some View {
        VStack(spacing: .zero) {
           Circle()
                .fill(AppColor.backgroundPage)
                .stroke(AppColor.color(hex: 0x000000), lineWidth: 1)
                .frame(width: 48, height: 48)
                .zIndex(11)
            
            
            Image(.roundRect)
                .resizable()
                .scaledToFit()
                .aspectRatio(contentMode: .fit)
                .frame(width: 8, height: 64)
                .zIndex(10)
            
            Image(.rpBtn)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 30)
                .offset(y: -5)
            
        }
    }
}
import SpriteKit

class CoinScene: SKScene {
    override func didMove(to view: SKView) {
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0.5
        borderBody.restitution = 0.2
        self.physicsBody = borderBody
        self.backgroundColor = .clear
    }

    func dropCoinsBatch(localPaths: [String], count: Int) {
        for(index, path) in localPaths.enumerated() {
            guard let image = UIImage(contentsOfFile: path) else {
                continue
            }
            let texture = SKTexture(image: image)
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.4, execute: {
                self.createSingleCoin(texture: texture)
            })
        }
    }

    private func createSingleCoin(texture: SKTexture) {
        let coinSize = CGSize(width: 64, height: 64)
        
        let radius = coinSize.width * 0.5
        
        let cropNode = SKCropNode()
        
        let mask = SKShapeNode(circleOfRadius: radius)
        mask.fillColor = .white
        mask.strokeColor = .clear
        cropNode.maskNode = mask
        
        let coinImageNode = SKSpriteNode(texture: texture, size: coinSize)
        coinImageNode.position = .zero
        cropNode.addChild(coinImageNode)
        
        let borderNode = SKShapeNode(circleOfRadius: radius)
        borderNode.strokeColor = .black
        borderNode.lineWidth = 4
        borderNode.fillColor = .clear
        borderNode.zPosition = 1
        cropNode.addChild(borderNode)
        
        let physicsRadius = radius - 1
        
        cropNode.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        cropNode.physicsBody?.restitution = 0.5 // 弹性
        cropNode.physicsBody?.friction = 0.3    // 摩擦力
        cropNode.physicsBody?.allowsRotation = true
        cropNode.physicsBody?.angularDamping = 0.5
        
        let randomX = CGFloat.random(in: radius...(frame.width - radius))
        cropNode.position = CGPoint(x: randomX, y: frame.height)
        
        addChild(cropNode)
    }
}

import SwiftUI
import SpriteKit

struct CoinDropView: View {
    // 初始化场景
    @State private var scene: CoinScene = {
        let scene = CoinScene(size: CGSize(width: 350, height: 500))
        scene.scaleMode = .fill
        return scene
    }()
    
    // 准备你的图标库
    let coinIcons = ["🛋", "💬", "✅", "🍷", "💡", "🚀", "❤️", "🔔"]

    var body: some View {
        VStack(spacing: 20) {
            Text("硬币容器")
                .font(.headline)
            
            // 物理引擎容器
            SpriteView(scene: scene, options: [.allowsTransparency])
                .frame(width: 350, height: 500)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.black, lineWidth: 3)
                        .background(Color.gray.opacity(0.05)) // 淡淡的背景色
                )
                .clipShape(RoundedRectangle(cornerRadius: 24))
            
            HStack(spacing: 20) {
                Button(action: {
                    // 一次投入 5 个硬币
                    let path = Bundle.main.path(forResource: "test_rocket.png", ofType: nil)!
                    scene.dropCoinsBatch(localPaths: [path, path, path,  path, path], count: 5)
                }) {
                    Label("投入5枚", systemImage: "plus.circle.fill")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    // 清空容器（重新创建场景或移除子节点）
                    scene.removeAllChildren()
                }) {
                    Text("清空")
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
    }
}

#Preview {
    CoinDropView()
}
