//
//  DODotNode.swift
//  Dot-Dash
//
//  Created by Zhaorong Tu on 11/4/24.
//

import SpriteKit

class DODotNode: SKShapeNode {
    var gridX: Int
    var gridY: Int
    init(radius: CGFloat = 30, position: CGPoint = .zero, gridPosition: CGPoint = .zero) {
        self.gridX = Int(gridPosition.x)
        self.gridY = Int(gridPosition.y)
        
        super.init()
        self.path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius * 0.5, height: radius * 0.5), transform: nil) 
      
        // set the position and color
        self.position = position
        //self.fillTexture = SKTexture(imageNamed: "closed")
        self.fillColor = .white
        
        // physics for collision detection
        // try to remove dependnece on physics
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        self.physicsBody?.isDynamic = false // disable gravity
        self.physicsBody?.categoryBitMask = 0x1 << 1 // category (key) for the dot
        
        // TODO: can be updated (or not use bitmasks altogether) to detect collision with other categories
        self.physicsBody?.contactTestBitMask = 0x1 << 2 // detect collision with another category
        self.physicsBody?.collisionBitMask = 0x1 << 2 // collide with the other category
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

