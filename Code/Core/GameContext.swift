//
//  GameContext.swift
//  Dot-Dash
//
//  Created by Zhaorong Tu on 11/1/24.
//

import Foundation
import CoreGraphics

public class GameContext {
    static let shared = GameContext() // singleton instance
    
    // define parameters for the grid, which will track positions of DotNodes
    var grid: [[Bool]]
    let gridSize = 13
    let dotSpacing: CGFloat = 15  // space between dots for layout on screen


    // initialize array to be of size gridSize x gridSize
    private init() { 
        grid = Array(repeating: Array(repeating: false, count: gridSize), count: gridSize)
    }
    
    // function to get a random grid position
    // TODO: update to avoid placing dots on top of each other
    func getRandomPosition() -> (Int, Int) {
        let i = Int.random(in: 0..<gridSize)
        let j = Int.random(in: 0..<gridSize)
        return (i, j)
    }
}
