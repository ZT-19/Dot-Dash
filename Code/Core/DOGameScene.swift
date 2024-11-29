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
    private var difficulty = 10
    private var dotCount: Int = 0
    //let backgroundNode = DOBackgroundNode()
    
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
    
    // timer
    private var remainingTime: TimeInterval = 64440
    private var bonusTime = 30.0
    private var timerNode: DOTimerNode!
    private var explodingTimer: DOTimerNode!
    
    // modifier states
    private var modCode: Int? // -1 is inactive, anything above 0 represents a modifier
    //private var modSuddenDeath = false
    //private var modExplodingTimer = false
    //private var modDoubleDots = false //2
    
    // animations
    let transitionAni = SKAction.moveBy(x: 0, y: -UIScreen.main.bounds.size.height, duration: 1.5)
    
    // powerups
    /*
    private var powerupNode: DOPowerUpNode!
    private var dotBonus = 1
    private var lvlBonus = 1
    */

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
        timerNode.setPosition(CGPoint(x: size.width / 2, y: size.height / 4))
        addChild(timerNode)
        
        //powerupNode = DOPowerUpNode(type: .doubleScorePerNode, position: CGPoint(x: 100, y: 100))
        //addChild(powerupNode)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if timerNode.update(currentTime) {
            gameOver()
        }
        if let explodingTimer = explodingTimer {
            if explodingTimer.update(currentTime) {
                gameOver()
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
                gameInfo.score += 10
                scoreNode.updateScore(with: gameInfo.score)

                break
            }
        }
        if currentX == 0 || currentY == 0 || currentX == self.gridSize + 1 || currentY == self.gridSize + 1 {
            //print("LEVEL RESET | X: \(currentX) Y: \(currentY)")
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
        }
    }

    private func drawGrid(difficultyRating: Int, initX: Int, initY: Int) {
        
        var randomDifficulty = difficultyRating
        
        // uncomment to use difficulty range instead of set difficulty
        // randomRange = 1
        // randomDifficulty = Int.random(in: (difficultyRating - randomRange)...(difficultyRating + randomRange), using: &rng)
        
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
        // remove all dots and players from the scene
        //levelTransition()
        if (!restart){
            print("animation should start")
            let playerTransition1 = SKAction.moveBy(x: 0, y: UIScreen.main.bounds.size.height - playerNode.position.y + 10, duration: 2.0)
            playerNode.run(playerTransition1){
                print("kjlsadkfa")
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
            if let explodeNodeD = child as? DOExplodingTimerNode {
                explodeNodeD.removeFromParent()
                //print("Exploding Timer removed")
            }
        }

        // set a new random background, non secret for now
       
    

        // if we are not restarting, we go to the next level
        if (!restart) {
          
            gameInfo.level += 1
            gameInfo.score += 100
            timerNode.addTime(bonusTime)
        }
        levelNode.updateLevel(with: gameInfo.level)
        scoreNode.updateScore(with: gameInfo.score)

        // clear the grid
        grid = Array(
            repeating: Array(repeating: false, count: self.gridSize + 2),
            count: self.gridSize + 2
        )
        
        if gameInfo.level % 3 == 0 && !restart {
            modCode = Int.random(in: 0...2) // random inclusive
            print("Modifier Active: modCode = \(modCode!)")
        } else if gameInfo.level % 3 != 0 {
            modCode = nil // Clear the modifier
            print("No Modifier Active")
        }
        
        if (modCode == 0 && !restart) {
            explodingTimer = DOTimerNode(initialTime: bonusTime)
            explodingTimer.setPosition(CGPoint(x: size.width / 2, y: size.height / 5))
            addChild(explodingTimer)
        }
        
        // mod: double difficulty
        if (modCode == 2) {
            drawGrid(difficultyRating: difficulty * 2, initX: 6, initY: 6)
        }
        else {
            drawGrid(difficultyRating: difficulty, initX: 6, initY: 6)
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
