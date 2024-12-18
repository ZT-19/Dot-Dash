//
//  DOStarNode.swift
//  Dot-Dash
//
//  Created by Zhaorong Tu on 11/29/24.
//

import SpriteKit

class DOFrameNode: SKNode {
    private let frameSprite: SKSpriteNode
    
    
    override init() {
        //starSprite = SKSpriteNode(imageNamed: "backgroundstar3x")
        frameSprite = SKSpriteNode(texture: SKTexture(imageNamed: "frame"))
        super.init()
        addChild(frameSprite)
        
      
    }
    func setup(screenSize: CGSize) {
      //  self.frameSprite.anchorPoint = CGPoint(x: 0, y: 0)
        frameSprite.size = screenSize
       // position = CGPoint(x:0,y:0)
        position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        let color = UIColor(red: 46/255, green: 44/255, blue: 42/255, alpha: 1)
        let rectleft = SKShapeNode(rect: CGRect(origin: CGPoint(x:-screenSize.width/2 - 100,y:-screenSize.height/2), size: CGSize(width: 101,height: screenSize.height)))
        rectleft.fillColor = color
        rectleft.strokeColor = UIColor(white:0,alpha: 0)
        addChild(rectleft)
        
        let rectTop = SKShapeNode(rect: CGRect(origin: CGPoint(x:-screenSize.width/2,y:screenSize.height/2-25), size: CGSize(width: screenSize.width,height: 50)))
        rectTop.fillColor = color
        rectTop.strokeColor = UIColor(white:0,alpha: 0)
        addChild(rectTop)
        
        
        let rectBottom = SKShapeNode(rect: CGRect(origin: CGPoint(x:-screenSize.width/2,y:-screenSize.height/2-25), size: CGSize(width: screenSize.width,height: 50)))
        rectBottom.fillColor = color
        rectBottom.strokeColor = UIColor(white:0,alpha: 0)
        addChild(rectBottom)
        
        let rectright = SKShapeNode(rect: CGRect(origin: CGPoint(x:screenSize.width/2 - 2 ,y:-screenSize.height/2), size: CGSize(width: 101,height: screenSize.height)))
        rectright.fillColor = color
        rectright.strokeColor = UIColor(white:0,alpha: 0)
        addChild(rectright)

        
        
       
    }
    func setupPowerups(powerUpNodeRadius: Double, powerUpRadius: Double, powerupHeight: Double){
        var xpos = powerUpNodeRadius - frameSprite.size.width/2
        for i in 0..<3{
            let placeholder = SKSpriteNode(texture: SKTexture(imageNamed: "powerupEmpty"))
        
 
            placeholder.size = CGSize(width: powerUpRadius*2 - 3, height: powerUpRadius * 2 - 3)
            placeholder.position = CGPoint(x:xpos,y:powerupHeight - frameSprite.size.height/2)
            print(i)
            addChild(placeholder)
            xpos += (frameSprite.size.width/2-powerUpNodeRadius)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
