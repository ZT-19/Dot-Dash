//
//  setupState.swift
//  watermelon
//
//  Created by Oleksii Andriushchenko on 26.10.2023.
//

import GameplayKit

class DOSetupState: GKState {
    unowned let scene: GameSKScene
    unowned let context: DOGameContext

    init(scene: DOGameScene, context: DOGameContext) {
        self.scene = scene
        self.context = context
        super.init()
        drawGrid(difficultyRating: 25, initX: 0, initY: 0)
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass is DOSwipingState.Type || stateClass is DOGameOverState.Type
    }

    override func didEnter(from previousState: GKState?) {
        print("🔴 DOSetupState. Did enter.")
    }

    private func drawGrid(difficultyRating: Int, initX: Int, initY: Int) {
        let gridWidth = CGFloat(scene.gridSize) * context.dotSpacing
        var offsetX = (scene.size.width - gridWidth) / 2
        var offsetY = (scene.size.height - gridWidth) / 2
        var rng = SystemRandomNumberGenerator()
        var randomDifficulty = Int.random(
            in: (difficultyRating - 1)...(difficultyRating + 1), using: &rng)
        var tempGrid = context.grid
        tempGrid[initX][initY] = true
        var currentX = initX
        var currentY = initY

        while randomDifficulty > 0 {
            let direction = Int.random(in: 0..<4, using: &rng)
            switch direction {
            case 0:  // right
                if currentX < context.gridSize - 1 {
                    currentX += 1
                }
            case 1:  //  left
                if currentX > 0 {
                    currentX -= 1
                }
            case 2:  // down
                if currentY < context.gridSize - 1 {
                    currentY += 1
                }
            case 3:  // up
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
        context.stateMachine?.enter(DOSwipingState.self)
    }
    private func placeDot(at gridPosition: (Int, Int), offsetX: CGFloat, offsetY: CGFloat) {
        let (i, j) = gridPosition

        // calculate screen position from grid coordinates
        let xPosition = offsetX + CGFloat(i) * context.dotSpacing
        let yPosition = offsetY + CGFloat(j) * context.dotSpacing

        // create a dot and add it to the scene
        let dotNode = DODotNode(position: CGPoint(x: xPosition, y: yPosition))
        scene.addChild(dotNode)
    }
}
