//
//  TTGameContext.swift
//  Test
//
//  Created by Hyung Lee on 10/20/24.
//

import Combine
import GameplayKit

class DDGameContext: GameContext {
    var gameScene: DDGameScene? {
        scene as? DDGameScene
    }
    let gameMode: GameModeType
    let gameInfo: DDGameInfo
    var layoutInfo: DDLayoutInfo = .init(screenSize: .zero)
    
    private(set) var stateMachine: GKStateMachine?
    
    init(dependencies: Dependencies, gameMode: GameModeType) {
        self.gameInfo = DDGameInfo()
        self.gameMode = gameMode
        super.init(dependencies: dependencies)
    }
    
    func configureStates() {
        guard let gameScene else { return }
        print("did configure states")
        stateMachine = GKStateMachine(states: [
            DDGameIdleState(scene: gameScene, context: self)
        ])
    }

}
