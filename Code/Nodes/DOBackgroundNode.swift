//
//  DOBackgroundNode.swift

import SpriteKit

class DOBackgroundNode: SKSpriteNode {
    private var backgrounds = [
        "tanbackground"
    ]
    private var gridSize = DOGameContext.shared.gridSize
    private var playableXSize:Double // right-left
    private var playableYSize:Double // top - bottom
    private let playableYTop = 620.0 / 874.0 * UIScreen.main.bounds.height // below the level count. All these values are scaled to 0,0 anchor
    private let playableYBottom = 140.0 / 874.0 * UIScreen.main.bounds.height// above all powerups.
    private let playableXLeft = 15.0 / 402.0 *  UIScreen.main.bounds.width// below the level count
    private let playableXRight = 397.0 / 402.0 *  UIScreen.main.bounds.width// above all powerups.
    private let eps = 3.0
    private var alt = false // to make sure chess rows alternate
    private let const_zpos = -30.0
    private let transitionTime = 1.4
    
    private var rng = SystemRandomNumberGenerator()
    init() {
        let texture = SKTexture(imageNamed: backgrounds[0])
        playableXSize = playableXRight-playableXLeft
        playableYSize = playableYTop-playableYBottom
        super.init(texture: texture, color: .clear, size: texture.size())
    }
    func changeGridSize(new:Int){
        gridSize=new
    }
    private func addStars(gridSize: Int = 13) {
   
        
        // generate random number of stars (40-50)
        
        var yPosition = playableYTop
       
        /*
        let debug = SKShapeNode(path:CGPath(ellipseIn: CGRect(
            x: -30/2,  // Center the rect
            y: -30/2,  // Center the rect
            width: 30,  // Use full radius for width
            height: 30  // Use full radius for height
        ), transform: nil))
        debug.fillColor = .red
        debug.position = CGPoint(x:0,y:playableYBottom - size.height/2)
       
        addChild(debug)
        */
      
        //now using the first tile laid around the border of the frame fill the part above the playable part
        yPosition = playableYTop + (playableYSize/Double(gridSize+1))
        while yPosition <= size.height + eps{
            var xPosition = playableXLeft
            if alt{
                xPosition += playableXSize/Double(gridSize+1)
            }
            while xPosition <= playableXRight + eps{
                let star = DOStarNode(position: CGPoint(x: xPosition - size.width/2, y: yPosition - size.height/2), screenHeight: size.height, width:  playableXSize/Double(gridSize+1), height: playableYSize/Double(gridSize+1), duration: transitionTime / 2.0)
    
                addChild(star)
               
                xPosition += 2 * playableXSize/Double(gridSize+1)
            }
            
            yPosition += (playableYSize/Double(gridSize+1))
            print(alt)
            alt = (alt == false) // switches alt
        }
        
        yPosition = playableYTop
        while yPosition >= 0 - eps{
            var xPosition = playableXLeft
            if alt{
                xPosition += playableXSize/Double(gridSize+1)
            }
            while xPosition <= playableXRight + eps{
                let star = DOStarNode(position: CGPoint(x: xPosition - size.width/2, y: yPosition - size.height/2), screenHeight: size.height, width:  playableXSize/Double(gridSize+1), height: playableYSize/Double(gridSize+1))
              
                addChild(star)
               
                xPosition += 2 * playableXSize/Double(gridSize+1)
            }
            
            yPosition -= (playableYSize/Double(gridSize+1))
      
            
            alt = (alt == false) // switches alt
           
        }
       
        yPosition = 0.0
        var xPosition = playableXLeft
        while xPosition <= playableXRight + eps{
            let star = DOStarNode(position: CGPoint(x: xPosition - size.width/2, y: yPosition - size.height/2), screenHeight: size.height, width:  playableXSize/Double(gridSize+1), height: playableYSize/Double(gridSize+1) * 2, color: UIColor(red: 79.0/255, green: 76.0/255, blue: 72.0/255, alpha: 1))
            
        
            addChild(star)
           
            xPosition += playableXSize/Double(gridSize+1)
        }

        /*
        let starCount = Int.random(in: 40...50, using: &rng)
    
        for _ in 0..<starCount {
            let xPos = CGFloat.random(in: -size.width/2...size.width/2, using: &rng)
            let yPos = CGFloat.random(in: -size.height/2...size.height/2, using: &rng)
            
            let star = DOStarNode(position: CGPoint(x: xPos, y: yPos), screenHeight: size.height)
            addChild(star)
        }
        */

    }
    private func animateCurrentStarsDown() {
        let slideDown = SKAction.moveBy(x: 0, y: -size.height * 2, duration: transitionTime)
    children.forEach { node in
        if let star = node as? DOStarNode {
            let sequence = SKAction.sequence([
                slideDown,
                SKAction.removeFromParent()
            ])
            star.run(sequence)
        }
    }
}

func setDeterminedTexture(id: Int = 0, secret: Bool = false) {
    // start sliding existing stars down
    animateCurrentStarsDown()
    
    // add new stars immediately to maintain continuity
    let changeBackground = SKAction.run { [weak self] in
        self?.texture = SKTexture(imageNamed: self?.backgrounds[id] ?? "")
        self?.addStars(gridSize: self!.gridSize)
    }
    
    run(changeBackground)
}

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(screenSize: CGSize) {
        position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        animateCurrentStarsDown()
        
        let wait = SKAction.wait(forDuration: 0.01)
        let setupAction = SKAction.run { [weak self] in
            self?.removeAllChildren()
            self?.addStars(gridSize: self!.gridSize)
        }
        
        run(SKAction.sequence([wait, setupAction]))
    }
}
