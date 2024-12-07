//
//  DOPlayerNode.swift, essentially a larger player
//  Dot-Dash
//
//  Created by Zhaorong Tu on 11/4/24.
//

import SpriteKit

class DOPlayerNode: SKShapeNode {
    var gridX: Int
    var gridY: Int
    init(radius: CGFloat = 27, position: CGPoint = .zero, gridPosition: CGPoint = .zero, fadeAni: Bool = true) {
        self.gridX = Int(gridPosition.x)
        self.gridY = Int(gridPosition.y)
        
        super.init()
        
        // Fix: Make rect dimensions match the radius
        let rect = CGRect(
                x: -radius/2,  // Center the rect
                y: -radius/2,  // Center the rect
                width: radius,  // Use full radius for width
                height: radius  // Use full radius for height
            )
        self.path = CGPath(ellipseIn: rect, transform: nil)
        
        self.position = position
        self.lineWidth = 0.0
        self.fillColor = .white
        self.fillTexture = SKTexture(imageNamed: "player")
        self.zPosition = 20
    }
    func getLoc() -> (Int, Int){
        return (gridX,gridY)
    }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
