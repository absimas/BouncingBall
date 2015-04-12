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
    let MIN_DISTANCE_BETWEEN_STEPS = 50 as CGFloat
    let MAX_DIFFICULTY = 4
    var curPosition = 0 as CGFloat
    var steps = [SKNode]()
    var scrollCount = 0
    var difficulty = 0
        
    func scrollUp() {
        if let scene = scene as? GameScene {
            if (scrollCount % 3 == 0) {
                difficulty = min(difficulty+1, MAX_DIFFICULTY)
            }
            let ballScene = scene as GameScene?
            let ballJumpHeight = frame.height / 2
            let scrollBy = -ballJumpHeight + scene.size.height * 4.0 / 5.0 - scene.maxStepDistanceFromBall!
            steps.removeAll(keepCapacity: false)
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
        if let scene = scene as? GameScene {
            // Move floor below screen
            if let floorNode = scene.floorNode {
                floorNode.position.y -= floorNode.frame.height
            }
            
            // Prevent ball from contacting the floor
            if let ballNode = scene.ballNode {
                ballNode.physicsBody?.collisionBitMask &= ~FLOOR_CATEGORY
                ballNode.physicsBody?.contactTestBitMask &= ~FLOOR_CATEGORY
            }
        }
    }
    
    func addStepsFrom(y: CGFloat) {
        if let scene = scene as? GameScene {
            let fromY = Int(y - scene.maxStepDistanceFromBall!)
            let toY = Int(y)
            // First add a step that will definitely allow reaching the top
            addRandomStep(toY, toY: toY)
            // Then add other random steps
            for i in difficulty...4 {
                addRandomStep(fromY, toY: toY)
            }
        }
    }
    
    func addRandomStep(fromY: Int, toY: Int) {
        if let scene = scene as? GameScene {
            // Calc random size
            let randWidth = randInRange(scene.minStepWidth, scene.maxStepWidth)
            let randSize = CGSize(width: randWidth, height: STEP_HEIGHT)
            let step = SKSpriteNode(texture: SKTexture(imageNamed: "BrickBlock"), color: UIColor.clearColor(), size: randSize)
            step.anchorPoint = CGPoint(x: 0, y: 0)
            
            var randPos: CGPoint?
            var rectMade = (steps.count == 0) ? true : false
            do {
                // Calc random position
                let randX = randInRange(0, Int(scene.frame.width) - scene.maxStepWidth)
                let randY = randInRange(fromY, toY)
                randPos = CGPoint(x: randX, y: randY)
                rectMade = true
                
                // Check for min distance with existing steps
                let randRect = CGRect(origin: randPos!, size: randSize)
                for node in steps {
                    if (minDistance(node.frame, randRect) < MIN_DISTANCE_BETWEEN_STEPS) {
                        rectMade = false
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
                        }
                    }),
                    SKAction.waitForDuration(5000)
                ])
            ))
            
            steps += [step]
            addChild(step)
        }
    }
    
    func randInRange(lower: Int , _ upper: Int) -> CGFloat {
        return CGFloat(lower + Int(arc4random_uniform(UInt32(upper - lower + 1))))
    }
    
    func minDistance(a: CGRect, _ b: CGRect) -> CGFloat {
        if a.intersects(b) {
            return 0
        }
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