// Code/Core/DOGameScene.swift

import SwiftUI
import SpriteKit

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
    
    private let grid = DOGameContext.shared.grid
    private let dotSpacing = DOGameContext.shared.dotSpacing
    private let gridSize = DOGameContext.shared.gridSize
    private var offsetX: CGFloat = 0
    private var offsetY: CGFloat = 0
    let backgroundNode = DOBackgroundNode()
    let scoreNode = DOScoreNode()
    var playerNode = DOPlayerNode()

    
    override func didMove(to view: SKView) {
        self.backgroundColor = .gray
        self.physicsWorld.contactDelegate = self

        backgroundNode.setup(screenSize: size)
        backgroundNode.zPosition = 0
        addChild(backgroundNode)

        scoreNode.setup(screenSize: size)
        addChild(scoreNode)

        // center grid on screen
        let gridWidth = CGFloat(gridSize) * dotSpacing
        offsetX = (size.width - gridWidth) / 2
        offsetY = (size.height - gridWidth) / 2
       
        
       
        // init

        // test dot generation

        // TEST: uncomment to draw the grid with a given difficulty rating of 25
        
         drawGrid(difficultyRating: 25, initX: 0, initY: 0)
         
        // Goal: move all of this code into setupState
        
        // context.stateMachine?.enter(DOSetupState.self) // turn on statemachine drawgrid here

    }
    // TODO: all current touch override functions are placeholders (these were implemented in the watermelon game)
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
    }


    private func handleTouchMoved(_ touch: UITouch) {
        // placeholder
    }
    
    
    private func drawGrid(difficultyRating: Int, initX: Int, initY: Int) {
            var rng = SystemRandomNumberGenerator()
            var randomDifficulty = Int.random(in: (difficultyRating - 1)...(difficultyRating + 1), using: &rng)
        print (randomDifficulty)
            var tempGrid = grid
            tempGrid[initX][initY] = true
            var currentX = initX
            var currentY = initY
            
            while randomDifficulty > 0 {
                let direction = Int.random(in: 0..<4, using: &rng)
                switch direction {
                case 0: // right
                    if currentX < gridSize - 1 {
                        currentX += 1
                    }
                case 1: //  left
                    if currentX > 0 {
                        currentX -= 1
                    }
                case 2: // down
                    if currentY < gridSize - 1 {
                        currentY += 1
                    }
                case 3: // up
                    if currentY > 0 {
                        currentY -= 1
                    }
                default:
                    break
                }
                
                if !tempGrid[currentX][currentY] {
                    tempGrid[currentX][currentY] = true
                    placeDot(at: (currentX, currentY), offsetX: offsetX, offsetY: offsetY)
                    randomDifficulty -= 1
                }
            }
        playerNode = DOPlayerNode(position: coordCalculate(indices: CGPoint(x:gridSize/2+1,y:gridSize/2+1)),gridPosition: CGPoint(x: gridSize / 2 + 1, y: gridSize / 2 + 1))
        self.addChild(playerNode)
        }
    private func placeDot(at gridPosition: (Int, Int), offsetX: CGFloat, offsetY: CGFloat) {
        let (i, j) = gridPosition
        
        // calculate screen position from grid coordinates
        let xPosition = offsetX + CGFloat(i) * dotSpacing
        let yPosition = offsetY + CGFloat(j) * dotSpacing
        
        // create a dot and add it to the scene
        let dotNode = DODotNode(position: CGPoint(x: xPosition, y: yPosition), gridPosition: CGPoint(x:i,y:j))
        self.addChild(dotNode)
    }
    
    // translates matrix index to position on screen
    func coordCalculate(indices: CGPoint) -> CGPoint{
        return CGPoint(x:offsetX + CGFloat(indices.x),y:offsetY + CGFloat(indices.y))
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        print("Dot has collided with another body!")
    }
}
