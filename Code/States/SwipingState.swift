//
//  SwipingState.swift
//  watermelon
//
//  Created by Oleksii Andriushchenko on 26.10.2023.
//

import GameplayKit

class SwipingState: GKState {
    unowned let scene: GameScene
    unowned let context: GameContext
    
    private var isSwiping = false
    private var lastPosition: CGPoint = .zero
    
    init(scene: GameScene, context: GameContext) {
        self.scene = scene
        self.context = context
        super.init()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass is SlidingState.Type || stateClass is GameOverState.Type
    }

    override func didEnter(from previousState: GKState?) {
        print("🔴 SwipingState. Did enter.")
        scene.targetLineNode.isHidden = false
    }

    func handleTouch(_ touch: UITouch) {
        lastPosition = touch.location(in: scene)
        if let fruitNode {
            let allowedRange = context.layoutInfo.getSwipingRange(for: fruitNode, inBox: scene.boxNode)
            if lastPosition.x < allowedRange.lowerBound {
                fruitNode.position.x = allowedRange.lowerBound
                scene.targetLineNode.position.x = allowedRange.lowerBound
            } else if lastPosition.x > allowedRange.upperBound {
                fruitNode.position.x = allowedRange.upperBound
                scene.targetLineNode.position.x = allowedRange.upperBound
            } else {
                fruitNode.position.x = lastPosition.x
                scene.targetLineNode.position.x = lastPosition.x
            }
        } else {
            fruitNode?.position.x = lastPosition.x
        }

    }

    func handleTouchMoved(_ touch: UITouch) {
        guard let fruitNode else {
            return
        }
        isSwiping = true
        let newPosition = touch.location(in: scene)
        let deltaX = newPosition.x - lastPosition.x
        let updatedPositionX = fruitNode.position.x + deltaX
        let allowedRange = context.layoutInfo.getSwipingRange(for: fruitNode, inBox: scene.boxNode)
        let clampedPositionX = max(allowedRange.lowerBound, min(updatedPositionX, allowedRange.upperBound))
        fruitNode.position.x = clampedPositionX
        scene.targetLineNode.position.x = clampedPositionX
        lastPosition = newPosition
    }

    func handleTouchEnd() {
        fruitNode?.enablePhysics()
        context.stateMachine?.enter(SlidingState.self)
        if let SlidingState = context.stateMachine?.state(forClass: SlidingState.self) {
            SlidingState.fallingFruit = fruitNode
            scene.targetLineNode.isHidden = true
        }
    }

}
