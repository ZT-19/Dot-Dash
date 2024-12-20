//
//  DOGameContext.swift
//  Dot-Dash
//
//  Created by Zhaorong Tu on 11/1/24.
//

import Foundation
import CoreGraphics
import GameplayKit

class DOGameContext: GameContext {
    var gameScene: DOGameScene? { scene as? DOGameScene }
    let gameMode: GameModeType
    
    // define parameters for the grid, which will track positions of DODotNodes


    // initialize array to be of size gridSize + 2 x gridSize + 2
    // outermost row and column have nothing in them, used to detect out-o-bounds
    
    init(dependencies: Dependencies, gameMode: GameModeType) {
        self.gameMode = gameMode
        super.init(dependencies: dependencies)
        
        self.scene = DOGameScene(context: self, size: UIScreen.main.bounds.size)
        
    }
    
}
