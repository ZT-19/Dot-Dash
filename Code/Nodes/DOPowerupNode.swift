import SpriteKit

enum PowerUpType {
    case doubleDotScore
    case levelScoreBonus
    case freezeTime
}

class DOPowerUpNode: SKNode {
    private let circleShape: SKShapeNode
    private let countdownLabel: SKLabelNode
    private let powerupLabel: SKLabelNode
    private var countdownDuration: TimeInterval
    private var type: PowerUpType
    private var remainingTime: TimeInterval

    init(radius: CGFloat, type: PowerUpType, position: CGPoint, duration: TimeInterval = 15.0) {
        self.type = type
        self.countdownDuration = duration
        self.remainingTime = duration

        // circular base
        circleShape = SKShapeNode(circleOfRadius: radius)
        circleShape.fillColor = .yellow
        circleShape.strokeColor = .darkGray
        circleShape.lineWidth = 1

        powerupLabel = SKLabelNode(fontNamed: "Arial")
        powerupLabel.fontSize = 16
        powerupLabel.fontColor = .darkGray
        powerupLabel.verticalAlignmentMode = .center
        powerupLabel.position = CGPoint(x: 0, y: 0)

        // countdown label (below circle)
        countdownLabel = SKLabelNode(fontNamed: "Arial")
        countdownLabel.fontSize = 12 // Smaller size
        countdownLabel.fontColor = .white
        countdownLabel.text = "\(Int(duration))"
        countdownLabel.verticalAlignmentMode = .center
        countdownLabel.position = CGPoint(x: 0, y: -(radius * 1.5)) // hardcode offset below

        super.init()
        
        self.position = position
        self.addChild(circleShape)
        self.addChild(powerupLabel)
        self.addChild(countdownLabel)

        configureAppearance()
        startCountdown()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAppearance() {
        switch type {
        case .doubleDotScore:
            circleShape.fillColor = .green
            powerupLabel.text = "2X"
            countdownLabel.fontSize = 10 // hardcoded constant: small for 2 characters
        case  .levelScoreBonus:
            circleShape.fillColor = .yellow
            powerupLabel.text = "+"
            countdownLabel.fontSize = 10 // hardcoded constant
        case .freezeTime:
            circleShape.fillColor = .cyan
            powerupLabel.text = "❆"
            countdownLabel.fontSize = 10 // hardcoded constant
        }
    }
    private func startCountdown() {
        let countdownAction = SKAction.customAction(withDuration: countdownDuration) { [weak self] _, elapsedTime in
            guard let self = self else { return }

            // Update label with remaining seconds
            remainingTime = max(0, self.countdownDuration - elapsedTime)
            self.countdownLabel.text = "\(Int(ceil(remainingTime)))"
        }

        // fade out animation for entire node
        let fadeOutAction = SKAction.fadeOut(withDuration: countdownDuration)

        // remove node from parent after countdown
        let removeAction = SKAction.run { [weak self] in
            self?.removeFromParent()
            print("Removed powerup from node")
        }

        // group the fade-out with the countdown timer
        let fadeAndCountdownGroup = SKAction.group([countdownAction, fadeOutAction])

        // run the grouped actions together followed by removal
        self.run(SKAction.sequence([fadeAndCountdownGroup, removeAction]))
    }
    func getPosition() -> CGPoint {
        return position
    }
    func islevelScoreBonus() -> Bool {
        return type == .levelScoreBonus
        }

    func isDoubleDotScore() -> Bool {
        return type == .doubleDotScore
    }
    
    func isFreezeTime() -> Bool {
        return type == .freezeTime
    }
    
    func isActive() -> Bool {
        return remainingTime > 0
    }
}
