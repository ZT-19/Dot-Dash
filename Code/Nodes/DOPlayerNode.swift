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
    }
    func getLoc() -> (Int, Int){
        return (gridX,gridY)
    }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
