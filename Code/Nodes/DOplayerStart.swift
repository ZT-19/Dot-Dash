//
//  DOplayerStart.swift
//  Dot-Dash
//
//  Created by Justin Chen on 12/9/24.
//
import SpriteKit
class DOplayerStart: SKNode {
    private let sprite: SKSpriteNode
    
    init(size: CGSize = .zero,position: CGPoint = .zero) {
        sprite = SKSpriteNode(texture: SKTexture(imageNamed: "playerStart"))
        super.init()
        self.position = position
        sprite.size = size
        addChild(sprite)
      
    }
    func setup(screenSize: CGSize) {
       
        position = CGPoint(x:0,y:0)
        //position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

