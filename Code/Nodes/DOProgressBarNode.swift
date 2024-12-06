//
//  DOProgressBarNode.swift
//  Dot-Dash
//
//  Created by Justin Chen on 12/5/24.
//

import SpriteKit

class DOProgressBarNode: SKNode {
    private let background: SKSpriteNode
    private let fill: SKSpriteNode
    private let cropNode: SKCropNode
    
    private var progress: CGFloat = 0.0 // Ranges from 0.0 to 1.0
    
    init(size: CGSize, backgroundColor: UIColor, fillColor: UIColor) {
        // Background
        background = SKSpriteNode(texture: SKTexture(imageNamed: "barback"), size: size)
        background.color.setFill()
        background.zPosition = 0
        
        // Fill
        fill = SKSpriteNode(color: fillColor, size: CGSize(width: 0, height: size.height)) // Initial size: zero width
        fill.zPosition = 1
        
        
        // CropNode
        cropNode = SKCropNode()
        cropNode.maskNode = SKSpriteNode(color: .white, size: CGSize(width: size.width-17.5, height: size.height-17.5)) // Mask restricts fill to bar size
        cropNode.addChild(fill)
        cropNode.zPosition = 1
        
        super.init()
        
        addChild(background)
        addChild(cropNode)
    }
    func setup(screenSize: CGSize) {
        position = CGPoint(x: screenSize.width / 2, y: 100)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setProgress(_ progress: CGFloat) {
        self.progress = max(0.0, min(progress, 1.0)) // Clamp between 0 and 1
        let newWidth = background.size.width * self.progress
        fill.size.width = newWidth
        fill.position.x = -background.size.width / 2 + newWidth / 2 // Align left
    }
    
    
    func increaseProgress(_ extraprogress: CGFloat) {
        
        // does not MOD, so 1.0 + x will still be 1.0
        self.progress = max(0.0, min(self.progress+extraprogress, 1.0)) // Clamp between 0 and 1
        let newWidth = background.size.width * self.progress
        fill.size.width = newWidth
        fill.position.x = -background.size.width / 2 + newWidth / 2 // Align left
    }
    func getProgress()->CGFloat{
        
        return progress
    }
    func setPosition(_ position: CGPoint) {
        self.position = position
        
    }
}
