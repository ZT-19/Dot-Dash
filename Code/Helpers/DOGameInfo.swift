//
//  DOGameInfo.swift
// DotDash
// 
// Created by Justin Chen, 11/5/024
//

import Foundation

struct DOGameInfo {
    var rng = SystemRandomNumberGenerator()
    let backgrounds = [
        "blue",
        "green",
        "red",
        "black",
        "navy",
        "yellow",
        "navy2",
        "blue2",
        "orange",
       
    ]
    var secretBackgrounds = [
        
    "secret1"
        ]
    let silo = [
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        true
    ]
    var score = 0
    var level: Int = 1
    var themeCount = 9 // hardcoded for now
    
}
