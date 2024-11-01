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
    private var firstPosition: CGPoint = .zero
    enum swipeDirections {
        case up
        case down
        case left
        case right
        case none
    }

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
        firstPosition = touch.location(in: scene)

    }

    func handleTouchMoved(_ touch: UITouch) {

        isSwiping = true
        lastPosition = touch.location(in: scene)
    }

    func handleTouchEnd() {

        let deltaX = lastPosition.x - firstPosition.x
        let deltaY = lastPosition.y - firstPosition.y
        let direction = swipeDirections.none
        if deltaX > 0 && abs(deltaX) > abs(deltaY) {
            let direction = swipeDirections.right
        } else if deltaX < 0 && abs(deltaX) > abs(deltaY) {
            let direction = swipeDirections.left
        } else if deltaY > 0 && abs(deltaX) < abs(deltaY) {
            let direction = swipeDirections.up
        } else if deltaY < 0 && abs(deltaX) < abs(deltaY) {
            let direction = swipeDirections.down
        }

        if direction != swipeDirections.none {
            context.stateMachine?.enter(SlidingState.self)
            if let SlidingState = context.stateMachine?.state(forClass: SlidingState.self) {
                SlidingState.fallingFruit = fruitNode
            }
        }
    }

}
