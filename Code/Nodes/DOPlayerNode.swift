//
//  DOPlayerNode.swift, essentially a larger player
//  Dot-Dash
//
//  Created by Zhaorong Tu on 11/4/24.
//

import SpriteKit

class DOPlayerNode: DODotNode {
    override init(radius: CGFloat = 30, position: CGPoint = .zero, gridPosition: CGPoint = .zero) {
      
        
        super.init(position: position , gridPosition: gridPosition)
        
        // create a circle
        self.path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius * 0.5, height: radius * 0.5), transform: nil)
        
        self.fillColor = .red

        self.fillTexture = SKTexture(imageNamed: "open")
        
        // physics for collision detection
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        self.physicsBody?.isDynamic = false // disable gravity
        self.physicsBody?.categoryBitMask = 0x1 << 2 // category (key) for the player
        
        // TODO: can be updated (or not use bitmasks altogether) to detect collision with other categories
        self.physicsBody?.contactTestBitMask = 0x1 << 2 // detect collision with another category
        self.physicsBody?.collisionBitMask = 0x1 << 2 // collide with the other category
    }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

