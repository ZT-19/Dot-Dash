//
//  GameContext.swift
//  watermelon
//
//  Created by Oleksii Andriushchenko on 26.10.2023.
//

import Combine
import GameplayKit
import SwiftUI

class GameContext {

    private(set) var scene: GameScene!
    private(set) var stateMachine: GKStateMachine?

    var layoutInfo = LayoutInfo(screenSize: .zero)
    var gameInfo = GameInfo()

    init() {
        self.scene = GameScene(context: self, size: UIScreen.main.bounds.size)
        configureStates()
    }

    func configureStates() {
        stateMachine = GKStateMachine(
            states: [
                SwipingState(scene: scene, context: self),
                FallingState(scene: scene, context: self),
                GameOverState(scene: scene, context: self)
            ]
        )
    }
}
