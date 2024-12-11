//
//  DODotNode.swift
//  Dot-Dash
//
//  Created by Zhaorong Tu on 11/4/24.
//

import SpriteKit

class DODotNode: SKNode{
    var gridX: Int
    var gridY: Int
    var destroyed = false
    private let sprite: SKSpriteNode
    private var skins = [
        "planet1",
        "planet2",
        "planet3",
        "planet4",
        "planet5",
        "planet6"
   
    ]
    var rng = SystemRandomNumberGenerator()
    
    init(size: CGSize = .zero, position: CGPoint = .zero, gridPosition: CGPoint = .zero, fadeAni:Bool = true) {
        self.gridX = Int(gridPosition.x)
        self.gridY = Int(gridPosition.y)
        sprite = SKSpriteNode(imageNamed:  skins[Int.random(in: (0)...(skins.count-1), using: &rng)])
        self.sprite.size = size
        super.init()
        self.position = position
       
        addChild(sprite)
        if fadeAni{
            fadeIn()
        }
        
    }
    
    func getLoc() -> (Int, Int){
        return (gridX,gridY)
    }
    
    func destroySelf(){
        destroyed = true
        self.sprite.texture = SKTexture(imageNamed: "brokenplanet")
        self.sprite.size = CGSize(width: self.sprite.size.width*0.66, height: self.sprite.size.width*0.66)
        //self.zRotation =  CGFloat(Float.random(in: (-.pi)...(.pi), using: &rng))// rotate doesnt work
                                          
       
    }
    
    func fadeIn(){
        self.setScale(0)
    
    // Scale up to normal size
    let scaleAction = SKAction.scale(to: 1.0, duration: 0.5)
    
    // Optional: Add easing for smoother animation
    scaleAction.timingMode = .easeOut
    
    self.run(scaleAction)
        
    }
    func fadeOut(){
        self.setScale(1.0)
    
    // Scale down to 0
    let scaleAction = SKAction.scale(to: 0.0, duration: 0.5)
    
    // Optional: Add easing for smoother animation
    scaleAction.timingMode = .easeOut
    
    self.run(scaleAction)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
