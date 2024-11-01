//
//  ScoreNode.swift
//  watermelon
//
//  Created by Oleksii Andriushchenko on 26.10.2023.
//

import SpriteKit

class ScoreNode: SKNode {

    private let textNode = SKLabelNode()

    func setup(screenSize: CGSize) {
        position = CGPoint(x: screenSize.width / 2, y: screenSize.height - 59 - Constants.size.height / 2)

        let backgroundNode = SKShapeNode(
            rect: CGRect(
                origin: CGPoint(x: -(Constants.size.width / 2), y: -(Constants.size.height / 2)),
                size: Constants.size
            ),
            cornerRadius: Constants.size.height / 2
        )
        backgroundNode.fillColor = .white
        backgroundNode.strokeColor = UIColor(named: "1672c4") ?? .clear
        addChild(backgroundNode)
        updateScore(with: 0)
        textNode.verticalAlignmentMode = .center
        addChild(textNode)
    }

    func adjustPosition(cameraNode: SKNode, screenSize: CGSize) {
        let cameraPosition = cameraNode.position
        position = CGPoint(x: 50, y: cameraPosition.y + screenSize.height / 2 - 70)
    }

    func updateScore(with score: Int) {
        textNode.attributedText = NSAttributedString(
            string: "\(score)",
            attributes: [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 26, weight: .bold)
            ]
        )
    }
}

extension ScoreNode {
    enum Constants {
        static let size = CGSize(width: 140, height: 45)
    }
}
