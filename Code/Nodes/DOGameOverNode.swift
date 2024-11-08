//
//  DOLevelNode.swift
//  Dot-Dash Level Node
//
//  Created by Justin Chen on 11/7/24.
//



import SpriteKit

class DOGameOverNode: SKNode {

    private let textNode = SKLabelNode()
    
    func setup(screenSize: CGSize) {
        position = CGPoint(x: screenSize.width / 2, y: screenSize.height - 160 - Constants.size.height / 2)
        
        updateMessage()
        textNode.verticalAlignmentMode = .center
        addChild(textNode)
        
       
    }

    func adjustPosition(cameraNode: SKNode, screenSize: CGSize) {
        let cameraPosition = cameraNode.position
        position = CGPoint(x: 50, y: cameraPosition.y + screenSize.height / 2 - 70)
    }
    func updateMessage() {
        textNode.attributedText = NSAttributedString(
            string: "Game Over",
            attributes: [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 40, weight: .bold)
            ]
        )
    }
    
}

extension DOGameOverNode {
    enum Constants {
        static let size = CGSize(width: 280, height: 90)
    }
}

//
//  DOScoreNode.swift
//  Dot Dash Score
//
//  Created by Justin Chen, 11/4/2024


