//
//  DOStarNode.swift
//  Dot-Dash
//
//  Created by Zhaorong Tu on 11/29/24.
//

import SpriteKit

class DOFrameNode: SKNode {
    private let frameSprite: SKSpriteNode
    
    override init() {
        //starSprite = SKSpriteNode(imageNamed: "backgroundstar3x")
        frameSprite = SKSpriteNode(texture: SKTexture(imageNamed: "frame"))
        super.init()
        addChild(frameSprite)
      
    }
    func setup(screenSize: CGSize) {
        self.frameSprite.anchorPoint = CGPoint(x: 0, y: 0)
        frameSprite.size = screenSize
        position = CGPoint(x:0,y:0)
        //position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
