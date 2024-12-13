//
//  DOExplanationNode.swift
//  Dot-Dash
//
//  Created by Justin Chen on 12/6/24.
//

import SpriteKit
class DOExplanationNode: SKNode {
    private let point: CGPoint
    
    private var overlay: SKSpriteNode
    private var picture: SKSpriteNode
    
    let message:[[String]] = [[
        "Swipe to control the Rook.",
        "Take all Black pieces.",
        "Advance as far as you can!"
    ]
    ,[
        "New Powerup: Freeze Time."
        , "Freeze time for 15 seconds."
        
    ]
    ,[
        "New Powerup: Skip Level."
        ,"Instantly clears current level."
    ],
    ["Swiping off screen", "results in a level restart."]]
    init(size: CGSize){
        overlay = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.7), size: size)
                overlay.zPosition = 30
        point = CGPoint(x: size.width / 2, y: size.height / 2)
        picture = SKSpriteNode()
        super.init()
        
        overlay.position = point
        addChild(overlay)

    }

    
    func resetText(){
        removeAllChildren()
        addChild(overlay)
       
        
    }
    
    required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    func updateText(code: Int) {
        var yPosition = point.y * 0.75 + CGFloat((30 * message[code].count) / 2)
        
        for line in message[code] {
               // Create an SKLabelNode for each line
               let label = SKLabelNode(text: line)
                
               label.fontSize = 30
            label.fontName="Helvetica"
         
               label.fontColor = .white
               label.horizontalAlignmentMode = .center
            label.position = CGPoint(x: point.x, y: yPosition)
            label.zPosition = 31
               addChild(label)
            
               
               // Adjust Y position for the next line
               yPosition -= 30  // 30 is the line spacing
           }
        if code == 2{
            picture = SKSpriteNode(imageNamed: "powerupSkip")
            picture.position = CGPoint(x:point.x,y:point.y * 1.15)
            picture.zPosition = 31
            addChild(picture)
        }
        else if code == 1 {
            picture = SKSpriteNode(imageNamed: "powerupFreeze")
            picture.position = CGPoint(x:point.x,y:point.y * 1.15)
            picture.zPosition = 31
            addChild(picture)
            
        }
        else{
            picture.removeFromParent()
        }
        let click2continue = SKLabelNode(text: "Tap anywhere to continue.")
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.8)
        let fadeOut =  SKAction.fadeAlpha(to: 0.0, duration: 0.8)
        click2continue.fontSize = 20
       
        click2continue.fontName="Helvetica"
  
        click2continue.fontColor = .white
        click2continue.position = CGPoint(x: point.x, y: yPosition)
        let flashingSequence = SKAction.sequence([fadeOut, fadeIn])
        click2continue.zPosition = 31
        addChild(click2continue)
        click2continue.run(SKAction.repeatForever(flashingSequence))
        
    }
    func fadeIn(){
        self.setScale(0)
    
    // Scale up to normal size
    let scaleAction = SKAction.scale(to: 1.0, duration: 0.5)
    
    // Optional: Add easing for smoother animation
    scaleAction.timingMode = .easeOut
    
    self.run(scaleAction)
        
    }
}
