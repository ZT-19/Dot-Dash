//
//  DOGameContext.swift
//  Dot-Dash
//
//  Created by Zhaorong Tu on 11/1/24.
//

import Foundation
import CoreGraphics
import GameplayKit

public class DOGameContext {
    static let shared = DOGameContext()  // singleton instance
    private(set) var scene: DOGameScene!
    private(set) var stateMachine: GKStateMachine?  // needed to manage states
    
    // define parameters for the grid, which will track positions of DODotNodes
    var grid: [[Int]]
    let gridSize = 13
    let gridCenter = 6
    let dotSpacing: CGFloat = 30  // space between dots for layout on screen, remove hardcode later
    var powerUpArray: [DOPowerUpNode?]

    // initialize array to be of size gridSize + 2 x gridSize + 2
    // outermost row and column have nothing in them, used to detect out-o-bounds
    init() {
        grid = Array(repeating: Array(repeating: 0, count: gridSize+2), count: gridSize+2)
        
        powerUpArray = Array(repeating: nil, count: 5)
    }

    func getRandomPosition() -> (Int, Int) {
        let i = Int.random(in: 1..<gridSize+1)
        let j = Int.random(in: 1..<gridSize+1)
        return (i, j)
    }
    
}
