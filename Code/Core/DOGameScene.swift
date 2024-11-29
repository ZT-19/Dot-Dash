// Code/Core/DOGameScene.swift

import SpriteKit
import SwiftUI

public struct DOGameScene: View {
    public var body: some View {
        SpriteView(scene: createDOGameScene())
            .ignoresSafeArea()
    }

    private func createDOGameScene() -> SKScene {
        let scene = GameSKScene()
        scene.size = UIScreen.main.bounds.size
        scene.scaleMode = .resizeFill
        return scene
    }
}

class GameSKScene: SKScene, SKPhysicsContactDelegate {

    private var grid = DOGameContext.shared.grid
    private let dotSpacing = DOGameContext.shared.dotSpacing
    private let gridSize = DOGameContext.shared.gridSize
    private var offsetX: CGFloat = 0
    private var offsetY: CGFloat = 0
    private var difficulty = 1//TEST
    private var dotCount: Int = 0
    
    //private let seed: UInt64 = 12345 // used for testing to seed rng
    var rng = SystemRandomNumberGenerator()
    let backgroundNode = DOBackgroundNode()
    let scoreNode = DOScoreNode()
    let levelNode = DOLevelNode()
    let gameOverNode = DOGameOverNode()
    var playerNode = DOPlayerNode()
    private var gameInfo = DOGameInfo()
    private var gameOverScreen = false
    private var theme = 0
    
    // player position
    private var lastPosition: CGPoint = .zero
    private var firstPosition: CGPoint = .zero
    private var xv: Int = .zero
    private var yv: Int = .zero
    
    // timer
    private var remainingTime: TimeInterval = 60
    private var bonusTime = 30.0
    private var timerNode: DOTimerNode!
    private var explodingTimer: DOExplodingTimerNode!
    
    /*
    MODIFIER STATES:
    modeCode is -1: inactive
    modCode is 0: exploding timer
    modCode is 1: sudden death
    modCode is 2: double difficulty
     */
    private let modInterval = 5
    private var modCode: Int? // -1 is inactive, anything above 0 represents a modifier
    private var modNotificationLabel: SKLabelNode?
    
    // powerups
    private let powerupRadius = 20.0
    private let powerupTypes: [PowerUpType] = [
        .doubleDotScore,
        .levelScoreBonus,
        .freezeTime
    ]
    private var powerupNode: DOPowerUpNode!
    private var powerupEligible = true
    private var powerupNotificationLabel: SKLabelNode?
    private var powerupCurr = PowerUpType.doubleDotScore

    override func didMove(to view: SKView) {
        self.backgroundColor = .gray
        self.physicsWorld.contactDelegate = self

        backgroundNode.setup(screenSize: size)
        gameOverNode.setup(screenSize: size)
        backgroundNode.zPosition = 0
        addChild(backgroundNode)

        scoreNode.setup(screenSize: size)
        addChild(scoreNode)

        levelNode.setup(screenSize: size)
        addChild(levelNode)

        // center grid on screen and draw it
        let gridWidth = CGFloat(gridSize) * dotSpacing
        offsetX = max(30, (size.width - gridWidth) / 2)
        offsetY = max(30, (size.height - gridWidth) / 2)
        drawGrid(difficultyRating: difficulty, initX: 6, initY: 6)
        
        // setup timer node
        timerNode = DOTimerNode(initialTime: remainingTime)
        timerNode.setPosition(CGPoint(x: size.width / 2, y: size.height / 5))
        addChild(timerNode)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if !(powerupNode != nil && powerupNode.isFreezeTime() && powerupNode.isActive()) {
            if timerNode.update(currentTime) {
                gameOver()
            }
        }
        if let explodingTimer = explodingTimer {
            if !(powerupNode != nil && powerupNode.isFreezeTime() && powerupNode.isActive()) {
                if explodingTimer.update(currentTime) {
                    gameOver()
                }
            }
        }
        // modifier states
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        handleTouch(touch)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        handleTouchEnd(touch)
    }

    private func handleTouch(_ touch: UITouch) {
        firstPosition = touch.location(in: self)
    }
    
    private func handleTouchEnd(_ touch: UITouch) {
        lastPosition = touch.location(in: self)
        if gameOverScreen{
            gameInfo.score = 0
            gameInfo.level = 0
            gameOverScreen = false
            levelClear()
            return
        }
        
        let deltaX = lastPosition.x - firstPosition.x
        let deltaY = lastPosition.y - firstPosition.y
        
        // hardcoded dead zone
        if sqrt((deltaX * deltaX + deltaY * deltaY)) < 35.0 {
            return
        }
        
        if deltaX > 0 && abs(deltaX) > abs(deltaY) {
            //print("Swipe right")
            yv = 0
            xv = 1
        } else if deltaX < 0 && abs(deltaX) > abs(deltaY) {
            //print("Swipe left")
            yv = 0
            xv = -1
        } else if deltaY > 0 && abs(deltaX) < abs(deltaY) {
            //print("Swipe up")
            yv = 1
            xv = 0
        } else if deltaY < 0 && abs(deltaX) < abs(deltaY) {
            //print("Swipe down")
            yv = -1
            xv = 0
        }

        var (currentX, currentY) = playerNode.getLoc()
        
        while currentX > 0 && currentY > 0 && currentX < self.gridSize + 1 && currentY < self.gridSize + 1 {
            currentX = currentX + xv
            currentY = currentY + yv
            
            if grid[currentX][currentY] {
                //print("DOT HIT | X: \(currentX) Y: \(currentY)")
                
                // remove dot
              
                grid[currentX][currentY] = false
                self.childNode(withName: "DotNode" + String(currentX) + " " + String(currentY))?
                    .removeFromParent()
                self.dotCount -= 1
                
                self.childNode(withName: "player")?.removeFromParent()
                playerNode = DOPlayerNode(
                    position: coordCalculate(indices: CGPoint(x: currentX, y: currentY)),
                    gridPosition: CGPoint(x: currentX, y: currentY))
                playerNode.name = "player"
                self.addChild(playerNode)
            
                // update score
                if (powerupNode != nil && powerupNode.isActive() && powerupNode.isDoubleDotScore()) {
                    gameInfo.score += 20
                }
                else {
                    gameInfo.score += 10
                }
                scoreNode.updateScore(with: gameInfo.score, mode: dotCount > 0 ? 1 : 0)
                break
            }
        }
        if currentX == 0 || currentY == 0 || currentX == self.gridSize + 1 || currentY == self.gridSize + 1 {
            //print("LEVEL RESET | X: \(currentX) Y: \(currentY)")
            powerupEligible = false
            if (modCode == 1) {
                gameOver()
            }
            else {
                levelLoad(restart: true)
            }
        }
        if dotCount == 0 {
            //print("LEVEL COMPLETE | X: \(currentX) Y: \(currentY)")
            levelLoad(restart: false)
            powerupEligible = true
        }
    }

    private func drawGrid(difficultyRating: Int, initX: Int, initY: Int) {
        
        var randomDifficulty = difficultyRating
        
        // uncomment to use difficulty range instead of set difficulty
        //let randomRange = 2
        //randomDifficulty = Int.random(in: (difficultyRating - randomRange)...(difficultyRating + randomRange), using: &rng)
        //print("Curr Difficulty: \(randomDifficulty)")
        dotCount = randomDifficulty
        randomDifficulty += 1
        var tempGrid = grid
        tempGrid[initX][initY] = true
        var currentX = initX
        var currentY = initY
        
        // vars to handle unsolvable levels
        var prevDir = -1
        let inverseDir = [1, 0, 3, 2]
        
        while randomDifficulty > 0 {
            let allDirections = Array(0..<4)
            var validDirections = allDirections
            if (prevDir >= 0) {
                validDirections = allDirections.filter { $0 != inverseDir[prevDir] }
            }
            let direction = validDirections.randomElement(using: &rng)!
            
            switch direction {
            case 0: // right
                if currentX < gridSize - 2 {
                    currentX += Int.random(in: 1...(gridSize - 1 - currentX), using: &rng)
                }
            case 1: // left
                if currentX > 1 {
                    currentX -= Int.random(in: 1...(currentX - 1), using: &rng)
                }
            case 2: // down
                if currentY < gridSize - 2 {
                    currentY += Int.random(in: 1...(gridSize - 1 - currentY), using: &rng)
                }
            case 3: // up
                if currentY > 1 {
                    currentY -= Int.random(in: 1...(currentY - 1), using: &rng)
                }
            default:
                break
            }

            
            if !tempGrid[currentX][currentY] {
                //print("X: \(currentX) Y: \(currentY)")
                tempGrid[currentX][currentY] = true
                if randomDifficulty == 1 {
                    placePlayer(at: (currentX, currentY), offsetX: offsetX, offsetY: offsetY)
                }
                else {
                    placeDot(at: (currentX, currentY), offsetX: offsetX, offsetY: offsetY)
                }
                
                randomDifficulty -= 1
                prevDir = direction
            }
        }
        
    }
    private func placeDot(at gridPosition: (Int, Int), offsetX: CGFloat, offsetY: CGFloat) {
        let (i, j) = gridPosition

        // calculate screen position from grid coordinates
        let xPosition = offsetX + CGFloat(i) * dotSpacing
        let yPosition = offsetY + CGFloat(j) * dotSpacing

        // create a dot and add it to the scene
        let dotNode = DODotNode(
            position: CGPoint(x: xPosition, y: yPosition), gridPosition: CGPoint(x: i, y: j))
        dotNode.name = "DotNode" + String(i) + " " + String(j)
        self.addChild(dotNode)
        self.grid[i][j] = true
    }

    private func placePlayer(at gridPosition: (Int, Int), offsetX: CGFloat, offsetY: CGFloat) {
        let (i, j) = gridPosition

        // calculate screen position from grid coordinates
        let xPosition = offsetX + CGFloat(i) * dotSpacing
        let yPosition = offsetY + CGFloat(j) * dotSpacing

        // create a player and add it to the scene
        playerNode = DOPlayerNode(
            position: CGPoint(x: xPosition, y: yPosition), gridPosition: CGPoint(x: i, y: j))
        playerNode.name = "player"
        self.addChild(playerNode)

    }

    private func showPowerupNotification() {
        // Remove existing notification
        powerupNotificationLabel?.removeFromParent()
        
        // Create notification at center
        let notification = SKLabelNode(fontNamed: "Arial")
        notification.fontSize = 20 // hardcode size
        notification.fontColor = .white
        
        switch powerupCurr {
        case .doubleDotScore:
            notification.text = "Powerup: 2X Score!"
        case .levelScoreBonus:
            notification.text = "Powerup: Level Bonus!"
        case .freezeTime:
            notification.text = "Powerup: Time Freeze!"
        default:
            return
        }
        notification.position = CGPoint(x: levelNode.getPosition().x , y: levelNode.getPosition().y - 40) // hardcoded constant
        notification.alpha = 0
        powerupNotificationLabel = notification
        addChild(notification)
        
        // Pop in animation
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.3)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        
        // Slide to corner while shrinking
        let moveToCorner = SKAction.move(to: powerupNode.getPosition(), duration: 0.5)
        let shrink = SKAction.scale(to: 0.5, duration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        
        // Combine animations
        let popIn = SKAction.group([scaleUp, fadeIn])
        let exitGroup = SKAction.group([moveToCorner, shrink, fadeOut])
        
        // Full sequence
        let sequence = SKAction.sequence([
            popIn,
            scaleDown,
            SKAction.wait(forDuration: 0.3),
            exitGroup,
            SKAction.removeFromParent()
        ])
        
        notification.run(sequence)
    }

    private func showModNotification(code: Int) {
        // Remove existing notification
        modNotificationLabel?.removeFromParent()
        
        // Create notification above timer
        let notification = SKLabelNode(fontNamed: "Arial")
        notification.fontSize = 20
        notification.fontColor = .white
        
        // Set text based on mod code
        switch code {
        case 0:
            notification.text = "Challenge: Exploding Timer!"
        case 1:
            notification.text = "Challenge: Sudden Death!"
        case 2:
            notification.text = "Challenge: Double Difficulty!"
        default:
            return // Don't show notification for invalid codes
        }
        
        // Position centered above timer
        notification.position = (CGPoint(x: size.width / 2, y: size.height / 5 + 40))
        notification.alpha = 0
        modNotificationLabel = notification
        addChild(notification)
        
        
        // Pop in animation
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.3)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        
        // Pop out animation
        let popOut = SKAction.scale(to: 0.8, duration: 0.3)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        
        // Combine animations
        let popIn = SKAction.group([scaleUp, fadeIn])
        let exitGroup = SKAction.group([popOut, fadeOut])
        
        // Full sequence
        let sequence = SKAction.sequence([
            popIn,
            scaleDown,
            SKAction.wait(forDuration: 1.0),
            exitGroup,
            SKAction.removeFromParent()
        ])
        
        notification.run(sequence)
    }

    func gameOver() {
        self.removeAllChildren()
        // gameOverNode.updateMessage()
        addChild(gameOverNode)
        gameOverScreen=true
        
        gameInfo.score = 0
        gameInfo.level = 0
    }

    //this seems to be a useless duplicate of levelload
    func levelClear() {
        
        levelTransition()
        gameInfo.level += 1
        levelNode.updateLevel(with: gameInfo.level)
       
        grid = Array(repeating: Array(repeating: false, count: self.gridSize + 2), count: self.gridSize + 2)
        drawGrid(difficultyRating: difficulty, initX: 6, initY: 6)
    }
    func levelTransition(){
        let playerTransition1 = SKAction.moveBy(x: 0, y: UIScreen.main.bounds.size.height - playerNode.position.y, duration: 2.0)
        playerNode.run(playerTransition1)
        self.removeAllChildren()
        addChild(backgroundNode)
        addChild(scoreNode)
        addChild(levelNode)
    
    }
    func levelLoad(restart: Bool) {
        if !restart, let explodingTimer = explodingTimer {
            explodingTimer.removeFromParent()
            self.explodingTimer = nil
        }
        // remove all dots and players from the scene
        //levelTransition()
        if (!restart){
            //print("animation should start")
            let playerTransition1 = SKAction.moveBy(x: 0, y: UIScreen.main.bounds.size.height - playerNode.position.y + 10, duration: 2.0)
            playerNode.run(playerTransition1){
                //print("kjlsadkfa")
            }
        }
        for child in self.children {
            if let dotNodeD = child as? DODotNode {
                dotNodeD.removeFromParent()
                //print("Dot removed")
            }
            if let dotNodeD = child as? DOPlayerNode {
                dotNodeD.removeFromParent()
                //print("Player removed")
            }
        }
        // if we are not restarting, we go to the next level
        if (!restart) {
            backgroundNode.setDeterminedTexture(id: theme, secret: false)
            gameInfo.level += 1
            
            if (gameInfo.level % 1 == 0) { // gradually increase difficulty every 6 levels //TEST
                difficulty += 1
            }
            if (powerupNode != nil && powerupNode.isActive() && powerupNode.islevelScoreBonus()) {
                gameInfo.score += 150
            }
            else {
                gameInfo.score += 100
            }
            timerNode.addTime(bonusTime)
        }
        levelNode.updateLevel(with: gameInfo.level)
        if (powerupNode != nil && powerupNode.isActive() && powerupNode.islevelScoreBonus()) {
            scoreNode.updateScore(with: gameInfo.score, mode: 2)
        }
        else {
            scoreNode.updateScore(with: gameInfo.score, mode: 1)
        }

        // clear the grid
        grid = Array(
            repeating: Array(repeating: false, count: self.gridSize + 2),
            count: self.gridSize + 2
        )
        
        if gameInfo.level % modInterval == 0 && !restart {
            modCode = Int.random(in: 0...2) // random inclusive
            showModNotification(code: modCode ?? -1)
            //print("Modifier Active: modCode = \(modCode!)")
        } else if gameInfo.level % modInterval != 0 {
            modCode = nil // Clear the modifier
            //print("No Modifier Active")
        }
        
        if (modCode == 0 && !restart) {
            explodingTimer = DOExplodingTimerNode(initialTime: bonusTime)
            explodingTimer.setPosition(CGPoint(x: size.width / 2, y: size.height / 6))
            addChild(explodingTimer)
        }
        
        // mod: double difficulty
        if (modCode == 2) {
            drawGrid(difficultyRating: difficulty * 2, initX: 6, initY: 6)
        }
        else {
            drawGrid(difficultyRating: difficulty, initX: 6, initY: 6)
        }
        if (powerupEligible) {print("powerUpEligible")}
        if powerupNode == nil || !powerupNode.isActive() {print("No Powerup Active")}
        if powerupEligible && (powerupNode == nil || !powerupNode.isActive()) {
            let powerUpNodeRadius: CGFloat = 20
            let position = CGPoint(x: powerUpNodeRadius + 15, y: size.height - powerUpNodeRadius - 70)
            powerupCurr = powerupTypes.randomElement(using: &rng)!
            //print("Powerup gained: \(powerupCurr)")
            powerupNode = DOPowerUpNode(radius: powerupRadius, type: powerupCurr, position: position)
            addChild(powerupNode!)
            showPowerupNotification()
        }
        if let existingPowerup = powerupNode, !existingPowerup.isActive() {
            existingPowerup.removeFromParent()
            powerupCurr = .inactive
            powerupNode = nil
        }
    }
    
    // translates matrix index to position on screen
    func coordCalculate(indices: CGPoint) -> CGPoint {
        return CGPoint(
            x: offsetX + CGFloat(indices.x) * dotSpacing,
            y: offsetY + CGFloat(indices.y) * dotSpacing)
    }

    func didBegin(_ contact: SKPhysicsContact) {
        //print("Dot has collided with another body!")
    }
}
