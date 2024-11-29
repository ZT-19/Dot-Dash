//
//  DOBackgroundNode.swift

import SpriteKit

class DOBackgroundNode: SKSpriteNode {
    private var backgrounds = [
        "black"
    ]
    private var rng = SystemRandomNumberGenerator()
    init() {
        let texture = SKTexture(imageNamed: backgrounds[0])
        super.init(texture: texture, color: .clear, size: texture.size())
    }
    private func addStars() {
        // generate random number of stars (40-50)
        let starCount = Int.random(in: 40...50, using: &rng)
    
        for _ in 0..<starCount {
            let xPos = CGFloat.random(in: -size.width/2...size.width/2, using: &rng)
            let yPos = CGFloat.random(in: -size.height/2...size.height/2, using: &rng)
            
            let star = DOStarNode(position: CGPoint(x: xPos, y: yPos), screenHeight: size.height)
            addChild(star)
        }
    }
    private func animateCurrentStarsDown() {
    let slideDown = SKAction.moveBy(x: 0, y: -size.height * 2, duration: 2.0)
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

func setDeterminedTexture(id:Int = 0, secret: Bool = false) {
    // start sliding existing stars down
    animateCurrentStarsDown()
    
    // add new stars immediately to maintain continuity
    let changeBackground = SKAction.run { [weak self] in
        self?.texture = SKTexture(imageNamed: self?.backgrounds[id] ?? "")
        self?.addStars()
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
            self?.addStars()
        }
        
        run(SKAction.sequence([wait, setupAction]))
    }
}
