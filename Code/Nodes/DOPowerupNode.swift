import SpriteKit

enum PowerUpType {
 //   case doubleDotScore
 //   case levelScoreBonus
    case freezeTime
 //   case extraSlot
    case skipLevel
    case inactive
}

class DOPowerUpNode: SKNode {
    private var sprite: SKSpriteNode
    private let countdownLabel: SKLabelNode
    //private let powerupLabel: SKLabelNode
    private let cropNode: SKCropNode
    private let maskNode: SKShapeNode
    private let maskHeight: CGFloat
    private let radius: CGFloat
    
    private var countdownDuration: TimeInterval
    private var type: PowerUpType
    private var remainingTime: TimeInterval
    let attributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.white,
        .strokeColor: UIColor.black,
        .strokeWidth: 3.0,
        .font: UIFont(name: "Arial-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16)
    ]
    private var turnedOn = false

    init(radius: CGFloat, type: PowerUpType, position: CGPoint, duration: TimeInterval = 15.0) {
        self.type = type
        self.countdownDuration = duration
        self.remainingTime = self.countdownDuration
        self.maskHeight = radius * 2
        
        if (type==PowerUpType.skipLevel){
            countdownDuration = 0.05
            self.remainingTime = countdownDuration
        }
        /*
        circleShape = SKShapeNode(circleOfRadius: radius)
        circleShape.fillColor = .yellow
        circleShape.strokeColor = .darkGray
        circleShape.lineWidth = 1
         */
        sprite = SKSpriteNode(imageNamed: "powerupDefault")
        self.radius = radius
        sprite.size = CGSize(width: 2 * radius, height: 2 * radius)
        // powerup label
        /*
        powerupLabel = SKLabelNode(fontNamed: "Arial-Bold")
        powerupLabel.fontSize = 16
        powerupLabel.fontColor = .white
        powerupLabel.verticalAlignmentMode = .center
        powerupLabel.position = CGPoint(x: 0, y: 0)
        
        powerupLabel.attributedText = NSAttributedString(string: "2X", attributes: attributes)
         */
        // initialize countdown label
        countdownLabel = SKLabelNode(fontNamed: "Arial")
        countdownLabel.fontSize = 12
        countdownLabel.fontColor = .white
        countdownLabel.text = "\(Int(countdownDuration))"
        countdownLabel.verticalAlignmentMode = .center
        countdownLabel.position = CGPoint(x: 0, y: -(radius * 1.3))

        // initialize crop node and mask for draining animation
        cropNode = SKCropNode()
        maskNode = SKShapeNode(rectOf: CGSize(width: radius * 2, height: radius * 4))
        maskNode.fillColor = .darkGray
        maskNode.strokeColor = .darkGray
        // set anchor point at top by positioning
        maskNode.position = CGPoint(x: 0, y: -radius)

        super.init()

        // setup node hierarchy
        cropNode.maskNode = maskNode
        
       
        configureAppearance()
        
        cropNode.addChild(sprite)
        
        self.position = position
        self.addChild(cropNode)
    
        self.addChild(countdownLabel)
       
       
       // startCountdown() // comment out and instead start on touch in gamescene
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureAppearance() {
        switch type {
            /*
        case .doubleDotScore:
            circleShape.fillColor = .green
            powerupLabel.attributedText = NSAttributedString(string: "2X", attributes: attributes)
            countdownLabel.fontSize = 10
            powerupLabel.fontSize = 20
            break
        case .levelScoreBonus:
            circleShape.fillColor = .yellow
            powerupLabel.attributedText = NSAttributedString(string: "+", attributes: attributes)
            countdownLabel.fontSize = 10
            powerupLabel.fontSize = 20
            break
        case .extraSlot:
            circleShape.fillColor = .orange
            powerupLabel.attributedText = NSAttributedString(string: "+", attributes: attributes)
            countdownLabel.fontSize = 0
            powerupLabel.fontSize = 20
            */
        case .freezeTime:
            sprite = SKSpriteNode(imageNamed: "powerupFreeze")
            sprite.size = CGSize(width: 2 * radius, height: 2 * radius)
          //  powerupLabel.attributedText = NSAttributedString(string: "❆", attributes: attributes)
            countdownLabel.fontSize = 10
            //powerupLabel.fontSize = 20
            break
        case .skipLevel:
            sprite = SKSpriteNode(imageNamed: "powerupSkip")
            sprite.size = CGSize(width: 2 * radius, height: 2 * radius)
            //powerupLabel.attributedText = NSAttributedString(string: "→", attributes: attributes)
            countdownLabel.fontSize = 0
            //powerupLabel.fontSize = 20
       
        default: // or inactive
            sprite = SKSpriteNode(imageNamed: "powerupDefault")
            sprite.size = CGSize(width: 2 * radius, height: 2 * radius)
            return
        }
            fadeIn()
    }

    func startCountdown(completion: @escaping () -> Void) {
        // create draining animation
        turnedOn = true
        self.remainingTime = countdownDuration
        let scaleAction = SKAction.scaleY(to: 0, duration: countdownDuration)
        maskNode.run(scaleAction)
        
        // update countdown label
        let countdownAction = SKAction.customAction(withDuration: countdownDuration) { [weak self] _, elapsedTime in
            guard let self = self else { return }
            self.remainingTime = max(0, self.countdownDuration - elapsedTime)
            self.countdownLabel.text = "\(Int(ceil(self.remainingTime)))"
        }
        
        // remove node when complete
        let removeAction = SKAction.run { [weak self] in
            self?.removeFromParent()
            //print("Removed powerup from node")
        }
        
        // run countdown and removal sequence
        self.run(SKAction.sequence([countdownAction, removeAction]))
        
        if let scene = self.scene as? GameSKScene {
                scene.activePowerUp = self
                scene.fadeOutOtherPowerUps(except: self)
            }
    }

    func getPosition() -> CGPoint {
        return position
    }
    func getTimeLeft() -> Double{
        return self.remainingTime
    }
    func getTimeStart() -> Double{
        return self.countdownDuration
    }
    /*
    func islevelScoreBonus() -> Bool {
        return type == .levelScoreBonus
    }

    func isDoubleDotScore() -> Bool {
        return type == .doubleDotScore
    }
    func isExtraSlot() -> Bool {
        return type == .extraSlot
    }
     */
    func isSkipLevel() -> Bool {
        return type == .skipLevel
    }
    
    func isFreezeTime() -> Bool {
        return type == .freezeTime
    }
    
    func isActive() -> Bool {
        return turnedOn
    }
    
    func isSpent() -> Bool{
        return remainingTime<=0&&turnedOn
    }
    func fadeIn(){
        self.setScale(0)
    
    // Scale up to normal size
    let scaleAction = SKAction.scale(to: 1.0, duration: 0.5)
    
    // Optional: Add easing for smoother animation
    scaleAction.timingMode = .easeOut
    
    self.run(scaleAction)
        
    }
    
    func fadeOutPart() {
        self.sprite.alpha = 0.5
    }

    func fadeInPart() {
        self.sprite.alpha = 1
    }
}
