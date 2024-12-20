//
//  DOTrailNode.swift
//  Dot-Dash
//
//  Created by Justin Chen on 11/29/24.
//


import SpriteKit

class DOTrailNode: SKNode {
    private let trailSprite: SKSpriteNode
    
    
    init(position: CGPoint, vertical: Bool, startPoint: CGPoint, size:CGSize = CGSize(width: 10, height: 30)) {
        var long = size.height, wid = size.width
        
        
            if vertical {
                trailSprite = SKSpriteNode(imageNamed: "trail")
                trailSprite.size = CGSize(width: wid, height: long)
                trailSprite.anchorPoint = position.y > startPoint.y ? CGPoint(x: 0.5, y: 0) : CGPoint(x: 0.5, y: 1)
                trailSprite.yScale = 0
                trailSprite.xScale = 1
            } else {
                trailSprite = SKSpriteNode(imageNamed: "trail")
                trailSprite.size = CGSize(width: long, height: wid)
                trailSprite.anchorPoint = position.x > startPoint.x ? CGPoint(x: 0, y: 0.5) : CGPoint(x: 1, y: 0.5)
                trailSprite.xScale = 0
                trailSprite.yScale = 1
            }
            
            trailSprite.position = startPoint
       
        
            super.init()
        self.zPosition = -3 // behind planet residues but in front of stars
            addChild(trailSprite)
            
            animateTrail(to: position, duration: 0.2, vertical: vertical)
        
        }
        
        private func animateTrail(to endPoint: CGPoint, duration: TimeInterval, vertical: Bool) {
            let scaleAction = SKAction.scaleX(to: vertical ? 1 : 1, y: vertical ? 1 : 1, duration: duration)
            scaleAction.timingMode = .easeOut
            trailSprite.run(scaleAction)
        }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
