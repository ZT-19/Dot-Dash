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
    var playableYTop = 690.0 // below the level count. All these values are scaled to 0,0 anchor
    var playableYBottom = 200.0 // above all powerups.
    var playableXLeft = 10.0 // below the level count
  var playableXRight = 392.0  // above all powerups.
    var playableXSize:Double = 1.00 // right-left ,will be set in didmove
     var playableYSize:Double = 10.0// top - bottom will be set in didmove
    var powerupRadius = 38.0 / 402.0 *  UIScreen.main.bounds.width
    var powerUpNodeRadius: CGFloat = 85 / 402.0 *  UIScreen.main.bounds.width
    var powerUpHeight: CGFloat = 133 / 402.0 *  UIScreen.main.bounds.width
    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 0
    init(size:CGSize){
        screenSize = size
      
        offsetX = playableXLeft * (0.85)
        offsetY = playableYBottom * (1.43)
        if screenSize.width < 376.0 {
            setUpSE()
        }
        else if screenSize.width < 394.0{
            setUpRegular()
        }
        else if screenSize.width > 403.0{
            setUpProMax()
        }
        playableXSize = playableXRight-playableXLeft
        playableYSize = playableYTop-playableYBottom
        offsetX = playableXLeft
       offsetY = playableYBottom
    }
    func setUpSE(){
        print("Using SE")
        self.playableYBottom = 140
        playableYTop = 535
        playableXRight = 355
        playableXLeft = 20
        powerUpHeight = 96
        powerupRadius = 34
      
    }
    func setUpRegular(){
        print ("using regular")
        self.playableYBottom = 180
        playableYTop = 670
        playableXRight = 383
        playableXLeft = 10
        
    }
    func setUpProMax(){
        print ("using max")
        self.playableYBottom = 210
        playableYTop = 750
        playableXRight = 430
        playableXLeft = 10
        offsetX = playableXLeft - 0.5
        offsetY = playableYBottom
    }
    
    
}
