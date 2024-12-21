import SpriteKit
import UIKit

enum DOPowerUpType {
    case freezeTime
    case skipLevel
    case inactive
}

class DOPowerUpNode: SKNode {
    private var sprite: SKSpriteNode
   // private let countdownLabel: SKLabelNode
    private let maskNode: SKShapeNode
    private let maskHeight: CGFloat
    private let radius: CGFloat
    
    private var countdownDuration: TimeInterval
    private var type: DOPowerUpType
    private var remainingTime: TimeInterval
    let attributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.white,
        .strokeColor: UIColor.black,
        .strokeWidth: 3.0,
        .font: UIFont(name: "Arial-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16)
    ]
    private var turnedOn = false
    private let overlayNode: SKCropNode
    private let cropNode: SKCropNode = SKCropNode()
    private var shadeOverlay: SKShapeNode?

    init(radius: CGFloat, type: DOPowerUpType, position: CGPoint, duration: TimeInterval = 15.0) {
        self.type = type
        self.countdownDuration = duration
        self.remainingTime = self.countdownDuration
        self.maskHeight = radius * 2
               
        if (type==DOPowerUpType.skipLevel){
            countdownDuration = 0.05
            self.remainingTime = countdownDuration
        }
        
        sprite = SKSpriteNode(imageNamed: "powerupDefault")
        self.radius = radius
        sprite.size = CGSize(width: 2 * radius, height: 2 * radius)
        
        // initialize countdown label
        /*
        countdownLabel = SKLabelNode(fontNamed: "Arial")
        countdownLabel.fontSize = 12
        countdownLabel.fontColor = .white
        countdownLabel.text = "\(Int(countdownDuration))"
        countdownLabel.verticalAlignmentMode = .center
        countdownLabel.position = CGPoint(x: 0, y: -(radius * 1.3))
        */
        overlayNode = SKCropNode()
        let overlayShape = SKShapeNode(circleOfRadius: radius)
        overlayShape.fillColor = .black
        overlayShape.strokeColor = .clear
        overlayShape.alpha = 0.2

        maskNode = SKShapeNode(rectOf: CGSize(width: radius * 2, height: radius * 4))
        maskNode.fillColor = .darkGray
        maskNode.strokeColor = .darkGray
        maskNode.position = CGPoint(x: 0, y: -radius)
        
        super.init()

        configureAppearance()
            
        cropNode.addChild(sprite)
        self.addChild(cropNode)
       // self.addChild(countdownLabel)

        overlayNode.addChild(overlayShape)
        overlayNode.maskNode = maskNode
        self.addChild(overlayNode)

        self.position = position
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureAppearance() {
        switch type {
        case .freezeTime:
            sprite = SKSpriteNode(imageNamed: "powerupFreeze")
            sprite.size = CGSize(width: 2 * radius, height: 2 * radius)
            //  powerupLabel.attributedText = NSAttributedString(string: "❆", attributes: attributes)
          //  countdownLabel.fontSize = 10
            //powerupLabel.fontSize = 20
            break
        case .skipLevel:
            sprite = SKSpriteNode(imageNamed: "powerupSkip")
            sprite.size = CGSize(width: 2 * radius, height: 2 * radius)
            //powerupLabel.attributedText = NSAttributedString(string: "→", attributes: attributes)
          //  countdownLabel.fontSize = 0
            //powerupLabel.fontSize = 20
        default: // or inactive
            sprite = SKSpriteNode(imageNamed: "powerupDefault")
            sprite.size = CGSize(width: 2 * radius, height: 2 * radius)
            return
        }
        fadeIn()
    }
    
    private func createPopAnimation() -> SKAction {
        let popUpAction = SKAction.scale(to: 1.3, duration: 0.05)
        let popDownAction = SKAction.scale(to: 1.0, duration: 0.05)
        return SKAction.sequence([popUpAction, popDownAction])
    }
    
    func startCountdown(completion: @escaping () -> Void) {
        print("Powerup countdown started")
        turnedOn = true
        self.remainingTime = countdownDuration
        // haptic and sound effect
        DOHapticsManager.shared.trigger(.powerUpUsed)
        if (self.isFreezeTime()) {
            let volumeAction = SKAction.changeVolume(to: 0.5, duration: 0)
            let soundAction = SKAction.playSoundFileNamed("DOFreeze.mp3", waitForCompletion: false)
            let sequence = SKAction.sequence([volumeAction, soundAction])
            self.run(sequence)
        }
        
        // 1. pop animation
        let popSequence = createPopAnimation()
        
        // 2. simultaneous drain animations
        let scaleAction = SKAction.scaleY(to: 0, duration: countdownDuration)
    
        let drainAction = SKAction.customAction(withDuration: countdownDuration) { [weak self] node, elapsedTime in
            guard let self = self else { return }
            
            self.remainingTime = max(0, self.countdownDuration - elapsedTime)
        //    self.countdownLabel.text = "\(Int(ceil(self.remainingTime)))"
        }
        
        // group drain animations to run simultaneously
        let drainGroup = SKAction.group([
            SKAction.run { self.maskNode.run(scaleAction) },
            drainAction
        ])
        
        // 3.remove action with pop
        let removeAction = SKAction.sequence([
            createPopAnimation(),
            SKAction.removeFromParent()
        ])
        
        
        
        // combine
        let fullSequence: SKAction
        if self.type == .skipLevel {
            // this works now as long as full sequence is defined as a sequence with only one item
            fullSequence = removeAction
        }
        else {
            fullSequence = SKAction.sequence([
                popSequence,
                drainGroup,
                removeAction
            ])
        }
        /*
        let fullSequence = SKAction.sequence([
            popSequence,
            drainGroup,
            removeAction
        ])
        
        if (self.type == .skipLevel) {
            fullSequence = SKAction.sequence([
                removeAction
            ])
        }
        */
        
        self.run(fullSequence)
        
        if let scene = self.scene as? DOGameScene {
            scene.activePowerUp = self
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
        if type == .skipLevel{
            return turnedOn
        }
        else{
            return remainingTime<=0.0&&turnedOn
        }
      
    }
    func fadeIn(){
        self.setScale(0)
        
        print("Fading out \(self.type)")
        let scaleAction = SKAction.scale(to: 1.0, duration: 0.5)
        scaleAction.timingMode = .easeOut
        
        self.run(scaleAction)
        
    }
    
    func fadeOutPart() {
        //self.sprite.alpha = 1
        //print("DEBUG: Tinted")
        
        shadeOverlay?.removeFromParent()
            
        let shade = SKShapeNode(circleOfRadius: radius)
        shade.fillColor = .black
        shade.strokeColor = .clear
        shade.alpha = 0.7
        shade.position = .zero

        shadeOverlay = shade
        self.addChild(shade)
    }

    func fadeInPart() {
        self.sprite.alpha = 1
        
        shadeOverlay?.removeFromParent()
        shadeOverlay = nil
    }
}
