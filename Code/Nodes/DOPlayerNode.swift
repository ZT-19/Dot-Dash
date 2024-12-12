//
//  DOPlayerNode.swift, essentially a larger player
//  Dot-Dash
//
//  Created by Zhaorong Tu on 11/4/24.
//

import SpriteKit

class DOPlayerNode: SKNode {
    var gridX: Int
    var gridY: Int
    private let sprite: SKSpriteNode
    private var skins = [
        "rook1",
        "rook2"
   
    ]
    var rng = SystemRandomNumberGenerator()
    init(size: CGSize = .zero, position: CGPoint = .zero, gridPosition: CGPoint = .zero) {
        self.gridX = Int(gridPosition.x)
        self.gridY = Int(gridPosition.y)
        sprite = SKSpriteNode(imageNamed:  skins[Int.random(in: (0)...(skins.count-1), using: &rng)])
        self.sprite.size = size
        super.init()
        self.position = position
        
        
        self.zPosition = 3
        addChild(sprite)
        fadeIn()
    }
    func getLoc() -> (Int, Int){
        return (gridX,gridY)
    }
    func fadeOut(){
        self.setScale(1.0)
    
    // Scale down to 0
    let scaleAction = SKAction.scale(to: 0.0, duration: 0.5)
    
    // Optional: Add easing for smoother animation
    scaleAction.timingMode = .easeOut
    
    self.run(scaleAction)
        
    }
    func fadeIn(){
        self.setScale(0)
    
    // Scale up to normal size
    let scaleAction = SKAction.scale(to: 1.0, duration: 0.5)
    
    // Optional: Add easing for smoother animation
    scaleAction.timingMode = .easeOut
    
    self.run(scaleAction)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
