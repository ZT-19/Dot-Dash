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
        let padding: CGFloat = 20
        // top left position
        position = CGPoint(x: padding + 40, y: screenSize.height - padding - 55)
                           
        //position = CGPoint(x: screenSize.width / 2, y: (screenSize.height - 167.5 / 874.0 * screenSize.height)) // central position

        let background = SKSpriteNode(imageNamed: "timerbackground")
        background.size = CGSize(width: 96, height: 40)
        addChild(background)

        updateLevel(with: 1)
        textNode.fontSize = 24
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
