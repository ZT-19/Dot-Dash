//
//  DOOnscreenTutorial.swift
//  Dot-Dash
//
//  Created by Justin Chen on 12/13/24.
//

import SpriteKit
class DOOnscreenTutorial: SKNode {
    private var finger: SKSpriteNode
    private var size: CGSize
    init(size: CGSize){
        self.size = size
        finger = SKSpriteNode(imageNamed: "pointer")
        //finger.size = CGSize(width: size.width/5, height: size.height/5)
        finger.name = "finger"
        finger.setScale(0.4)
        super.init()
    }
    
    func firstLevel(){
        reset()
        addChild(finger)
        finger.position = CGPoint(x:size.width * 0.25, y:size.height * 0.6)
        finger.zPosition = 31
        let travel1 = SKAction.move(by: CGVector(dx:size.width/2,dy:0), duration: 1)
        let fadeOut1 = SKAction.fadeAlpha(to: 0.0, duration: 1)
        let returntostart1 = SKAction.move(by: CGVector(dx:-size.width/2,dy:0), duration: 0.3)
        let appear1 = SKAction.fadeAlpha(to: 1.0, duration: 0.001)
        let movingSequence1 = SKAction.sequence([travel1, fadeOut1, returntostart1, appear1])
        finger.run(SKAction.repeatForever(movingSequence1))
    }
    
    func secondLevel(){
        reset()
        addChild(finger)
        
        finger.position = CGPoint(x:size.width * 0.25, y:size.height * 0.4)
      
        finger.zPosition = 31
        let travel2x = SKAction.move(by: CGVector(dx:size.width/2,dy:0), duration: 0.7)
        let wait2 = SKAction.wait(forDuration: 1)
        let travel2y = SKAction.move(by: CGVector(dx:0,dy:size.width/2), duration: 0.7)
        let fadeOut2 = SKAction.fadeAlpha(to: 0.0, duration: 1)
        let returntostart2x = SKAction.move(by: CGVector(dx:-size.width/2,dy:0), duration: 0.3)
        let returntostart2y = SKAction.move(by: CGVector(dx:0,dy:-size.width/2), duration: 0.3)
        let appear = SKAction.fadeAlpha(to: 1.0, duration: 0.001)
        let movingSequence2 = SKAction.sequence([travel2x, wait2, travel2y,fadeOut2, returntostart2x,returntostart2y,appear])
       // let debuggingSequence = SKAction.sequence([traveltest,fadeOut, returntostart,returntostart2, appear])
        finger.run(SKAction.repeatForever(movingSequence2))
       // finger.run(SKAction.repeatForever(debuggingSequence))
    }
    
    
    func reset(){
        removeAllChildren()
        finger.removeAllActions()
    }
    
    func isActive()->Bool{
        return childNode(withName: "finger") != nil
    }
    required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
}
