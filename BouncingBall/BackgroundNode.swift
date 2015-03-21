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
    let MIN_STEP_DISTANCE = 200 as CGFloat
    var curPosition = 0 as CGFloat
    var steps = [SKNode]()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(size: CGSize) {
        super.init(texture: nil, color: SKColor.clearColor(), size: size)
    }
    
    func scrollUp() {
        // ToDo disable existing steps so they don't push the ball down
            // Or place the steps differently / Scroll slower
        if scene is GameScene {
            let ballScene = scene as GameScene?

            if let ballJump = ballScene!.ballJumpHeight {
                curPosition += ballJump
                // Move background up
                addStepsFrom(curPosition);
                runAction(SKAction.moveByX(0, y: -ballJump, duration: SCROLL_DURATION))
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

        // Calc random size
        let randWidth = randInRange(MIN_STEP_WIDTH, upper: MAX_STEP_WIDTH)
        let randSize = CGSize(width: randWidth, height: STEP_HEIGHT)
        let step = SKSpriteNode(color: SKColor.greenColor(), size: randSize)
        step.anchorPoint = CGPoint(x: 0, y: 0)
        
        var randPos: CGPoint?
        var rectMade = (steps.count == 0) ? true : false
        do {
            // Calc random position
            let randX = randInRange(0, upper: Int(scene!.frame.width) - MAX_STEP_WIDTH)
            let randY = randInRange(Int(toY - MIN_STEP_DISTANCE), upper: Int(toY))
            randPos = CGPoint(x: randX, y: randY)
            
            // Check for min distance with existing steps
            let randRect = CGRect(origin: randPos!, size: randSize)
            for node in steps {
                if (minDistance(node.frame, randRect) > 50) {
                    rectMade = true
                    break
                }
            }
        } while (!rectMade)
        step.position = randPos!
        
        // Physics
        let physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(origin: CGPoint(x: 0, y: 0), size: randSize))
        physicsBody.dynamic = false
        physicsBody.categoryBitMask = GameScene.ContactCategory.Step.rawValue
        physicsBody.contactTestBitMask = GameScene.ContactCategory.Step.rawValue | GameScene.ContactCategory.Ball.rawValue
        physicsBody.collisionBitMask = GameScene.ContactCategory.Step.rawValue | GameScene.ContactCategory.Ball.rawValue
        physicsBody.affectedByGravity = false
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
        
        steps += [step]
        addChild(step)
    }
    
    func randInRange(lower: Int , upper: Int) -> CGFloat {
        return CGFloat(lower + Int(arc4random_uniform(UInt32(upper - lower + 1))))
    }
    
    func minDistance(a: CGRect, _ b: CGRect) -> CGFloat {
        let deltaX = b.origin.x - a.origin.x
        let deltaY = b.origin.y - a.origin.y
        let delta = abs(deltaX) > abs(deltaY) ? deltaX : deltaY
        
        var distance: CGFloat = 0
        
        switch (delta >= 0, delta == deltaX) {
        case (true, true)   : distance = b.origin.x - (a.origin.x + a.width)
        case (true, false)  : distance = b.origin.y - (a.origin.y + a.height)
        case (false, true)  : distance = a.origin.x - (b.origin.x + b.width)
        case (false, false) : distance = a.origin.y - (b.origin.y + b.height)
        default: println("error")
        }
        
        return distance
    }
    
}