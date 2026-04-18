//
//  CoinScene.swift
//  LTApp
//
//  Created by Renjun Li on 2026/3/17.
//
import UIComponent
@preconcurrency import SpriteKit

class CoinScene: SKScene , @unchecked Sendable {
    override func didMove(to view: SKView) {
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

    func dropCoinsBatch(localPaths: [String], count: Int, onCompleted: (@Sendable () -> Void)? = nil) {
        let textures = localPaths.compactMap { path -> SKTexture? in
            guard let image = UIImage(contentsOfFile: path) else { return nil }
            return SKTexture(image: image)
        }
        
        nonisolated(unsafe) let preloadedTextures = textures
        SKTexture.preload(preloadedTextures) { [weak self] in
            DispatchQueue.main.async {
                let total = preloadedTextures.count
                if total == 0 {
                    onCompleted?()
                    return
                }
                for (index, texture) in preloadedTextures.enumerated() {
                    let isLast = (index == total - 1)
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.15) {
                        self?.createSingleCoin(texture: texture)
                        if isLast {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                onCompleted?()
                            }
                        }
                    }
                }
            }
        }
    }

    private func createSingleCoin(texture: SKTexture) {
        let containerDimension: CGFloat = 51
        let iconDimension: CGFloat = 30

        let radius = containerDimension * 0.5
        
        let textureSize = texture.size()
        let iconWidthRatio = iconDimension / textureSize.width
        let iconHeightRatio = iconDimension / textureSize.height
        
        let iconScale = min(iconWidthRatio, iconHeightRatio)
        let finalIconSize = CGSize(width: textureSize.width * iconScale, height: textureSize.height * iconScale)
        
    
        
        let cropNode = SKCropNode()
        
        let mask = SKShapeNode(circleOfRadius: radius)
        mask.fillColor = .white
        mask.strokeColor = .clear
        cropNode.maskNode = mask
        
        let bgNode = SKShapeNode(circleOfRadius: radius)
        bgNode.fillColor = UIColor(AppColor.backgroundPage)
        bgNode.strokeColor = .clear
        bgNode.zPosition = -1
        
        cropNode.addChild(bgNode)
        
        let coinImageNode = SKSpriteNode(texture: texture, size: finalIconSize)
        coinImageNode.position = .zero
        cropNode.addChild(coinImageNode)
        
        let borderNode = SKShapeNode(circleOfRadius: radius)
        borderNode.strokeColor = .black
        borderNode.lineWidth = 3
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
