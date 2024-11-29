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
    private var skins = [
        "planet1",
        "planet2",
        "planet3",
        "planet4",
        "planet5"
   
    ]
    var rng = SystemRandomNumberGenerator()
    
    init(radius: CGFloat = 15, position: CGPoint = .zero, gridPosition: CGPoint = .zero, fadeAni: Bool = true) {
        self.gridX = Int(gridPosition.x)
        self.gridY = Int(gridPosition.y)
        
        
        super.init()
        let rect = CGRect(
                x: -radius/2,  // Center the rect
                y: -radius/2,  // Center the rect
                width: radius,  // Use full radius for width
                height: radius  // Use full radius for height
            )
        self.path = CGPath(ellipseIn: rect, transform: nil)
        // set the position and color
        self.position = position
        self.lineWidth = 0.0
        
        self.fillColor = .white
           
        self.fillTexture = SKTexture(imageNamed: skins[Int.random(in: (0)...(skins.count-1), using: &rng)])
       
        if fadeAni{
            fadeIn()
        }
    }
    
    func getLoc() -> (Int, Int){
        return (gridX,gridY)
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
