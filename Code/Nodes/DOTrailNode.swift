//
//  DOTrailNode.swift
//  Dot-Dash
//
//  Created by Justin Chen on 11/29/24.
//


import SpriteKit

class DOTrailNode: SKNode {
    private let trailSprite: SKSpriteNode
    
    init(position: CGPoint,vertical: Bool) {
        if vertical{
            trailSprite = SKSpriteNode(imageNamed: "trailVert")
        }
        else{
            trailSprite = SKSpriteNode(imageNamed: "trailHoriz")
        }
        if !vertical{
            trailSprite.size = CGSize(width: 30, height: 10)
        }
        else{
            trailSprite.size = CGSize(width: 10, height: 30)
        }
       
        trailSprite.position = CGPoint(x: position.x, y: position.y)
        //trailSprite.alpha = 0.5
        super.init()
        addChild(trailSprite)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
