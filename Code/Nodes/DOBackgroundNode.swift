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
        "pink"
    ]
    var rng = SystemRandomNumberGenerator()
    init() {
        let texture = SKTexture(imageNamed: backgrounds[2])
        super.init(texture: texture, color: .clear, size: texture.size())
        setRandomTexture()
    }

    func setRandomTexture(){
        self.texture = SKTexture(imageNamed: backgrounds[Int.random(in: (0)...(6), using: &rng)])
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(screenSize: CGSize) {
        position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
    }
}
