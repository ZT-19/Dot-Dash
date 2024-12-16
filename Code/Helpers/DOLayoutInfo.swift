//
//  DOLayoutInfo.swift
//  Dot-Dash
//
//  Created by Justin Chen on 12/15/24.
//


import UIKit

class DOLayoutInfo {
    var screenSize: CGSize
    // ALL DEFAULT VALUES ARE FOR PRO
    var playableYTop = 620.0 // below the level count. All these values are scaled to 0,0 anchor
    var playableYBottom = 140.0 // above all powerups.
    var playableXLeft = 15.0 // below the level count
  var playableXRight = 397.0  // above all powerups.
    var playableXSize:Double = 1.00 // right-left ,will be set in didmove
     var playableYSize:Double = 10.0// top - bottom will be set in didmove
    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 0
    
    var powerupRadius = 45.0 / 402.0 *  UIScreen.main.bounds.width
    var powerUpNodeRadius: CGFloat = 68 / 402.0 *  UIScreen.main.bounds.width

    init(size:CGSize){
        screenSize = size
      
        offsetX = playableXLeft * (0.85)
        offsetY = playableYBottom * (1.43)
        if screenSize.width < 376.0 {
            setUpSE()
        }
        if screenSize.width > 403.0{
            setUpProMax()
        }
        playableXSize = playableXRight-playableXLeft
        playableYSize = playableYTop-playableYBottom
    }
    func setUpSE(){
        self.playableYBottom = 140
        playableYTop = 500
        playableXRight = 375
        playableXLeft = 30
        offsetX = playableXLeft - 16
        offsetY = playableYBottom + 17
      
    }
    func setUpRegular(){
        
    }
    func setUpProMax(){
        self.playableYBottom = 210
        playableYTop = 750
        playableXRight = 430
        playableXLeft = 10
        offsetX = playableXLeft - 0.5
        offsetY = playableYBottom 
    }
    
    
}
