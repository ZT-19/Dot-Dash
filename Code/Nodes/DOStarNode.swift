//
//  DOStarNode.swift
//  Dot-Dash
//
//  Created by Zhaorong Tu on 11/29/24.
//

import SpriteKit

class DOStarNode: SKNode {
    private let starSprite: SKSpriteNode
    
    init(position: CGPoint, screenHeight: CGFloat, width:CGFloat = 5, height:CGFloat = 5, color: UIColor =  UIColor(red: 0.8274, green: 0.69804, blue: 0.6157, alpha: 1), duration:Double = 0.7) {
        //starSprite = SKSpriteNode(imageNamed: "backgroundstar3x")
        starSprite = SKSpriteNode(color:color, size: CGSize(width: width, height: height))
        //starSprite.size = CGSize(width: width, height: height)
        starSprite.position = CGPoint(x: position.x, y: position.y + screenHeight)
        
        super.init()
        
        addChild(starSprite)
        
        let slideDown = SKAction.moveBy(x: 0, y: -screenHeight, duration: duration) // Match duration
        starSprite.run(slideDown)
    }
    
  
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
