//
//  DOSlidingState.swift
//  DotDash
//
//  Created by Justin Chen, 11/1/2024
//

import GameplayKit

class DOSlidingState: GKState {
    unowned let scene: GameSKScene
    unowned let context: DOGameContext

   
    var playerNode: DOPlayerNode?

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
        stateClass is DOSwipingState.Type || stateClass is DOGameOverState.Type
    }

    override func didEnter(from previousState: GKState?) {
        print("🔴 DOSlidingState. Did enter.")
    }

    func handleContact(_ contact: SKPhysicsContact) {

       
        playerNode?.physicsBody?.velocity = CGVector(dx:0,dy:0) // stops on impact with a point
        
        context.stateMachine?.enter(DOSwipingState.self)
    }

}
