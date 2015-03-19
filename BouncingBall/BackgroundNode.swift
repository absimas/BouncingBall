//
//  BackgroundNode.swift
//  BouncingBall
//
//  Created by Simas Abramovas on 3/18/15.
//  Copyright (c) 2015 Simas Abramovas. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class BackgroundNode: SKSpriteNode {
    
    let SCROLL_DURATION = 0.7
    let STEP_HEIGHT = CGFloat(20)
    let MIN_STEP_WIDTH = 15
    let MAX_STEP_WIDTH = 60
    let MIN_STEP_DISTANCE = 200
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(size: CGSize) {
        super.init(texture: nil, color: SKColor.clearColor(), size: size)
    }
    
    func scrollUp() {
        if scene is GameScene {
            let ballScene = scene as GameScene?

            if let ballJump = ballScene!.ballJumpHeight {
                println("scroll up3")
                // Move background up
                runAction(SKAction.moveByX(0, y: -ballJump, duration: SCROLL_DURATION))
                println(position)
                addStepsFrom(abs(position.y) + ballJump);
            }
        }
    }
    
    func addStepsFrom(y: CGFloat) {
        for i in 1...5 {
            addRandomStepFrom(y)
        }
    }
    
    func addRandomStepFrom(toY: CGFloat) {
        if scene == nil {
            return
        }
        println("add step")
        // Calc the size and create a step node
        let randWidth = randInRange(MIN_STEP_WIDTH, upper: MAX_STEP_WIDTH)
        let size = CGSize(width: randWidth, height: STEP_HEIGHT)
        let step = SKSpriteNode(color: SKColor.greenColor(), size: size)
        step.anchorPoint = CGPoint(x: 0, y: 0)
        
        // Calculate the position
        let randX = randInRange(0, upper: Int(scene!.frame.width) - MAX_STEP_WIDTH)
        let randY = randInRange(Int(toY) - MIN_STEP_DISTANCE, upper: Int(toY))
        step.position = CGPoint(x: randX, y: randY)
        
        // Physics
        let physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
        physicsBody.dynamic = false
        physicsBody.categoryBitMask = GameScene.ContactCategory.Step.rawValue
        physicsBody.contactTestBitMask = GameScene.ContactCategory.Step.rawValue | GameScene.ContactCategory.Ball.rawValue
        physicsBody.collisionBitMask = GameScene.ContactCategory.Step.rawValue | GameScene.ContactCategory.Ball.rawValue
        step.physicsBody = physicsBody
        
        // Check every 5 seconds if the node should be remvoed
        step.runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock({
                    if step.position.y < abs(self.position.y) {
                        step.removeFromParent()
                    }
                }),
                SKAction.waitForDuration(5000)
            ])
        ))
        
        addChild(step)
    }
    
    func randInRange(lower: Int , upper: Int) -> CGFloat {
        return CGFloat(lower + Int(arc4random_uniform(UInt32(upper - lower + 1))))
    }
    
}