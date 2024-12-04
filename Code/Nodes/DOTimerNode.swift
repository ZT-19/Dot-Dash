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
    private var timeFreeze: Date
    private var timeFrozenCompensation:Double = 0

    init(initialTime: TimeInterval) {
        self.remainingTime = initialTime
        self.timeFreeze = Date()
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

    func setTime(_ level: Int) -> Double{
        var cnt = 0.0
        switch level {
        case 1...15:
            // linear growth from 20 to 25 seconds
            cnt =  20 + (5.0 / 15.0) * Double(level - 1)
        case 16...40: // 16-30
            // linear growth from 30 to 40 seconds
            cnt = 30 + (10.0 / 25.0) * Double(level - 16) //TODO: change rate of increase
        default:
            // Levels 41+: Logistic growth approaching 120 seconds
            cnt = Double(level)
        }
        remainingTime = cnt
        timerLabel.text = "Time: \(Int(remainingTime))"
        return remainingTime
    }
    
    func addTime(_ seconds: TimeInterval, stealth: Bool = false) {
        remainingTime += seconds
        timerLabel.text = "Time: \(Int(remainingTime))"
        if !stealth{
            emitTimeParticle(seconds: seconds)
        }
          
    }
    func pause(){
        if timerPaused{
            timeFrozenCompensation += Date().timeIntervalSince(timeFreeze)
        }
        timeFreeze = Date()
        
        timerPaused=true
    }
    func resume(){
      //  remainingTime = TimeInterval(timeFreeze)
        addTime(timeFrozenCompensation+Date().timeIntervalSince(timeFreeze),stealth: true)
        timeFrozenCompensation=0
        timerPaused=false
    }
    func setPosition(_ position: CGPoint) {
        timerLabel.position = position
    }
    func getPosition() -> CGPoint {
        return position
    }
}
