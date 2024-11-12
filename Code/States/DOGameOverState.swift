//
//  DOGameOverState.swift
//  watermelon
//
//  Created by Oleksii Andriushchenko on 26.10.2023.
//

import CoreHaptics
import GameplayKit

class DOGameOverState: GKState {
    unowned let scene: GameSKScene
    unowned let context: DOGameContext

    init(scene: DOGameScene, context: DOGameContext) {
        self.scene = scene
        self.context = context
        super.init()
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass is DOSwipingState.Type
    }

    override func didEnter(from previousState: GKState?) {
        print("🔴 DOGameOverState. Did enter.")
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred(intensity: 0.85)
        Task { @MainActor in
            scene.reset()
        }
    }
}
