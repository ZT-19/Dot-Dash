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

   // New properties for circular animation
    private var innerCircle: SKShapeNode!
    private var textureNode: SKSpriteNode!
    private var timerService: DOTimerTrackerService!
    private var isTexturesPrepared = false
    private var pendingStart = false
    private let radius: CGFloat = 30 // Adjust size as needed

    init(initialTime: TimeInterval) {
        self.remainingTime = initialTime
        self.timeFreeze = Date()
        super.init()
        setupTimerService()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTimerService() {
        timerService = DOTimerTrackerService(circleSize: CGSize(width: radius*2, height: radius*2)) { [weak self] in
            self?.isTexturesPrepared = true
            if self?.pendingStart == true {
                DispatchQueue.main.async {
                    self?.startAnimation()
                }
            }
        }
    }

    func start() {
        if isTexturesPrepared {
            startAnimation()
        } else {
            pendingStart = true
        }
    }

    // Modify setup() in DOTimerNode
    private func setup() {
        // Setup circle background
        innerCircle = SKShapeNode(circleOfRadius: radius)
        innerCircle.fillColor = .gray
        innerCircle.strokeColor = .clear
        innerCircle.zPosition = 1
        addChild(innerCircle)

        // Setup texture node for animation
        textureNode = SKSpriteNode(texture: nil, color: .clear, size: CGSize(width: radius*2, height: radius*2))
        textureNode.zPosition = 2
        addChild(textureNode)

        // Setup timer label
        timerLabel.text = "\(Int(remainingTime))"
        timerLabel.fontSize = 24
        timerLabel.fontColor = .white
        timerLabel.verticalAlignmentMode = .center
        timerLabel.horizontalAlignmentMode = .center
        timerLabel.zPosition = 3
        addChild(timerLabel)
    }
      private func startAnimation() {
        let textures = timerService.getAllTextures()
        guard !textures.isEmpty else { return }
        
        let totalDuration = remainingTime
        let animation = SKAction.animate(with: textures, timePerFrame: totalDuration / TimeInterval(textures.count))
        textureNode.run(animation, withKey: "countdownAnimation")
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
    }
    func pause() {
        if timerPaused {
            timeFrozenCompensation += Date().timeIntervalSince(timeFreeze)
        }
        timeFreeze = Date()
        timerPaused = true
        
        // Pause animation
        textureNode.isPaused = true
    }

    // Modified resume function
    func resume() {
        addTime(timeFrozenCompensation + Date().timeIntervalSince(timeFreeze), stealth: true)
        timeFrozenCompensation = 0
        timerPaused = false
        
        // Resume animation
        textureNode.isPaused = false
    }

    func setPosition(_ position: CGPoint) {
        timerLabel.position = position
    }
    func getPosition() -> CGPoint {
        return position
    }
}
