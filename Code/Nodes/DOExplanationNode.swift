//
//  DOExplanationNode.swift
//  Dot-Dash
//
//  Created by Justin Chen on 12/6/24.
//

import SpriteKit
class MultiLineTextNode: SKNode {
    init(text: String, fontSize: CGFloat = 30, fontColor: UIColor = .white, lineSpacing: CGFloat = 5) {
        super.init()

        // Split the text into lines by `\n`
        let lines = text.components(separatedBy: "\n")
        var yOffset: CGFloat = 0

        // Create a label for each line
        for line in lines {
            let label = SKLabelNode(text: line)
            label.fontSize = fontSize
            label.fontColor = fontColor
            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = .baseline
            label.position = CGPoint(x: 0, y: yOffset)

            addChild(label)
            yOffset -= fontSize + lineSpacing // Adjust y-position for the next line
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DOExplanationNode: SKNode {
    private let point: CGPoint
    
    private var overlay: SKSpriteNode
  
    
    let message:[[String]] = [[
        "Swipe to control the Rook.",
        "Take all Black pieces.",
        "Advance as far as you can!",
        "Tap anywhere to continue."
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
        var yPosition = point.y + CGFloat((30 * message[code].count) / 2) - 100
        
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
        
    }
}
