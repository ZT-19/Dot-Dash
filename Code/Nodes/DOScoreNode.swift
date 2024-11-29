//
//  DOScoreNode.swift
//  Dot Dash Score 
//
//  Created by Justin Chen, 11/4/2024

import SpriteKit

class DOScoreNode: SKNode {
    private let textNode = SKLabelNode(fontNamed: "Arial")

    func setup(screenSize: CGSize) {
        position = CGPoint(x: screenSize.width / 2, y: screenSize.height - 70 - Constants.size.height / 2)
        updateScore(with: 0)
        textNode.verticalAlignmentMode = .center
        addChild(textNode)
    }
    
    func getPosition() -> CGPoint {
        return position
    }

    private func emitScoreParticle(text: String, mode: Int = 0) {
        let particle = SKLabelNode(fontNamed: "Arial")
        particle.text = text
        particle.fontSize = 12
        particle.fontColor = .white
        particle.position = CGPoint(x: textNode.frame.maxX + 10, y: textNode.frame.midY)
        addChild(particle)
        
        // Animation sequence
        let moveUp = SKAction.moveBy(x: 20, y: 20, duration: 0.7) // hardcoded constant
        let fadeOut = SKAction.fadeOut(withDuration: 0.7)
        let scale = SKAction.scale(to: 0.7, duration: 0.7)
        let group = SKAction.group([moveUp, fadeOut, scale])
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([group, remove])
        
        particle.run(sequence)
    }

    func updateScore(with score: Int, mode: Int = 0) {
        if let currentScore = Int(textNode.text ?? "0") {
                // mode 0: no emission
                // mode 1: show score difference
                if mode == 1 {
                    let difference = score - currentScore
                    if difference > 0 {
                        emitScoreParticle(text: "+\(difference)")
                    }
                }
                // mode 2: show bonus text
                else if mode == 2 {
                    emitScoreParticle(text: "Bonus!")
                }
            }
        textNode.text = "\(score)"
    }
}

extension DOScoreNode {
    enum Constants {
        static let size = CGSize(width: 140, height: 45)
    }
}
