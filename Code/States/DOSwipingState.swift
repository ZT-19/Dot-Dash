//
//  DOSwipingState.swift
//  watermelon
//
//  Created by Oleksii Andriushchenko on 26.10.2023.
//

import GameplayKit

class DOSwipingState: GKState {
    unowned let scene: GameSKScene
    unowned let context: DOGameContext

    private var isSwiping = false
    private var lastPosition: CGPoint = .zero
    private var firstPosition: CGPoint = .zero
    var playerNode: DOPlayerNode?
    private var xv: Int = .zero
    private var yv: Int = .zero

    enum swipeDirections {
        case up
        case down
        case left
        case right
        case none
    }

    init(scene: DOGameScene, context: DOGameContext) {
        self.scene = scene
        self.context = context
        super.init()
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass is DOSlidingState.Type || stateClass is DOGameOverState.Type
    }

    override func didEnter(from previousState: GKState?) {
        print("🔴 DOSwipingState. Did enter.")

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
            yv = 0
            xv = 1
        } else if deltaX < 0 && abs(deltaX) > abs(deltaY) {
            let direction = swipeDirections.left
            yv = 0
            xv = -1

        } else if deltaY > 0 && abs(deltaX) < abs(deltaY) {
            let direction = swipeDirections.up
            yv = 1
            xv = 0
        } else if deltaY < 0 && abs(deltaX) < abs(deltaY) {
            let direction = swipeDirections.down
            yv = -1
            xv = 0
        }
        // could add dead zone to stop misclicks

        if direction != swipeDirections.none {
            if direction != swipeDirections.none {
                playerNode?.physicsBody?.applyImpulse(CGVector(dx: xv, dy: yv))

            }
            context.stateMachine?.enter(DOSlidingState.self)

        }

    }

}
