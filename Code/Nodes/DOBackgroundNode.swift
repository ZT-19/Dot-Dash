//
//  DOBackgroundNode.swift
//  watermelon
//
//  Created by Oleksii Andriushchenko on 30.10.2023.
//

import SpriteKit

class DOBackgroundNode: SKSpriteNode {
    private var backgrounds = [
        "blue",
        "green",
        "red",
        "black",
        "navy",
        "yellow",
        "navy2",
        "blue2",
        "orange"
    ]

    private var secretBackgrounds = [
        "secret1"
    ]
    
    var rng = SystemRandomNumberGenerator()
    init() {
        let texture = SKTexture(imageNamed: backgrounds[0])
        super.init(texture: texture, color: .clear, size: texture.size())
        setRandomTexture(secret: false)
    }

    func setRandomTexture(secret: Bool){
        if !secret{
            self.texture = SKTexture(imageNamed: backgrounds[Int.random(in: (0)...(backgrounds.count-1), using: &rng)])
        }
        else{
            
            self.texture = SKTexture(imageNamed: secretBackgrounds[Int.random(in: (0)...(secretBackgrounds.count-1), using: &rng)])
        }
    }
    func setDeterminedTexture(id:Int, secret: Bool){
        if !secret{
            self.texture = SKTexture(imageNamed: backgrounds[id])
        }
        else{
            
            self.texture = SKTexture(imageNamed: secretBackgrounds[id])
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(screenSize: CGSize) {
        position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
    }
}
