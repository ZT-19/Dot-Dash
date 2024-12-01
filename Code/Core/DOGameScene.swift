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
    private var baseGrid = DOGameContext.shared.grid
    private let dotSpacing = DOGameContext.shared.dotSpacing
    private let gridSize = DOGameContext.shared.gridSize
    private let gridCenter = DOGameContext.shared.gridCenter
    private var offsetX: CGFloat = 0
    private var offsetY: CGFloat = 0
    private var difficulty = 1
    private var dotCount: Int = 0
    
    var rng = SystemRandomNumberGenerator()
    let backgroundNode = DOBackgroundNode()
    let scoreNode = DOScoreNode()
    let levelNode = DOLevelNode()
    let gameOverNode = DOGameOverNode()
    var playerNode = DOPlayerNode()
    private var gameInfo = DOGameInfo()
    private var gameOverScreen = false
    
    // player position
    private var lastPosition: CGPoint = .zero
    private var firstPosition: CGPoint = .zero
    private var xv: Int = .zero
    private var yv: Int = .zero
    private var isPlayerAnimating = false
    private var queuedLevelLoad: (Bool, Bool, Bool)? // restart, powerup, active

    
    // timer
    private var initialTime: TimeInterval = 9020
    private var bonusTime = 10.0
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
        backgroundNode.zPosition = -CGFloat.greatestFiniteMagnitude // hardcoded to the back layer
        addChild(backgroundNode)

        scoreNode.setup(screenSize: size)
        addChild(scoreNode)

        levelNode.setup(screenSize: size)
        addChild(levelNode)

        // center grid on screen and draw it
        let gridWidth = CGFloat(gridSize) * dotSpacing
        offsetX = (max(30, (size.width - gridWidth) / 2))/3
        offsetY = max(30, (size.height - gridWidth) / 2)
        
        // clear grid
        grid = Array(
            repeating: Array(repeating: 0, count: self.gridSize + 2),
            count: self.gridSize + 2
        )
        // initialize first level
        grid = drawGridArray(difficultyRating: difficulty, initX: gridCenter, initY: gridCenter)
        baseGrid = grid
        placeDotsFromGrid(grid: grid)
        
        // setup timer node
        timerNode = DOTimerNode(initialTime: initialTime)
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
        if let existingPowerup = powerupNode, !existingPowerup.isActive() {
            existingPowerup.removeFromParent()
            if existingPowerup.isFreezeTime(){
                timerNode.addTime(existingPowerup.getTimeStart(), stealth: true)
            }
            powerupCurr = .inactive
            powerupNode = nil
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
            
         
            let startPoint = coordCalculate(indices: CGPoint(x: currentX - xv, y: currentY - yv))
            let endPoint = coordCalculate(indices: CGPoint(x: currentX, y: currentY))
            self.addChild(DOTrailNode(position: endPoint,
                                         vertical: xv == 0,
                                         startPoint: startPoint))
          
            
            
            if grid[currentX][currentY] == 1 {
                let newPlayerPosition = coordCalculate(indices: CGPoint(x: currentX, y: currentY))
                let slideAction = SKAction.move(to: newPlayerPosition, duration: 0.2)
                slideAction.timingMode = .easeOut
                
                isPlayerAnimating = true
                
                playerNode.gridX = currentX
                playerNode.gridY = currentY

                playerNode.run(slideAction) { [weak self] in
                    guard let self = self else { return }
                    self.isPlayerAnimating = false
                    
                    // Execute queued level load if exists
                    if let (restart, eligible, _) = self.queuedLevelLoad {
                        self.queuedLevelLoad = nil
                        
                        self.levelLoad(restart: restart,powerupEligible: eligible)
                        
                    }
                }
                
                // remove dot
                grid[currentX][currentY] = 0
                let onnode:DODotNode = self.childNode(withName: "DotNode" + String(currentX) + " " + String(currentY))! as! DODotNode
                onnode.destroySelf()// since we're pretty sure its a dot node
                
                   
                self.dotCount -= 1
            
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
            for child in children { // no trails on invalid moves
                if child is DOTrailNode {
                    child.removeFromParent()
                }
            }
            if yv == 0 && xv == 1 {
                // slide right offscreen
                let rightEdge = UIScreen.main.bounds.width + playerNode.frame.width
                let slideRight = SKAction.moveTo(x: rightEdge, duration: 0.25)
                slideRight.timingMode = .easeIn
                isPlayerAnimating = true
                playerNode.run(slideRight) { [weak self] in
                    guard let self = self else { return }
                    self.isPlayerAnimating = false
                    if let (restart, eligible, _) = self.queuedLevelLoad {
                        self.queuedLevelLoad = nil
                        
                        self.levelLoad(restart: restart,powerupEligible: eligible)
                        
                    }
                }
            }
            else if yv == 0 && xv == -1 {
                // slide left offscreen
                let leftEdge = -playerNode.frame.width
                let slideLeft = SKAction.moveTo(x: leftEdge, duration: 0.25)
                slideLeft.timingMode = .easeIn
                isPlayerAnimating = true
                playerNode.run(slideLeft) { [weak self] in
                    guard let self = self else { return }
                    self.isPlayerAnimating = false
                    if let (restart, eligible, _) = self.queuedLevelLoad {
                        self.queuedLevelLoad = nil
                        
                        self.levelLoad(restart: restart,powerupEligible: eligible)
                        
                    }
                }
            }
            else if yv == 1 && xv == 0 {
                // Slide up offscreen
                let topEdge = UIScreen.main.bounds.height + playerNode.frame.height
                let slideUp = SKAction.moveTo(y: topEdge, duration: 0.25)
                slideUp.timingMode = .easeIn
                isPlayerAnimating = true
                playerNode.run(slideUp) { [weak self] in
                    guard let self = self else { return }
                    self.isPlayerAnimating = false
                    if let (restart, eligible, _) = self.queuedLevelLoad {
                        self.queuedLevelLoad = nil
                        
                        self.levelLoad(restart: restart,powerupEligible: eligible)
                        
                    }
                }
            }
            else if yv == -1 && xv == 0 {
                // slide down offscreen
                let bottomEdge = -playerNode.frame.height
                let slideDown = SKAction.moveTo(y: bottomEdge, duration: 0.25)
                slideDown.timingMode = .easeIn
                isPlayerAnimating = true
                playerNode.run(slideDown) { [weak self] in
                    guard let self = self else { return }
                    self.isPlayerAnimating = false
                    if let (restart, eligible, _) = self.queuedLevelLoad {
                        self.queuedLevelLoad = nil
                        
                        self.levelLoad(restart: restart,powerupEligible: eligible)
                        
                    }
                }
            }
            
            powerupEligible = false
           
            if (modCode == 1) {
                gameOver()
            }
            else {
              
                levelLoad(restart: true,powerupEligible: powerupEligible)
            }
        }
        else if dotCount == 0 {
            //print("LEVEL COMPLETE | X: \(currentX) Y: \(currentY)")
           
            levelLoad(restart: false,powerupEligible: powerupEligible)
            powerupEligible = true
            
        }
    }
    
    private func drawGridArray(difficultyRating: Int, initX: Int, initY: Int) -> [[Int]] {
        var randomDifficulty = difficultyRating
        var tempGrid = Array(repeating: Array(repeating: 0, count: gridSize + 2), count: gridSize + 2)
        
        // uncomment below to use difficulty range instead of set difficulty
        /*
        let randomRange = 2
        randomDifficulty = Int.random(in: (difficultyRating - randomRange)...(difficultyRating + randomRange), using: &rng)
        print("Curr Difficulty: \(randomDifficulty)")
        */
        
        var currentX = initX
        var currentY = initY
        tempGrid[initX][initY] = 1 // first dot
        
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
            var changeAmount:Int = 0
            var newX = currentX,newY=currentY
            switch direction {
            case 0: // right
                if currentX < gridSize - 2 {
                    changeAmount = Int.random(in: 1...(gridSize - 1 - currentX), using: &rng)
                    newX += changeAmount
                    break
                }
            case 1: // left
                if currentX > 1 {
                    changeAmount = Int.random(in: 1...(currentX - 1), using: &rng)
                    newX -= changeAmount
                    break
                }
            case 2: // down
                if currentY < gridSize - 2 {
                    changeAmount = Int.random(in: 1...(gridSize - 1 - currentY), using: &rng)
                    newY += changeAmount
                    break
                }
            case 3: // up
                if currentY > 1 {
                    changeAmount = Int.random(in: 1...(currentY - 1), using: &rng)
                    newY -= changeAmount
                    break
                }
            default:
                break
            }
            
            if tempGrid[newX][newY] == 0 {
                if randomDifficulty == 1 {
                    tempGrid[newX][newY] = 2 // last dot is player position
                } else {
                    tempGrid[newX][newY] = 1 // dot position
                }
                randomDifficulty -= 1
                prevDir = direction
                currentX=newX // only update position if the new spot is valid
                currentY=newY
            }
           
            
            
        }
        
        return tempGrid
    }
    private func placeDotsFromGrid(grid: [[Int]]) {
        dotCount = 0
        
        for i in 1...gridSize {
            for j in 1...gridSize {
                switch grid[i][j] {
                case 1: // dot
                    addDot(at: (i, j), offsetX: offsetX, offsetY: offsetY)
                    dotCount += 1
                case 2: // player
                    addPlayer(at: (i, j), offsetX: offsetX, offsetY: offsetY)
                default:
                    continue
                }
            }
        }
    }

    private func addDot(at gridPosition: (Int, Int), offsetX: CGFloat, offsetY: CGFloat) {
        let (i, j) = gridPosition

        // calculate screen position from grid coordinates
        let xPosition = offsetX + CGFloat(i) * dotSpacing
        let yPosition = offsetY + CGFloat(j) * dotSpacing

        // create a dot and add it to the scene
        let dotNode = DODotNode(
            position: CGPoint(x: xPosition, y: yPosition), gridPosition: CGPoint(x: i, y: j))
        dotNode.name = "DotNode" + String(i) + " " + String(j)
        self.addChild(dotNode)
    }

    private func addPlayer(at gridPosition: (Int, Int), offsetX: CGFloat, offsetY: CGFloat) {
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
        // remove any existing notification
        powerupNotificationLabel?.removeFromParent()
        
        // create notification at center
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
        
        // pop-in animation
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.3)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        
        // slide to corner while shrinking
        let moveToCorner = SKAction.move(to: powerupNode.getPosition(), duration: 0.5)
        let shrink = SKAction.scale(to: 0.5, duration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        
        // combine pop-in and slide animations
        let popIn = SKAction.group([scaleUp, fadeIn])
        let exitGroup = SKAction.group([moveToCorner, shrink, fadeOut])
        
        // build and run full sequence
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
        // remove any existing notification
        modNotificationLabel?.removeFromParent()
        
        // create notification above timer
        let notification = SKLabelNode(fontNamed: "Arial")
        notification.fontSize = 20
        notification.fontColor = .white
        
        // set modifier(challenge) text based on mod code
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
        
        // position centered above timer
        notification.position = (CGPoint(x: size.width / 2, y: size.height / 5 + 40))
        notification.alpha = 0
        modNotificationLabel = notification
        addChild(notification)
        
        
        // pop-in animation
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.3)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        
        // pop-out animation
        let popOut = SKAction.scale(to: 0.8, duration: 0.3)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        
        // combine pop-in and pop-out animations
        let popIn = SKAction.group([scaleUp, fadeIn])
        let exitGroup = SKAction.group([popOut, fadeOut])
        
        // build and run full sequence
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
    }
    
    func levelTransition(){
        let playerTransition1 = SKAction.moveBy(x: 0, y: UIScreen.main.bounds.size.height - playerNode.position.y, duration: 2.0)
        playerNode.run(playerTransition1)
        self.removeAllChildren()
        addChild(backgroundNode)
        addChild(scoreNode)
        addChild(levelNode)
    }
    
    func levelLoad(restart: Bool, powerupEligible:Bool = true) {
       
       
        if isPlayerAnimating {
            queuedLevelLoad = (restart, powerupEligible ,true)
            return
        }
        
        if !restart, let explodingTimer = explodingTimer {
            explodingTimer.removeFromParent()
            self.explodingTimer = nil
        }
        
        // remove all dots and players from the scene
        for child in self.children {
            if let dotNodeD = child as? DODotNode {
                dotNodeD.removeFromParent()
                //print("Dot removed")
            }
            if let dotNodeD = child as? DOPlayerNode {
                dotNodeD.removeFromParent()
                //print("Player removed")
            }
            if let trailNode = child as? DOTrailNode{
                trailNode.removeFromParent()
                
            }
        }
        // if we are not restarting, we go to the next level
        if (!restart) {
            backgroundNode.setDeterminedTexture()
            gameInfo.level += 1
            
            difficulty += 1 // constant increase every lvl
            // if (gameInfo.level % 6 == 0) {  difficulty += 1 } // gradually increase difficulty every 6 lvls
            
            if (powerupNode != nil && powerupNode.isActive() && powerupNode.islevelScoreBonus()) { // bonus level score powerup
                gameInfo.score += 150
            }
            else {
                gameInfo.score += 100
            }
            
            timerNode.addTime(bonusTime)
            
            // draw new 2D Int Array for new level
            if (modCode == 2) { // mod: double difficulty
                grid = drawGridArray(difficultyRating: difficulty * 2, initX: gridCenter, initY: gridCenter)
                baseGrid = grid
            }
            else {
                grid = drawGridArray(difficultyRating: difficulty, initX: gridCenter, initY: gridCenter)
                baseGrid = grid
            }
            
        }
        else {
            grid = baseGrid
        }
        levelNode.updateLevel(with: gameInfo.level)
        
        if (powerupNode != nil && powerupNode.isActive() && powerupNode.islevelScoreBonus() && !restart) { // double dot score powerup
            scoreNode.updateScore(with: gameInfo.score, mode: 2)
        }
        else {
            scoreNode.updateScore(with: gameInfo.score, mode: 1)
        }
        
        if (modCode == 0 && !restart) {
            explodingTimer = DOExplodingTimerNode(initialTime: bonusTime)
            explodingTimer.setPosition(CGPoint(x: size.width / 2, y: size.height / 6))
            addChild(explodingTimer)
        }
        
        placeDotsFromGrid(grid: grid) // place player and dots from 2D integer array

        if powerupEligible && (powerupNode == nil || !powerupNode.isActive()) {
            
            let powerUpNodeRadius: CGFloat = 20
            let position = CGPoint(x: powerUpNodeRadius + 15, y: size.height - powerUpNodeRadius - 70)
            powerupCurr = powerupTypes.randomElement(using: &rng)!
        
            powerupNode = DOPowerUpNode(radius: powerupRadius, type: powerupCurr, position: position)
           
            addChild(powerupNode!)
            showPowerupNotification()
            //print("Powerup gained: \(powerupCurr)")
           
        }
       
     
      
    }
    
    // translates matrix index to position on screen
    func coordCalculate(indices: CGPoint) -> CGPoint {
        return CGPoint(
            x: offsetX + CGFloat(indices.x) * dotSpacing,
            y: offsetY + CGFloat(indices.y) * dotSpacing)
    }
}
