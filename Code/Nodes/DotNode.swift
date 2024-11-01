//
//  FruitNode.swift
//  watermelon
//
//  Created by Oleksii Andriushchenko on 26.10.2023.
//

import SpriteKit

class FruitNode: SKNode {

    let texture: SKTexture
    var radius: CGFloat  // I'll keep these 2 params in case we want to play with them
    var scale: CGFloat  // after the MVP is done
    var disabled: Bool
    var current: Bool

    init(texture: SKTexture, scale: CGFloat = 1.0) {

        self.texture = texture
        self.scale = scale
        self.radius = 0.0
        disabled = false // already collected
        current = false // dot we are currently on
        super.init()
        setup(type: type)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        let fruitShape = SKSpriteNode(texture: texture)
        fruitShape.setScale(scale)
        radius = fruitShape.size.width / 2.0
        disabled = false
        addChild(fruitShape)
        current = false

    }

    extension FruitNode {
        enum Constants {
            static let fruitName = "fruit"

        }
    }
}
