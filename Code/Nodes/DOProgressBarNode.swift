//
//  DOProgressBarNode.swift
//  Dot-Dash
//
//  Created by Justin Chen on 12/5/24.
//

import SpriteKit

class DOProgressBarNode: SKNode {
    private let background: SKSpriteNode
    private let fullTexture: SKSpriteNode
        private let cropNode: SKCropNode
        private let maskTexture: SKSpriteNode
        
        private var progress: CGFloat = 0.0 // Progress from 0.0 to 1.0
        
        init(size: CGSize) {
          
            background = SKSpriteNode(texture: SKTexture(imageNamed: "barback"), size: size)
            background.zPosition = 2
            
            // Full texture to reveal
            fullTexture = SKSpriteNode(texture: SKTexture(imageNamed: "fullprogress"))
            fullTexture.size = size
            fullTexture.zPosition = self.background.zPosition+1
            
            // Mask texture
            maskTexture = SKSpriteNode(texture: SKTexture(imageNamed: "barback"))
            maskTexture.size = size
            maskTexture.anchorPoint = CGPoint(x: 0.0, y: 0.5) // Anchor on the left for horizontal progress
            maskTexture.position.x -= size.width/2
            
            // CropNode with mask
            cropNode = SKCropNode()
            cropNode.maskNode = maskTexture
            cropNode.addChild(fullTexture)
            cropNode.zPosition = self.background.zPosition+1
            
            super.init()
            addChild(background)
            addChild(cropNode)
            setProgress(0.0) // Start fully hidden
          
        }
    func setup(screenSize: CGSize) {
        if screenSize.width < 376.0{
            position = CGPoint(x: screenSize.width / 2, y: background.size.height)
        }
        else{
            position = CGPoint(x: screenSize.width / 2, y: min(background.size.height * 2,screenSize.height / 10))
        }
        setProgress(0.0) // Start fully hidden
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setProgress(_ progress: CGFloat) {
        self.progress = max(0.0, min(progress, 1.0)) // Clamp between 0 and 1
        let newWidth = fullTexture.size.width * self.progress
        maskTexture.size = CGSize(width: newWidth, height: maskTexture.size.height)
    }
    
    
    func increaseProgress(_ extraprogress: CGFloat) {
        
        // does not MOD, so 1.0 + x will still be 1.0
     
       // self.progress = max(0.0, min(self.progress+extraprogress, 1.0)) // Clamp between 0 and 1
        //let newWidth = fullTexture.size.width * self.progress
        
     //  maskTexture.size = CGSize(width: newWidth, height: maskTexture.size.height)
        animateProgress(to: max(0.0, min(self.progress+extraprogress, 1.0)) , duration: 0.25)
    }
    func getProgress()->CGFloat{
        
        return progress
    }
    func setPosition(_ position: CGPoint) {
        self.position = position
        
    }
    func animateProgress(to targetProgress: CGFloat, duration: TimeInterval) {
            let startProgress = self.progress
            let delta = targetProgress - startProgress
            
            let action = SKAction.customAction(withDuration: duration) { [weak self] _, elapsedTime in
                let fraction = elapsedTime / CGFloat(duration)
                let newProgress = startProgress + delta * fraction
                self?.setProgress(newProgress)
            }
            
            self.run(action)
        }
}
