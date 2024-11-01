//
//  GameOverState.swift
//  watermelon
//
//  Created by Oleksii Andriushchenko on 26.10.2023.
//

import CoreHaptics
import GameplayKit

class GameOverState: GKState {
    unowned let scene: GameScene
    unowned let context: GameContext

    init(scene: GameScene, context: GameContext) {
        self.scene = scene
        self.context = context
        super.init()
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass is SwipingState.Type
    }

    override func didEnter(from previousState: GKState?) {
        print("🔴 GameOverState. Did enter.")
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred(intensity: 0.85)
        Task { @MainActor in
            scene.reset()
        }
    }
}
