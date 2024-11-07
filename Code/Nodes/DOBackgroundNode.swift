//
//  DOBackgroundNode.swift
//  watermelon
//
//  Created by Oleksii Andriushchenko on 30.10.2023.
//

import SpriteKit

class DOBackgroundNode: SKSpriteNode {
    init() {
        let texture = SKTexture(imageNamed: "blue")
        super.init(texture: texture, color: .clear, size: texture.size())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(screenSize: CGSize) {
        position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
    }
}
