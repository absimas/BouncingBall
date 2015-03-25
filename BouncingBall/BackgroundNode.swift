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

var firstScrollCompleted = false

class BackgroundNode: SKSpriteNode {
    
    let SCROLL_DURATION = 0.5
    let STEP_HEIGHT = CGFloat(20)
    let MIN_STEP_WIDTH = 15
    let MAX_STEP_WIDTH = 60
    let MIN_STEP_DISTANCE = 200 as CGFloat
    var curPosition = 0 as CGFloat
    var steps = [SKNode]()
    var scrollCount = 0
    var difficulty = 0
    
    func scrollUp() {
        if scene is GameScene {
            if (scrollCount % 3 == 0) {
                ++difficulty
            }
            let ballScene = scene as GameScene?
            let ballJumpHeight = frame.height / 2
            let scrollBy = -ballJumpHeight + scene!.size.height * 4.0 / 5.0 - MIN_STEP_DISTANCE
            addStepsFrom(ballJumpHeight)
    
            runAction(SKAction.sequence([
                SKAction.runBlock {
                    // Hide the floor at first scroll
                    if !firstScrollCompleted {
                        self.makeFloorDeadly()
                        firstScrollCompleted = true
                    }
                    
                    // Disable interactivity with steps until scene animation is done
                    for step in self.steps {
                        step.physicsBody!.categoryBitMask = 0
                    }
                },
                SKAction.moveByX(0, y: scrollBy, duration: SCROLL_DURATION),
                SKAction.runBlock {
                    // Disable interactivity with steps until scene animation is done
                    for step in self.steps {
                        step.physicsBody!.categoryBitMask = STEP_CATEGORY
                    }
                }
            ]))
            ++scrollCount
        }
    }
    
    func makeFloorDeadly() {
        let floorNode = scene?.childNodeWithName(FLOOR_NAME)
        if let floorNode = floorNode {
            floorNode.position.y -= floorNode.frame.height
        }
    }
    
    func addStepsFrom(y: CGFloat) {
        for i in difficulty...5 {
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
        physicsBody.categoryBitMask = STEP_CATEGORY
        physicsBody.contactTestBitMask = STEP_CATEGORY | BALL_CATEGORY
        physicsBody.collisionBitMask = STEP_CATEGORY | BALL_CATEGORY
        physicsBody.affectedByGravity = false
        step.physicsBody = physicsBody
        
        // Check every 5 seconds if the node should be remvoed
        step.runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock({
                    // Remove node if it becomes invisible
                    if step.position.y < abs(self.position.y) {
                        // Remove from parent node
                        step.removeFromParent()
                        
                        let index = find(self.steps, step)
                        if let index = index {
                            self.steps.removeAtIndex(index)
                        }
                        // Remove from array
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