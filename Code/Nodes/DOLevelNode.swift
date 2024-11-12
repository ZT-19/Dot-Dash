//
//  DOLevelNode.swift
//  Dot-Dash Level Node
//
//  Created by Justin Chen on 11/7/24.
//



import SpriteKit

class DOLevelNode: SKNode {

    private let textNode = SKLabelNode()

    func setup(screenSize: CGSize) {
        position = CGPoint(x: screenSize.width / 2, y: screenSize.height - 120 - Constants.size.height / 2)

      
        updateLevel(with: 1)
        textNode.verticalAlignmentMode = .center
        addChild(textNode)
    }

    func adjustPosition(cameraNode: SKNode, screenSize: CGSize) {
        let cameraPosition = cameraNode.position
        position = CGPoint(x: 50, y: cameraPosition.y + screenSize.height / 2 - 70)
    }

    func updateLevel(with level: Int) {
        textNode.attributedText = NSAttributedString(
            string: "Level \(level)",
            attributes: [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 40, weight: .bold)
            ]
        )
    }
    
}

extension DOLevelNode {
    enum Constants {
        static let size = CGSize(width: 140, height: 45)
    }
}
