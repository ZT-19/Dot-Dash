//
//  DOScoreNode.swift
//  Dot Dash level loading
//     NOT DONE, ZHAORONG USE UR LEVEL GEN CODE
//  Created by Justin Chen, 11/4/2024



import SpriteKit

class DOScoreNode: SKNode {

    private let textNode = SKLabelNode()

    func setup(screenSize: CGSize) {
        position = CGPoint(x: screenSize.width / 2, y: screenSize.height - 59 - Constants.size.height / 2)

      
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
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 40, weight: .bold)
            ]
        )
    }
}

extension DOScoreNode {
    enum Constants {
        static let size = CGSize(width: 140, height: 45)
    }
}
