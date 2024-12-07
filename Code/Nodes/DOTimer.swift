//
//  DOTimer.swift
//  Dot-Dash
//
//  Created by Zhaorong Tu on 12/6/24.
//

import SpriteKit
import GameplayKit

class DOTimer: SKSpriteNode {
    private var totalTime: Int = 20
    private var remainingTime: Int
    private var timeLabel: SKLabelNode!
    private var innerCircle: SKShapeNode!
    private var textureNode: SKSpriteNode!
    private var freezeNode: SKSpriteNode!
    private var timerService: DOTimerTrackerService!
    private var isTimerPaused = false
    private var timeFreeze: Date
    private var timeFrozenCompensation:Double = 0
    public var hasEnded: Bool = false
    private(set) var playedTick: Bool = false
    private var isTexturesPrepared = false
    private var pendingStart = false
    
    var purple = UIColor(red: 180/255.0, green: 122/255.0, blue: 254/255.0, alpha: 1.0)
    var lightPurple = UIColor(red: 220/255.0, green: 197/255.0, blue: 250/255.0, alpha: 1.0)
    var white = UIColor(red: 250/255.0, green: 250/255.0, blue: 250/255.0, alpha: 1.0)
    var blue = UIColor(red: 23/255.0, green: 143/255.0, blue: 255/255.0, alpha: 1.0)
    var gray = UIColor(red: 217/255.0, green: 217/255.0, blue: 217/255.0, alpha: 1.0)
    var red = UIColor(red: 243/255.0, green: 80/255.0, blue: 76/255.0, alpha: 1.0)
    
    private var selfRad = 0.0
    private var selfTime = 20

    init(radius: CGFloat, levelTime: Int = 20, completion: @escaping () -> Void) {
        self.totalTime = levelTime
        self.remainingTime = totalTime
        self.timeFreeze = Date()
        super.init(texture: nil, color: .clear, size: CGSize(width: radius*2, height: radius*2))
        timerService = DOTimerTrackerService(circleSize: CGSize(width: radius*2, height: radius*2)) { [weak self] in
            self?.isTexturesPrepared = true
            if self?.pendingStart == true {
                DispatchQueue.main.async {
                    self?.startAnimation()
                }
            }
            completion()
        }
        setupTimerAppearance(radius: radius)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTimerAppearance(radius: CGFloat, currTime: Int = 20) {
        timeLabel = SKLabelNode(fontNamed: "PPNeueMontreal-Bold")
        timeLabel.fontSize = 14
        timeLabel.fontColor = lightPurple
        timeLabel.position = CGPoint(x: 0, y: 0)
        timeLabel.horizontalAlignmentMode = .center
        timeLabel.verticalAlignmentMode = .center
        timeLabel.zPosition = 10
        timeLabel.text = "00:\(totalTime)"
        addChild(timeLabel)
        
        innerCircle = SKShapeNode(circleOfRadius: radius - 4)
        innerCircle.fillColor = lightPurple
        innerCircle.strokeColor = .clear
        innerCircle.lineWidth = 0
        innerCircle.position = CGPoint(x: 0, y: 0)
        innerCircle.zPosition = 0.5
        addChild(innerCircle)

        textureNode = SKSpriteNode(texture: nil, color: .clear, size: CGSize(width: radius*2, height: radius*2))
        textureNode.position = CGPoint(x: 0, y: 0)
        addChild(textureNode)
        
        freezeNode = SKSpriteNode(imageNamed: "wh_timer_freeze")
        freezeNode.size = CGSize(width: radius*3, height: radius*3)
        freezeNode.position = CGPoint(x: 0, y: 0)
        freezeNode.zPosition = 2
        freezeNode.alpha = 0.0
        addChild(freezeNode)
        
        selfRad = radius
    }
    func timeLeft() -> Int {
        return remainingTime
    }
    func start() {
        isTimerPaused = false
        if isTexturesPrepared {
            startAnimation()
        } else {
            pendingStart = true
        }
    }
    
    private func startAnimation() {
        let textures = timerService.getAllTextures()
        guard !textures.isEmpty else {
            print("Warning: Timer textures array is empty")
            return
        }
        
        let totalDuration = TimeInterval(remainingTime)
        let animation = SKAction.animate(with: textures, timePerFrame: totalDuration / TimeInterval(textures.count))
        textureNode.run(animation, withKey: "countdownAnimation")

        let updateTimeAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.remainingTime -= 1
            self.updateTimeLabel()
            if self.remainingTime <= 0 {
                self.stop()
            }
            print(remainingTime)
        }
        let waitAction = SKAction.wait(forDuration: 1.0)
        let countdownSequence = SKAction.sequence([updateTimeAction, waitAction])
        let countdownAction = SKAction.repeat(countdownSequence, count: remainingTime)
        self.run(countdownAction, withKey: "countdownTimer")
    }

    func pause() {
        if isTimerPaused{
            timeFrozenCompensation += Date().timeIntervalSince(timeFreeze)
        }
        //guard !isTimerPaused else { return }
        isTimerPaused = true
        self.speed = 0.01
        
        //freezeNode.setScale(1.2)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.002)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.01)
        scaleUp.timingMode = .easeOut
        
        /*freezeNode.run(fadeIn)
        freezeNode.run(scaleUp) {
            self.innerCircle.fillColor = self.gray
            self.timeLabel.fontColor = self.white
            self.speed = 0
        }*/
    }

    func resume() {
        //guard isTimerPaused else { return }
        isTimerPaused = false
        self.speed = 1
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        freezeNode.run(fadeOut) {
            self.innerCircle.fillColor = self.lightPurple
            self.updateTimeLabel()
        }
    }

    func stop() {
        hasEnded = true
        print("stop time")
        NotificationCenter.default.post(name: NSNotification.Name("TimerEnded"), object: nil)
        self.removeAction(forKey: "countdownTimer")
        textureNode.removeAction(forKey: "countdownAnimation")
    }
    /*
    func resetTimer(level: Int) {
        hasEnded = false
        playedTick = false
        remainingTime = setTime(level)
        print("setting time to \(totalTime)")
        //remainingTime = setTime(level)//totalTime
        setupTimerAppearance(radius: self.selfRad, currTime: remainingTime)
        updateTimeLabel()
    }*/

    private func updateTimeLabel() {
        let minutes = remainingTime / 60
        let seconds = remainingTime % 60
        timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
        
        if remainingTime < 8 {
            timeLabel.fontColor = .black
            innerCircle.fillColor = red
            if !playedTick {
                playedTick = true
                //SKTAudio.sharedInstance().playSoundEffect(.mmTick)
            }
        } else {
            timeLabel.fontColor = isTimerPaused ? .black : white
        }
    }
}
