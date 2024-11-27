//
//  DOTimerNode.swift
//  Dot-Dash
//
//  Created by Zhaorong Tu on 11/26/24.
//

import SpriteKit

class DOExplodingTimerNode: SKNode {
    private let timerLabel = SKLabelNode(fontNamed: "Arial")
    private var remainingTime: TimeInterval
    private var lastUpdateTime: TimeInterval = 0

    init(initialTime: TimeInterval) {
        self.remainingTime = initialTime
        super.init()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        timerLabel.text = "Time: \(Int(remainingTime))"
        timerLabel.fontSize = 24
        timerLabel.fontColor = .white
        addChild(timerLabel)
    }

    func update(_ currentTime: TimeInterval) -> Bool {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }

        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        remainingTime -= deltaTime
        if remainingTime <= 0 {
            remainingTime = 0
            return true // signals game over
        }

        timerLabel.text = "Time: \(Int(remainingTime))"
        return false
    }
    func addTime(_ seconds: TimeInterval) {
        remainingTime += seconds
        timerLabel.text = "Time: \(Int(remainingTime))"
    }
    func setPosition(_ position: CGPoint) {
        timerLabel.position = position
    }
}
