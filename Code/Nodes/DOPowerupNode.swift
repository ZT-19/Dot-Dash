//
//  DOPowerupNode.swift
//  Dot-Dash
//
//  Created by Zhaorong Tu on 11/27/24.
//

import SpriteKit

enum PowerUpType {
    case inactive
    case doubleScorePerNode
    case doubleScoreBonusPerLevel
}

class DOPowerUpNode: SKNode {
    private let icon = SKSpriteNode()
    private let type: PowerUpType

    init(type: PowerUpType, position: CGPoint) {
        self.type = type
        super.init()
        self.position = position
        setupAppearance()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupAppearance() {
        switch type {
        case .doubleScorePerNode:
            //icon.texture = SKTexture(imageNamed: "double_score_node_icon") // replace with actual asset name
            icon.texture = SKTexture()
        case .doubleScoreBonusPerLevel:
            icon.texture = SKTexture()
        case .inactive:
            break
        }
        icon.size = CGSize(width: 40, height: 40) // Adjust as needed
        addChild(icon)
    }

    func getType() -> PowerUpType {
        return type
    }
}
