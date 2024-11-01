//
//  GameScene.swift
//  watermelon
//
//  Created by Oleksii Andriushchenko on 26.10.2023.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    unowned let context: GameContext

    private lazy var contactResovler = ContactResolver(scene: self)

    let backgroundNode = BackgroundNode()
    let scoreNode = ScoreNode()
    let evolutionNode = EvolutionNode()
    let targetLineNode = TargetLineNode()

    let dotSprites = SKTextureAtlas(named: "DotAtlas")
    
    init(context: GameContext, size: CGSize) {
        self.context = context
        super.init(size: size)
        
        dotSprites.preload {
            print("dot sprite preloaded")
        }
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        isUserInteractionEnabled = true
       // applyGravity()

        backgroundNode.setup(screenSize: size)
        backgroundNode.zPosition = 0
        addChild(backgroundNode)

        let ht = evolutionNode.setup(screenSize: size)
        evolutionNode.position = CGPoint(x: size.width/2.0, y: size.height / 2.0)
        evolutionNode.zPosition = 1
        addChild(evolutionNode)

        nextFruitNode.setup(screenSize: size)
        addChild(nextFruitNode)

        scoreNode.setup(screenSize: size)
        addChild(scoreNode)

        let imgSize = boxNode.setup(screenSize: size, bottom: ht)
        addChild(boxNode)

        targetLineNode.setup(
            screenSize: size,
            boxBottom: boxNode.boxImageBottom,
            height: boxNode.boxImageSize.height + 24
        )
        addChild(targetLineNode)

        let boxFront = SKSpriteNode(imageNamed: "dtf_box_front")
        boxFront.zPosition = 99
        boxFront.size = .init(width: imgSize.width, height: imgSize.height * 0.9078947368)
        boxFront.position = .init(x: size.width / 2.0, y: boxFront.size.height / 2.0 + ht + BoxNode.Constants.bottomPadding - 1.5)
        addChild(boxFront)

        context.layoutInfo = LayoutInfo(screenSize: size)
        context.stateMachine?.enter(SwipingState.self)
    }

    override func update(_ currentTime: TimeInterval) {
        //let's check for
        children
            .compactMap { $0 as? FruitNode }
            .forEach { fruitNode in
                if fruitNode.name == FruitNode.Constants.fallenFruitName, boxNode.isOverTop(fruit: fruitNode) {
                    context.stateMachine?.enter(GameOverState.self)
                } else {
                    if let pos = boxNode.isLeft(fruit: fruitNode) {
                        fruitNode.position = pos
                    } else if let pos = boxNode.isRight(fruit: fruitNode) {
                        fruitNode.position = pos
                    } else if let pos = boxNode.isBottom(fruit: fruitNode) {
                        fruitNode.position = pos
                    }
                }
            }

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let state = context.stateMachine?.currentState as? SwipingState else {
            return
        }
        state.handleTouch(touch)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let state = context.stateMachine?.currentState as? SwipingState else {
            return
        }
        state.handleTouchMoved(touch)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let state = context.stateMachine?.currentState as? SwipingState else {
            return
        }
        state.handleTouchEnd()
    }

    func createFruitNode(type: FruitType) -> FruitNode {
        let fruitNode = FruitNode(type: type, texture: fruitSprites.textureNamed(type.textureName))
        fruitNode.position = CGPoint(x: size.width / 2, y: size.height - 150)
        addChild(fruitNode)
        targetLineNode.position.x = size.width / 2
        return fruitNode
    }

    func reset() {
        context.gameInfo.score = 0
        scoreNode.updateScore(with: 0)
        children
            .compactMap { $0 as? FruitNode }
            .forEach { $0.removeFromParent() }
        context.stateMachine?.enter(SwipingState.self)
    }

    func updateNextFruitNode(type: FruitType) {
        let texture = fruitSprites.textureNamed(type.textureName)
        let scale = NextFruitNode.Constants.fruitSize.height / texture.size().height
        let fruitNode = FruitNode(type: type, texture: texture, scale: scale)
        nextFruitNode.update(fruitNode: fruitNode)
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        if let score = contactResovler.handle(contact: contact) {
            context.gameInfo.score += score
            scoreNode.updateScore(with: context.gameInfo.score)
        }
        guard let state = context.stateMachine?.currentState as? SlidingState else {
            return
        }
        state.handleContact(contact)
    }
}
