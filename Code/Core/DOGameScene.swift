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
    private var gridSize = DOGameContext.shared.gridSize
    private let gridCenter = DOGameContext.shared.gridCenter
    private var powerUpArray = DOGameContext.shared.powerUpArray
    private let playableYTop = 620.0 / 874.0 * UIScreen.main.bounds.height // below the level count. All these values are scaled to 0,0 anchor
    private let playableYBottom = 140.0 / 874.0 * UIScreen.main.bounds.height// above all powerups.
    private let playableXLeft = 15.0 / 402.0 *  UIScreen.main.bounds.width// below the level count
    private let playableXRight = 397.0  / 402.0 *  UIScreen.main.bounds.width // above all powerups.
    private var playableXSize:Double = 1.00 // right-left ,will be set in didmove
    private var playableYSize:Double = 10.0// top - bottom will be set in didmove
    private var dotSpacingX: Double = 69 // temporary value, changes depending on gridsize
    private var dotSpacingY: Double = 420 // temporary value, changes depending on gridsize,
  
    private var offsetX: CGFloat = 0
    private var offsetY: CGFloat = 0
    private var difficulty = 1
    private var dotCount: Int = 0
    
    var rng = SystemRandomNumberGenerator()
    let backgroundNode = DOBackgroundNode()
    //let scoreNode = DOScoreNode()
    let levelNode = DOLevelNode()
    let gameOverNode = DOGameOverNode()
    let frameNode = DOFrameNode()
    var playerNode = DOPlayerNode()
    var playerstart = DOplayerStart()
    private var gameInfo = DOGameInfo()
    private var gameOverScreen = false
    private var isTouchEnabled = true
    
    // player position
    private var lastPosition: CGPoint = .zero
    private var firstPosition: CGPoint = .zero
    private var xv: Int = .zero
    private var yv: Int = .zero
    private var isPlayerAnimating = false
    private var queuedLevelLoad: (Bool, Bool, Bool)? // restart, powerup, active

    
    // timer
    private var initialTime: TimeInterval = 20
    private var bonusTime = 10.0
    private let levelTransitionTime = 0.7
    private var timerNode: DOTimer!
    private var progressBar: DOProgressBarNode!
    //private var explodingTimer: DOExplodingTimerNode!
    
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
    private let powerupRadius = 45.0 / 402.0 *  UIScreen.main.bounds.width
    let powerUpNodeRadius: CGFloat = 68 / 402.0 *  UIScreen.main.bounds.width

    private let powerupTypes: [PowerUpType] = [
    //    .doubleDotScore,
    //    .levelScoreBonus,
        .freezeTime,
      //  .extraSlot,
        .skipLevel,
    ]
    private var powerupEligible = true
    private var powerupNotificationLabel: SKLabelNode?
    private var powerupCurr = PowerUpType.freezeTime
    private var n_powerups = 0
    private var max_powerUps = 3

    private var inIntermission = false
    private var firstFreeze = true
    private var firstSkip = true
    private var firstFail = true
    private var onscreentext: DOExplanationNode!
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .gray
        self.physicsWorld.contactDelegate = self
        
        print(size.height)
        print(size.width)
        playableXSize = playableXRight-playableXLeft
        playableYSize = playableYTop-playableYBottom
        
        backgroundNode.setup(screenSize: size)
        gameOverNode.setup(screenSize: size)
        progressBar = DOProgressBarNode(size: CGSize(width: UIScreen.main.bounds.width*0.5, height: 30))
        progressBar.setup(screenSize: size)
        frameNode.setup(screenSize: CGSize(width: size.width+1, height: size.height))
        
        addChild(backgroundNode)
        addChild(frameNode)
        addChild(progressBar)
        onscreentext = DOExplanationNode(size:size)
        
        

     //   scoreNode.setup(screenSize: size)
       // addChild(scoreNode)

        levelNode.setup(screenSize: size)
        addChild(levelNode)
     
        dotSpacingX = (playableXSize)/Double(gridSize+1)
        dotSpacingY = (playableYSize)/Double(gridSize+1)
        // center grid on screen and draw it
        let gridWidth = CGFloat(gridSize) * dotSpacingX
        offsetX = playableXLeft - 3 / 402.0 *  UIScreen.main.bounds.width
        offsetY = playableYBottom + 58 / 874.0 * UIScreen.main.bounds.height
        
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
        timerNode = DOTimer(radius: 30, levelTime: 20) { [weak self] in
            // Timer setup completed callback if needed
            //self?.gameOver()
        }
        timerNode.position = CGPoint(x: size.width / 2, y: size.height - size.height / 8)
        addChild(timerNode)
        timerNode.start()//WK
        
        print(playableYTop)
        print(playableYBottom)
        
        backgroundNode.zPosition = -CGFloat.greatestFiniteMagnitude // hardcoded to the back layer
        frameNode.zPosition = 5
        timerNode.zPosition = 6
        progressBar.zPosition = 6
        levelNode.zPosition = 6
        
        intermission(code: 0)
    }
    
    override func update(_ currentTime: TimeInterval) {
       
        
        if let timer = timerNode, timer.parent != nil {
                if timer.timeLeft() <= 0 {
                    gameOver()
                }
            }
      /*
        if let explodingTimer = explodingTimer {
            if !(powerupNode != nil && powerupNode.isFreezeTime() && powerupNode.isActive()) {
                if explodingTimer.update(currentTime) {
                    gameOver()
                }
            }
        }
       */
        for i in 0..<n_powerups{
            if let existingPowerup = powerUpArray[i], existingPowerup.isSpent() {
                //existingPowerup.removeFromParent()
                if existingPowerup.isFreezeTime(){
                    var frozen = false
                    for j in 0..<n_powerups{
                        if (i != j && powerUpArray[j] != nil && powerUpArray[j]!.isFreezeTime() && powerUpArray[j]!.isActive()) {
                            frozen = true
                           
                        }
                       
                    }
                 //   timerNode.addTime(existingPowerup.getTimeStart(),stealth: true)
                    if !frozen{
                        timerNode.resume()
                    }
                    
                }
                /* currently disabled feature
                if existingPowerup.isExtraSlot(){
                    max_powerUps += 1
                }
                 */
                powerupCurr = .inactive
                
                for j in i+1..<n_powerups{
                    powerUpArray[j]?.position.x -= (UIScreen.main.bounds.width/2 - powerUpNodeRadius)
                    powerUpArray.swapAt(j, j-1)
                    powerUpArray[j-1]?.fadeIn()
                    
                }
                powerUpArray[n_powerups-1] = nil
                n_powerups -= 1
              //  if existingPowerup.isSkipLevel(){
                    
                   // levelLoad(restart: false,powerupEligible: false,skipped: true) // had to comment this out for  a scuffed
                    
               // }
                
            }
            
        }
        if progressBar.getProgress() == 1.0 && n_powerups < max_powerUps  {
            addPowerUp()
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
            return
        }
        if !isTouchEnabled{
            lastPosition = CGPoint(x: -1, y: -1)
            return
        }
        /*
        if gameOverScreen{
            gameInfo.score = 0
            gameInfo.level = 0
            gameOverScreen = false
            levelClear()
            print("You lost but what happens now")
            return
        }
         */
        if inIntermission{
            onscreentext.resetText()
            onscreentext.removeFromParent()
            timerNode.resume()
            inIntermission = false
            return
            
        }
        for i in 0..<n_powerups{
            if let cpow = powerUpArray[i]{
                if (lastPosition.x <= ((cpow.position.x)+CGFloat(powerupRadius))&&lastPosition.x >= (cpow.position.x-powerupRadius)&&lastPosition.y <= (cpow.position.y+powerupRadius)&&lastPosition.y >= (cpow.position.y-powerupRadius) && firstPosition.x <= ((cpow.position.x)+CGFloat(powerupRadius))&&firstPosition.x >= (cpow.position.x-powerupRadius)&&firstPosition.y <= (cpow.position.y+powerupRadius)&&firstPosition.y >= (cpow.position.y-powerupRadius) && !cpow.isActive() && !isPlayerAnimating){
                        
                        cpow.startCountdown()
                
                 
                        if (cpow.isFreezeTime()){
                            timerNode.pause()
                            print("freezenode actiavted")
                        }
                    else{
                        levelLoad(restart: false)
                    }
                    print("poweurp used")
                    return
                }
            }
           
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
            if xv==0{
                self.addChild(DOTrailNode(position: endPoint,
                                             vertical: xv == 0,
                                          startPoint: startPoint, size:CGSize(width: dotSpacingX/4, height: dotSpacingY))) // height is argument for length, width for width
            }
            else{
                self.addChild(DOTrailNode(position: endPoint,
                                             vertical: xv == 0,
                                          startPoint: startPoint, size:CGSize(width: dotSpacingY/4, height: dotSpacingX)))
            }
            
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
                
                //let doublefactor = 1
                /* double score powerup
                for i in 0..<n_powerups{
                    if (powerUpArray[i] != nil && powerUpArray[i]!.isActive() && powerUpArray[i]!.isDoubleDotScore()) {
                        doublefactor *= 2
                    }
                // double score powerups stack
                }
                 */
                //gameInfo.score += 10 * doublefactor
                
                //scoreNode.updateScore(with: gameInfo.score, mode: dotCount > 0 ? 1 : 0)
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
        
        var currentX = initX
        var currentY = initY

        tempGrid[initX][initY] = 2 // first location is player

        
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
            var newX = currentX, newY=currentY
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
                tempGrid[newX][newY] = 1
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
       // let xPosition = offsetX + CGFloat(i) * dotSpacingX
       // let yPosition = offsetY + CGFloat(j) * dotSpacingY

        // create a dot and add it to the scene
        let dotNode = DODotNode(size: CGSize(width:dotSpacingX * 0.8,height: dotSpacingY*0.8),
            position: coordCalculate(indices: CGPoint(x: i,y: j)), gridPosition: CGPoint(x: i, y: j))
        dotNode.name = "DotNode" + String(i) + " " + String(j)
        self.addChild(dotNode)
    }

    private func addPlayer(at gridPosition: (Int, Int), offsetX: CGFloat, offsetY: CGFloat) {
        let (i, j) = gridPosition

        // calculate screen position from grid coordinates
       // let xPosition = offsetX + CGFloat(i) * dotSpacingX
       // let yPosition = offsetY + CGFloat(j) * dotSpacingY

        // create a player and add it to the scene
        playerNode = DOPlayerNode(size: CGSize(width:dotSpacingX * 0.8,height: dotSpacingY*0.8),
            position:coordCalculate(indices: CGPoint(x: i,y: j)), gridPosition: CGPoint(x: i, y: j))
        playerstart = DOplayerStart(size: CGSize(width:dotSpacingX * 0.4,height: dotSpacingX*0.4), position: coordCalculate(indices: CGPoint(x: i,y: j)))
       
        self.addChild(playerstart)
        
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
            /*
        case .doubleDotScore:
            notification.text = "Powerup: 2X Score!"
        case .levelScoreBonus:
            notification.text = "Powerup: Level Bonus!"
        case .extraSlot:
            notification.text = "Powerup: Extra Powerup Slot!"
             */
        case .skipLevel:
            notification.text = "Powerup: Level Skip!"
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
        let moveToCorner = SKAction.move(to: powerUpArray[n_powerups]!.getPosition(), duration: 0.5)
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
    private func difficultyToTime(_ level: Int) -> Int {
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
        print(cnt)
            return Int(cnt)
    }
    func intermission(code: Int){
        // 0 for basic tutorial, 1 for first freeze, 2 for first level skip
        inIntermission=true
        timerNode.pause()
        print("intermission pause")
        onscreentext.updateText(code: code)
        addChild(onscreentext)
        
    }
    func gameOver() {
        self.gameOverScreen=true
        var removeCount = 0.0
        let nodes = self.children // Get all nodes in the scene
        for (index, node) in nodes.enumerated() {
            if (node is DOPlayerNode) || (node is DODotNode){
                if let dotnode = node as? DODotNode{
                    if !dotnode.destroyed{
                        removeCount += 1 // only fade away still alive pieces
                    }
                }
                else{
                    removeCount += 1
                }
                
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 * removeCount + 0.5) {
            self.removeAllChildren()
            // gameOverNode.updateMessage()
            self.addChild(self.gameOverNode)
            
            
            self.gameInfo.score = 0
            self.gameInfo.level = 0
            print("game over")
        }
            
        for (index, node) in nodes.enumerated() {
            if !(node is DOPlayerNode) && !(node is DODotNode){
                    continue
            }
            
            if let dotnode2 = node as? DODotNode{
                if dotnode2.destroyed{
                    continue
                }
            }
          //  print(node.position)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 * removeCount) {
                let scaleAction = SKAction.fadeOut(withDuration: 0.2)
                
                // Optional: Add easing for smoother animation
                scaleAction.timingMode = .easeOut
                
                node.run(scaleAction)
                
            }
            removeCount -= 1
                
        }
        
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
      //  addChild(scoreNode)
        addChild(levelNode)
    }
    
    func addPowerUp(){
        if n_powerups>=max_powerUps{
            return
        }
        var x_powerUp_position = powerUpNodeRadius
        x_powerUp_position += (UIScreen.main.bounds.width/2 - powerUpNodeRadius) * CGFloat(n_powerups)
        
       
        let position = CGPoint(x:x_powerUp_position, y: powerUpNodeRadius + 75 / 874.0 * UIScreen.main.bounds.height )
        powerupCurr = powerupTypes.randomElement(using: &rng)!
        /*
        while(max_powerUps>=actual_max_powerUps && powerupCurr==PowerUpType.extraSlot){
            powerupCurr = powerupTypes.randomElement(using: &rng)!
        }
         */
        powerUpArray[self.n_powerups] = DOPowerUpNode(radius: powerupRadius, type: powerupCurr, position: position)
        powerUpArray[self.n_powerups]?.zPosition = 5
        addChild(powerUpArray[self.n_powerups]!)
        showPowerupNotification()
        //print("Powerup gained: \(powerupCurr)")
        n_powerups += 1
        progressBar.setProgress(0.0)
        if (firstSkip && powerupCurr == .skipLevel){
            intermission(code: 2)
            firstSkip = false
        }
        else if (firstFreeze && powerupCurr == .freezeTime){
            intermission(code: 1)
            firstFreeze = false
        }
    }
    
    func levelLoad(restart: Bool, powerupEligible:Bool = true, skipped:Bool = false) {
       
       
        if isPlayerAnimating {
            queuedLevelLoad = (restart, powerupEligible ,true)
            return
        }
        /*
        if !restart, let explodingTimer = explodingTimer {
            explodingTimer.removeFromParent()
            self.explodingTimer = nil
        }
         */
        
        // remove all dots and players from the scene
        isTouchEnabled = false
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
        playerstart.removeFromParent()
        // if we are not restarting, we go to the next level
        if (!restart) {
            if gridSize<13 && difficulty%2==1{
                gridSize += 1
                backgroundNode.changeGridSize(new: gridSize)
            }
            
            dotSpacingX = (playableXSize)/Double(gridSize+1)
            dotSpacingY = (playableYSize)/Double(gridSize+1)
            backgroundNode.setDeterminedTexture()
            
            gameInfo.level += 1
           
            difficulty += 1 // constant increase every lvl
           
            // if (gameInfo.level % 6 == 0) {  difficulty += 1 } // gradually increase difficulty every 6 lvls
            let leveBonusMultiplier = 1.0
            /*
            for i in 0..<n_powerups{
                if (powerUpArray[i] != nil && powerUpArray[i]!.isActive() && powerUpArray[i]!.islevelScoreBonus()) {// bonus level score powerup
                    leveBonusMultiplier *= 1.5
                }
            
            }
           */

            gameInfo.score += Int(100 * leveBonusMultiplier)
            
     
                timerNode.resetTimer(timeLeft: difficultyToTime(difficulty))
                
            timerNode.pause()
           
            
            
           
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
            if firstFail{
                firstFail = false
                intermission(code: 3)
                
            }
        }
        
        levelNode.updateLevel(with: gameInfo.level)
        
        //var bonusApplied = false
        /*
        for i in 0..<n_powerups{
            if (powerUpArray[i] != nil && powerUpArray[i]!.isActive() && powerUpArray[i]!.islevelScoreBonus()) {
                bonusApplied = true
                scoreNode.updateScore(with: gameInfo.score, mode: 2)
                break
            }
        // double score powerups stack
        }
         
        if !bonusApplied{
            scoreNode.updateScore(with: gameInfo.score, mode: 1)
        }
        
         */
        /*
        if (modCode == 0 && !restart) {
            explodingTimer = DOExplodingTimerNode(initialTime: bonusTime)
            explodingTimer.setPosition(CGPoint(x: size.width / 2, y: size.height / 6))
            addChild(explodingTimer)
        }
         */
        var waitForTransition = levelTransitionTime
        if restart{
            waitForTransition = 0.0
        }
     

        DispatchQueue.main.asyncAfter(deadline: .now() + waitForTransition) { [self] in
            self.placeDotsFromGrid(grid: grid) // place player and dots from 2D integer array
            timerNode.start()
            print("level timer start")
         
        
            for i in 0..<n_powerups{
                if let cpow = powerUpArray[i]{
                    if (cpow.isActive() && cpow.isFreezeTime() ){  
                        timerNode.pause()
                        print("freezenode still active")
                    }
                }
            }
            if (!isTouchEnabled){
                isTouchEnabled = true
            }
        }
       

       // if powerupEligible && n_powerups < max_powerUps  {
        if !restart{
            progressBar.increaseProgress(3.8)
        }
        
        
       
    }
    
    // translates matrix index to position on screen
    func coordCalculate(indices: CGPoint) -> CGPoint {
        return CGPoint(
            x: offsetX + CGFloat(indices.x) * dotSpacingX,
            y: offsetY + CGFloat(indices.y) * dotSpacingY)
        
    }
}
