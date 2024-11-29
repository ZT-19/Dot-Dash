//
//  DOStarNode.swift
//  Dot-Dash
//
//  Created by Zhaorong Tu on 11/29/24.
//

import SpriteKit

class DOStarNode: SKNode {
    private let starSprite: SKSpriteNode
    
    init(position: CGPoint, screenHeight: CGFloat) {
        starSprite = SKSpriteNode(imageNamed: "backgroundstar3x")
        starSprite.size = CGSize(width: 5, height: 5)
        starSprite.position = CGPoint(x: position.x, y: position.y + screenHeight)
        
        super.init()
        addChild(starSprite)
        
        let slideDown = SKAction.moveBy(x: 0, y: -screenHeight, duration: 1.0) // Match duration
        starSprite.run(slideDown)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
