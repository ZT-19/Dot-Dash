import SpriteKit

enum PowerUpType {
    case doubleDotScore
    case levelScoreBonus
    case freezeTime
}

class DOPowerUpNode: SKNode {
    // MARK: - Properties
    private let circleShape: SKShapeNode
    private let countdownLabel: SKLabelNode
    private let powerupLabel: SKLabelNode
    private let cropNode: SKCropNode
    private let maskNode: SKShapeNode
    private let maskHeight: CGFloat
    
    private var countdownDuration: TimeInterval
    private var type: PowerUpType
    private var remainingTime: TimeInterval
    let attributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.white,
        .strokeColor: UIColor.black,
        .strokeWidth: 3.0,  // Negative value for outer stroke
        .font: UIFont(name: "Arial-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16)
    ]

    init(radius: CGFloat, type: PowerUpType, position: CGPoint, duration: TimeInterval = 15.0) {
        self.type = type
        self.countdownDuration = duration
        self.remainingTime = duration
        self.maskHeight = radius * 2

        // Initialize circle shape
        circleShape = SKShapeNode(circleOfRadius: radius)
        circleShape.fillColor = .yellow
        circleShape.strokeColor = .darkGray
        circleShape.lineWidth = 1

        // Initialize powerup label
        powerupLabel = SKLabelNode(fontNamed: "Arial-Bold")
        powerupLabel.fontSize = 16
        powerupLabel.fontColor = .white
        powerupLabel.verticalAlignmentMode = .center
        powerupLabel.position = CGPoint(x: 0, y: 0)

        // Add stroke using NSAttributedString
        
        powerupLabel.attributedText = NSAttributedString(string: "2X", attributes: attributes)

        // Initialize countdown label
        countdownLabel = SKLabelNode(fontNamed: "Arial")
        countdownLabel.fontSize = 12
        countdownLabel.fontColor = .white
        countdownLabel.text = "\(Int(duration))"
        countdownLabel.verticalAlignmentMode = .center
        countdownLabel.position = CGPoint(x: 0, y: -(radius * 1.5))

        // Initialize crop node and mask
        cropNode = SKCropNode()
        maskNode = SKShapeNode(rectOf: CGSize(width: radius * 2, height: radius * 4))
        maskNode.fillColor = .darkGray
        maskNode.strokeColor = .darkGray
        // Set anchor point at top by positioning
        maskNode.position = CGPoint(x: 0, y: -radius)

        super.init()

        // Setup node hierarchy
        cropNode.maskNode = maskNode
        cropNode.addChild(circleShape)
        self.position = position
        self.addChild(cropNode)
        self.addChild(powerupLabel)
        self.addChild(countdownLabel)

        configureAppearance()
        startCountdown()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods
    private func configureAppearance() {
        switch type {
        case .doubleDotScore:
            circleShape.fillColor = .green
            powerupLabel.attributedText = NSAttributedString(string: "2X", attributes: attributes)
            countdownLabel.fontSize = 10
        case .levelScoreBonus:
            circleShape.fillColor = .yellow
            powerupLabel.attributedText = NSAttributedString(string: "+", attributes: attributes)
            countdownLabel.fontSize = 10
        case .freezeTime:
            circleShape.fillColor = .cyan
            powerupLabel.attributedText = NSAttributedString(string: "❆", attributes: attributes)
            countdownLabel.fontSize = 10
        }
    }

    private func startCountdown() {
        // Create draining animation
        let scaleAction = SKAction.scaleY(to: 0, duration: countdownDuration)
        maskNode.run(scaleAction)
        
        // Update countdown label
        let countdownAction = SKAction.customAction(withDuration: countdownDuration) { [weak self] _, elapsedTime in
            guard let self = self else { return }
            self.remainingTime = max(0, self.countdownDuration - elapsedTime)
            self.countdownLabel.text = "\(Int(ceil(self.remainingTime)))"
        }
        
        // Remove node when complete
        let removeAction = SKAction.run { [weak self] in
            self?.removeFromParent()
            print("Removed powerup from node")
        }
        
        // Run countdown and removal sequence
        self.run(SKAction.sequence([countdownAction, removeAction]))
    }

    // MARK: - Public Methods
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
