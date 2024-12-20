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
    private var size: CGSize
    let scaleUp = SKAction.scale(to: 1.0, duration: 0.4)
    let scaleDown = SKAction.scale(to: 0.0, duration: 0.4)
    let fadeInAni = SKAction.fadeAlpha(to: 1.0, duration: 0.6)
    private var rng = SystemRandomNumberGenerator()
    
    let message:[[String]] = [[
        "Test","test"
    ]
    ,[
        "Time Freeze"
        , "Freeze time for 15 seconds."
        
    ]
    ,[
        "Level Skip"
        ,"Instantly clears current level."
    ]]
    init(size: CGSize){
        self.size = size
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
        resetText()
        var yPosition = point.y * 0.75 + CGFloat((30 * message[code].count) / 2)
        let toplabel = SKLabelNode(text: "New Powerup!")
         
        toplabel.fontSize = 30
     toplabel.fontName="Arial"
  
        toplabel.fontColor =  UIColor(red: 247/255.0, green: 229/255.0, blue: 205/255.0, alpha: 1.0)
        toplabel.horizontalAlignmentMode = .center
        toplabel.position = CGPoint(x: point.x, y: point.y * 1.3)
     toplabel.zPosition = 31
        addChild(toplabel)
     toplabel.alpha = 0
     toplabel.run(fadeInAni)
        
       
        
        var index = 0
        for line in message[code] {
               // Create an SKLabelNode for each line
               let label = SKLabelNode(text: line)
                
               label.fontSize = 30
            label.fontName="Arial Rounded MT Bold"
            if index >= 1 {
                label.fontName = "Arial-ItalicMT"
                label.fontSize = 25
            }
         
               label.fontColor = .white
               label.horizontalAlignmentMode = .center
            label.position = CGPoint(x: point.x, y: yPosition)
            label.zPosition = 31
            
               addChild(label)
            label.alpha = 0
            label.run(fadeInAni)
            
               
               // Adjust Y position for the next line
               yPosition -= 30  // 30 is the line spacing
            index += 1
           }
        if code == 2{
            picture = SKSpriteNode(imageNamed: "powerupSkip")
            picture.position = CGPoint(x:point.x,y:point.y * 1.10)
            picture.zPosition = 31
            addChild(picture)
           // picture.alpha = 0
           // picture.run(fadeInAni)
            picture.setScale(0.0)
            picture.run(scaleUp)
           
        }
        else if code == 1 {
            picture = SKSpriteNode(imageNamed: "powerupFreeze")
            picture.position = CGPoint(x:point.x,y:point.y * 1.1)
            picture.zPosition = 31
            addChild(picture)
            picture.setScale(0.0)
            picture.run(scaleUp)
            
        
            
        }
        else if code == 0{
            overlay.removeFromParent()
       
        }
       
        let click2continue = SKLabelNode(text: "Tap anywhere to continue.")
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.8)
        let fadeOut =  SKAction.fadeAlpha(to: 0.0, duration: 0.8)
        click2continue.fontSize = 15
       
        click2continue.fontName="Arial"
  
        click2continue.fontColor = .white
        click2continue.position = CGPoint(x: point.x, y: yPosition)
        let flashingSequence = SKAction.sequence([fadeOut, fadeIn])
        click2continue.zPosition = 31
        addChild(click2continue)
        click2continue.run(SKAction.repeatForever(flashingSequence))
        
    }
        /*
    func congratulate(){
        resetText()
        overlay.removeFromParent()
        var yPosition = point.y
        var code = Int.random(in: 0..<winmessage.count, using: &rng)
        let back = SKSpriteNode(imageNamed: "timerbackground")
       
        addChild(back)
      
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            back.run(scaleDown)
        }
        print(code)
        for line in winmessage[code] {
               // Create an SKLabelNode for each line
               let label = SKLabelNode(text: line)
                
               label.fontSize = 30
            label.fontName="Helvetica"
         
               label.fontColor = .white
               label.horizontalAlignmentMode = .center
            label.position = CGPoint(x: point.x, y: yPosition)
            label.zPosition = 31
               addChild(label)
            label.setScale(0.0)
            label.run(scaleUp)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
                label.run(scaleDown)
                
            }
               
               // Adjust Y position for the next line
               yPosition -= 30  // 30 is the line spacing
           }
        back.size = CGSize(width: size.width/2, height: 30 * CGFloat(winmessage[code].count) + 30)
        back.position = CGPoint(x: point.x, y: point.y - 15 * CGFloat(winmessage[code].count) + 22.5)
        back.setScale(0.0)
        back.run(scaleUp)
        back.zPosition = 31
     
    }
    */
    func fadeIn(){
        self.setScale(0)
        
        // Scale up to normal size
        let scaleAction = SKAction.scale(to: 1.0, duration: 0.5)
        
        // Optional: Add easing for smoother animation
        scaleAction.timingMode = .easeOut
        
        self.run(scaleAction)
    }
}
