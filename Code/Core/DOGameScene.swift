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
    private var difficulty = 5
    var dotCount: Int = 0
    let backgroundNode = DOBackgroundNode()
    let scoreNode = DOScoreNode()
    let levelNode = DOLevelNode()
    var playerNode = DOPlayerNode()
    let gameOverNode = DOGameOverNode()
    var gameInfo = DOGameInfo()
    var gameOverScreen = false

    private var lastPosition: CGPoint = .zero
    private var firstPosition: CGPoint = .zero
    private var xv: Int = .zero
    private var yv: Int = .zero
    
    // time vars
    private var bonusTime = 10.0
    private var lastUpdateTime: TimeInterval = 0
    private var remainingTime: TimeInterval = 30
    private var timerLabel = SKLabelNode(fontNamed: "Arial")

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
        
        // setup timer label
        timerLabel.text = "Time: \(Int(remainingTime))"
        timerLabel.fontSize = 24
        timerLabel.fontColor = .white
        timerLabel.position = CGPoint(x: size.width / 2, y: size.height / 4)
        addChild(timerLabel)

    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        handleTouch(touch)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        handleTouchMoved(touch)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        handleTouchEnd(touch)
    }
    
    override func update(_ currentTime: TimeInterval) {
            // initialize lastUpdateTime during the first frame
            if lastUpdateTime == 0 {
                lastUpdateTime = currentTime
            }

            // calculate time difference as deltaTime
            let deltaTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime

            // update the time remaining and check if game ends
            remainingTime -= deltaTime
            if remainingTime <= 0 {
                remainingTime = 0
                gameOver()
            }

            // ppdate the label
            timerLabel.text = "Time: \(Int(remainingTime))"
    }

    private func handleTouch(_ touch: UITouch) {
        firstPosition = touch.location(in: self)
    }

    private func handleTouchMoved(_ touch: UITouch) {
        // placeholder
        // lastPosition = touch.location(in: self)
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
        if sqrt( (deltaX * deltaX + deltaY * deltaY))<35.0{
            return
        }
        if deltaX > 0 && abs(deltaX) > abs(deltaY) {
            print("Swipe right")
            yv = 0
            xv = 1
        } else if deltaX < 0 && abs(deltaX) > abs(deltaY) {
            print("Swipe left")
            yv = 0
            xv = -1
        } else if deltaY > 0 && abs(deltaX) < abs(deltaY) {
            print("Swipe up")
            yv = 1
            xv = 0
        } else if deltaY < 0 && abs(deltaX) < abs(deltaY) {
            print("Swipe down")
            yv = -1
            xv = 0
        }
        // could add dead zone to stop misclicks
        //  if yv != .zero && xv != .zero{

        var (currentX, currentY) = playerNode.getLoc()
        while currentX > 0 && currentY > 0 && currentX < self.gridSize + 1 && currentY < self.gridSize + 1 {
            currentX = currentX + xv
            currentY = currentY + yv
            
            if grid[currentX][currentY] {
                print("found a dot")
                
                // remove dot
                grid[currentX][currentY] = false
                self.childNode(withName: "DotNode" + String(currentX) + " " + String(currentY))?
                    .removeFromParent()
                self.dotCount -= 1
                
                // move player
                
                let destinationPosition = coordCalculate(indices: CGPoint(x: currentX, y: currentY))

                if let playerNode = self.childNode(withName: "player") as? DOPlayerNode {
                    let slideTween = SKAction.move(to: destinationPosition, duration: 0.1)
                    playerNode.run(slideTween) {
                        playerNode.gridPosition = CGPoint(x: currentX, y: currentY)
                    }
                }
                else {
                    let newPlayerNode = DOPlayerNode(
                        position: coordCalculate(indices: CGPoint(x: currentX, y: currentY)),
                        gridPosition: CGPoint(x: currentX, y: currentY)
                    )
                    newPlayerNode.name = "player"
                    self.addChild(newPlayerNode)
                }
                /*
                
                self.childNode(withName: "player")?.removeFromParent()
                playerNode = DOPlayerNode(
                    position: coordCalculate(indices: CGPoint(x: currentX, y: currentY)),
                    gridPosition: CGPoint(x: currentX, y: currentY))
                playerNode.name = "player"
                self.addChild(playerNode)
            
                 */
                
                // update score
                gameInfo.score += 100
                scoreNode.updateScore(with: gameInfo.score)

                break

            }
        }
        if currentX == 0 || currentY == 0 || currentX == self.gridSize + 1 || currentY == self.gridSize + 1 {
            print("Level failed, try again")
            levelLoad(restart: true)
        }
        //}
        if dotCount == 0 {
            print("Round finished! ggs")
            levelLoad(restart: false)
        }
    }

    private func drawGrid(difficultyRating: Int, initX: Int, initY: Int) {
        var rng = SystemRandomNumberGenerator()
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
            //var direction = Int.random(in: 0..<4, using: &rng)
            //while (prevDir >= 0 && direction == inverseDir[prevDir]) direction = Int.random(in: 0..<4, using: &rng)
            
            
            switch direction {
            case 0: // right
                if currentX < gridSize - 1 {
                    currentX += Int.random(in: 1...(gridSize - currentX), using: &rng)
                }
            case 1: // left
                if currentX > 0 {
                    currentX -= Int.random(in: 1...currentX, using: &rng)
                }
            case 2: // down
                if currentY < gridSize - 1 {
                    currentY += Int.random(in: 1...(gridSize - currentY), using: &rng)
                }
            case 3: // up
                if currentY > 0 {
                    currentY -= Int.random(in: 1...currentY, using: &rng)
                }
            default:
                break
            }
            
            if !tempGrid[currentX][currentY] {
                //print(currentX)
                //print(currentY)
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

    func levelClear() {
        self.removeAllChildren()
        backgroundNode.setRandomTexture()
        gameInfo.level += 1
        levelNode.updateLevel(with: gameInfo.level)
        addChild(backgroundNode)
        addChild(scoreNode)
        addChild(levelNode)
        grid = Array(
            repeating: Array(repeating: false, count: self.gridSize + 2), count: self.gridSize + 2)
        drawGrid(difficultyRating: difficulty, initX: 6, initY: 6)
    }
 
    func levelLoad(restart: Bool) {
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
        }

        // set a new random background
        backgroundNode.setRandomTexture()

        // if we are not restarting (we go to next level)
        if (!restart) {
            // level increments and receive level completion bonuses
            gameInfo.level += 1
            gameInfo.score += 300
            remainingTime += bonusTime
        }
        levelNode.updateLevel(with: gameInfo.level)
        scoreNode.updateScore(with: gameInfo.score)

        // clear the grid and redraw it
        grid = Array(
            repeating: Array(repeating: false, count: self.gridSize + 2),
            count: self.gridSize + 2
        )
        drawGrid(difficultyRating: difficulty, initX: 6, initY: 6)
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
