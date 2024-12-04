//
//  DOTimerNode.swift
//  Dot-Dash
//
//  Created by Zhaorong Tu on 11/26/24.
//

import SpriteKit

class DOTimerNode: SKNode {
    private let timerLabel = SKLabelNode(fontNamed: "Arial")
    private var remainingTime: TimeInterval
    private var lastUpdateTime: TimeInterval = 0
    private var timerPaused: Bool = false

    init(initialTime: TimeInterval) {
        self.remainingTime = initialTime
        super.init()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        timerLabel.text = "\(Int(remainingTime))"
        timerLabel.fontSize = 24
        timerLabel.fontColor = .white
        addChild(timerLabel)
    }
    private func emitTimeParticle(seconds: TimeInterval) {
    let particle = SKLabelNode(fontNamed: "Arial")
    particle.text = "+\(Int(seconds))"
    particle.fontSize = 12
    particle.fontColor = .white
    particle.position = CGPoint(x: timerLabel.frame.maxX + 10, y: timerLabel.frame.midY)
    addChild(particle)
    
    // Animation sequence
    let moveUp = SKAction.moveBy(x: 10, y: 15, duration: 0.7)
    let fadeOut = SKAction.fadeOut(withDuration: 0.7)
    let scale = SKAction.scale(to: 0.7, duration: 0.7)
    let group = SKAction.group([moveUp, fadeOut, scale])
    let remove = SKAction.removeFromParent()
    let sequence = SKAction.sequence([group, remove])
    
    particle.run(sequence)
}

    func update(_ currentTime: TimeInterval) -> Bool {
        if (timerPaused){
            return false
        }
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
    func addTime(_ seconds: TimeInterval, stealth: Bool = false) {
        remainingTime += seconds
        timerLabel.text = "Time: \(Int(remainingTime))"
        if !stealth{
            emitTimeParticle(seconds: seconds)
        }
          
    }
    func pause(){
        timerPaused=true
    }
    func resume(){
        timerPaused=false
    }
    func setPosition(_ position: CGPoint) {
        timerLabel.position = position
    }
    func getPosition() -> CGPoint {
        return position
    }
}
