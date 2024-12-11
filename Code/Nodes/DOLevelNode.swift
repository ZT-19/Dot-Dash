//
//  DOLevelNode.swift
//  Dot-Dash Level Node
//
//  Created by Justin Chen on 11/7/24.
//



import SpriteKit

class DOLevelNode: SKNode {

    private let textNode = SKLabelNode(fontNamed: "Arial")

    func setup(screenSize: CGSize) {
        position = CGPoint(x: screenSize.width / 2, y: screenSize.height - 145 - Constants.size.height / 2)
        let background = SKSpriteNode(imageNamed: "timerbackground")
        background.size = CGSize(width:150, height: 52.5)
        addChild(background)
        updateLevel(with: 1)
        textNode.verticalAlignmentMode = .center
        addChild(textNode)
        
    }
    
    func getPosition() -> CGPoint {
        return position
    }

    func updateLevel(with level: Int) {
        textNode.text = "Level \(level)"
    }
    
}

extension DOLevelNode {
    enum Constants {
        static let size = CGSize(width: 140, height: 45)
    }
}
