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

        // center grid on screen
        let gridWidth = CGFloat(gridSize) * dotSpacing
        offsetX = max(30, (size.width - gridWidth) / 2)
        offsetY = max(30, (size.height - gridWidth) / 2)

        drawGrid(difficultyRating: 5, initX: 6, initY: 6)

        // context.stateMachine?.enter(DOSetupState.self) // turn on statemachine drawgrid here

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
        // placeholder
        handleTouchEnd()
    }

    private func handleTouch(_ touch: UITouch) {
        // TEST: uncomment to place dots randomly with a click to see how the placeDot function works
        /*
        let (i, j) = DOGameContext.shared.getRandomPosition()

        if !grid[i][j] {
            placeDot(at: (i, j), offsetX: offsetX, offsetY: offsetY)
            DOGameContext.shared.grid[i][j] = true // Mark the position as occupied
        }
        */
        firstPosition = touch.location(in: self)
    }

    private func handleTouchMoved(_ touch: UITouch) {
        // placeholder
        lastPosition = touch.location(in: self)
    }
    func handleTouchEnd() {
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
        if sqrt( (deltaX * deltaX + deltaY * deltaY))<55.0{
            return
           
        }
        if deltaX > 0 && abs(deltaX) > abs(deltaY) {
            yv = 0
            xv = 1
        } else if deltaX < 0 && abs(deltaX) > abs(deltaY) {
            yv = 0
            xv = -1

        } else if deltaY > 0 && abs(deltaX) < abs(deltaY) {

            yv = 1
            xv = 0
        } else if deltaY < 0 && abs(deltaX) < abs(deltaY) {

            yv = -1
            xv = 0
        }
        // could add dead zone to stop misclicks
        //  if yv != .zero && xv != .zero{

        var (currentX, currentY) = playerNode.getLoc()
        while currentX > 0 && currentY > 0 && currentX < self.gridSize + 1
            && currentY < self.gridSize + 1
        {
            currentX = currentX + xv
            currentY = currentY + yv
            if grid[currentX][currentY] {
                print("found a dot")
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
                gameInfo.score += 100
                scoreNode.updateScore(with: gameInfo.score)

                break

            }
        }
        if currentX == 0 || currentY == 0 || currentX == self.gridSize + 1
            || currentY == self.gridSize + 1
        {
            // print("game over, try again")
            gameOver()
        }
        //}
        if dotCount == 0 {
            // print("Round finished! ggs")
            levelClear()
        }
    }

    private func drawGrid(difficultyRating: Int, initX: Int, initY: Int) {
        var rng = SystemRandomNumberGenerator()
        //var randomDifficulty = Int.random(in: (difficultyRating - 1)...(difficultyRating + 1), using: &rng) // difficulty range
        var randomDifficulty = difficultyRating
        print(randomDifficulty)
        
        dotCount = randomDifficulty
        randomDifficulty += 1
        var tempGrid = grid
        tempGrid[initX][initY] = true
        var currentX = initX
        var currentY = initY
        
        // vars to handle unsolvable levels
        var prevDir = -1
        let inverseDir = [1, 0, 3, 2]
        
        // TEST: manually set difficulty for testing
        /*
        var difficultyRating = 10
        var initX = 7
        var initY = 7
        */
        
        while randomDifficulty > 0 {
            var direction = Int.random(in: 0..<4, using: &rng)
            while (prevDir >= 0 && direction == inverseDir[prevDir]) {
                direction = Int.random(in: 0..<4, using: &rng)
            }
            
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
                print(currentX)
                print(currentY)
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

        // create a dot and add it to the scene
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
        drawGrid(difficultyRating: 10, initX: 6, initY: 6)
    }

    // translates matrix index to position on screen
    func coordCalculate(indices: CGPoint) -> CGPoint {
        return CGPoint(
            x: offsetX + CGFloat(indices.x) * dotSpacing,
            y: offsetY + CGFloat(indices.y) * dotSpacing)

    }

    func didBegin(_ contact: SKPhysicsContact) {
        print("Dot has collided with another body!")
    }
}
