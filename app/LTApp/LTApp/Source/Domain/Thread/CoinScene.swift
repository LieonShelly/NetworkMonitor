//
//  CoinScene.swift
//  LTApp
//
//  Created by Renjun Li on 2026/3/17.
//

import SpriteKit

class CoinScene: SKScene {
    override func didMove(to view: SKView) {
        // 预热渲染引擎
        let warmUpNode = SKCropNode()
        warmUpNode.maskNode = SKShapeNode(circleOfRadius: 1)
        warmUpNode.position = CGPoint(x: -100, y: -100) // 放在屏幕外
        addChild(warmUpNode)
        
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0.5
        borderBody.restitution = 0.2
        self.physicsBody = borderBody
        self.backgroundColor = .clear
        view.preferredFramesPerSecond = 60
        view.ignoresSiblingOrder = false
    }

    func dropCoinsBatch(localPaths: [String], count: Int) {
        // 1. 先把所有路径转换成纹理对象
        let textures = localPaths.compactMap { path -> SKTexture? in
            guard let image = UIImage(contentsOfFile: path) else { return nil }
            return SKTexture(image: image)
        }
        
        // 2. 核心：预加载纹理到 GPU
        SKTexture.preload(textures) { [weak self] in
            // 只有当所有纹理都准备好后，才开始掉落逻辑
            DispatchQueue.main.async {
                for (index, texture) in textures.enumerated() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.15) {
                        self?.createSingleCoin(texture: texture)
                    }
                }
            }
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
        
        cropNode.physicsBody = SKPhysicsBody(circleOfRadius: physicsRadius)
        cropNode.physicsBody?.restitution = 0.5
        cropNode.physicsBody?.friction = 0.3
        cropNode.physicsBody?.allowsRotation = true
        cropNode.physicsBody?.angularDamping = 0.5
        
        let randomX = CGFloat.random(in: radius...(frame.width - radius))
        cropNode.position = CGPoint(x: randomX, y: frame.height)
        
        addChild(cropNode)
    }
}
