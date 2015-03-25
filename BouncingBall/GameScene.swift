//
//  GameScene.swift
//  BouncingBall
//
//  Created by Simas Abramovas on 3/18/15.
//  Copyright (c) 2015 Simas Abramovas. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit
import GLKit

let FLOOR_NAME = "floor_node"
let SCENE_CATEGORY =    0x1 << 1 as UInt32
let FLOOR_CATEGORY =    0x1 << 2 as UInt32
let CEILING_CATEGORY =  0x1 << 3 as UInt32
let STEP_CATEGORY =     0x1 << 4 as UInt32
let BALL_CATEGORY =     0x1 << 5 as UInt32

class GameScene: SKScene, SKPhysicsContactDelegate, Resizable {
    
    enum Direction {
        case North
        case South
        case East
        case West
    }
    
    var minStepHeight : Int?
    let MOVEMENT_STEP = 50 as CGFloat
    let MOVEMENT_TIME = 0.2
    let GROW_TIME = 0.1
    let OBSTACLE_WIDTH = 20 as CGFloat
    let COLLISION_SCALE = 0.7 as CGFloat
    let COLLISION_SCALE_DURATION = 0.2
    let ACTION_MOVEMENT = "action_movement"
    
    var otherContact = false
    
    // Limits
    let maxScaleBy = 4/5.0 as CGFloat
    let maxImpulse = 900 as CGFloat
    let minImpulse = 100 as CGFloat
    let backgroundHeight = 5000 as CGFloat
    
    // Nodes
    var backgroundNode: BackgroundNode?
    var floorNode: SKSpriteNode?
    var ceilingNode: SKSpriteNode?
    var boundingNode: SKSpriteNode?
    var ballNode: SKShapeNode?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        scaleMode = .AspectFit
        physicsWorld.gravity = CGVectorMake(0, -5)
        physicsWorld.contactDelegate = self
        
        physicsBody?.categoryBitMask = SCENE_CATEGORY
        physicsBody?.contactTestBitMask = SCENE_CATEGORY | BALL_CATEGORY
        physicsBody?.collisionBitMask = SCENE_CATEGORY | BALL_CATEGORY
        
        
        // Init nodes
        addFloor()
        addBall(SKColor.blueColor(), radius: 30,
            position: CGPoint(x: size.width / 2 - 30, y: 0 + 30 * 2 + 10))
        addCeiling()
        addBackground()
        
        resize()
    }

    override func didMoveToView(view: SKView) {
        backgroundNode?.addStepsFrom(view.frame.height / 2)
    }
    
    // ToDo anchor on the bottom of the ball? so it move up when Y axis is scaled
    func squashNode(node: SKNode, collisionImpulse: CGFloat) {
        if collisionImpulse < minImpulse {
            return
        }
        var impulse = max(collisionImpulse, maxImpulse)
        
        let xTo = 1 + (impulse / 9000)
        let yTo = 1 - (impulse / 9000)
        let interval = 0.2 - (impulse / 9000)
        
        var actions = [SKAction]();
        actions.append(SKAction.scaleXBy(xTo, y: yTo, duration: NSTimeInterval(interval)))
        actions.append(SKAction.scaleXBy(1/xTo, y: 1/yTo, duration: NSTimeInterval(interval)))
        let sequence = SKAction.sequence(actions);
        
        node.runAction(sequence)
    }
    
    func addFloor() {
        // Bounding Node
        boundingNode = SKSpriteNode()
        boundingNode!.color = SKColor.clearColor()
        boundingNode!.anchorPoint = CGPoint(x: 0, y: 0)
        addChild(boundingNode!)
        
        // Floor Node
        floorNode = SKSpriteNode()
        floorNode!.color = SKColor.redColor()
        floorNode!.anchorPoint = CGPoint(x: 0, y: 0)
        floorNode!.name = FLOOR_NAME
        addChild(floorNode!)
    }
    
    func addBackground() {
        backgroundNode = BackgroundNode()
        backgroundNode!.anchorPoint = CGPoint(x: 0, y: 0)
        backgroundNode!.color = SKColor.clearColor()
        addChild(backgroundNode!)
    }
    
    func addCeiling() {
        ceilingNode = SKSpriteNode()
        ceilingNode!.color = SKColor.redColor()
        ceilingNode!.anchorPoint = CGPoint(x: 0, y: 0)
        addChild(ceilingNode!)
    }
    
    func addBall(color: SKColor, radius: Int, position: CGPoint) {
        ballNode = SKShapeNode(circleOfRadius: CGFloat(radius))
        ballNode!.name = name
        // Physics
        let physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(radius))
        physicsBody.restitution = 1
        physicsBody.friction = 0.0
        physicsBody.angularDamping = 0.0
        physicsBody.linearDamping = 0.0
        physicsBody.mass = 0
        physicsBody.dynamic = true
        physicsBody.categoryBitMask = BALL_CATEGORY
        physicsBody.contactTestBitMask = BALL_CATEGORY | FLOOR_CATEGORY | SCENE_CATEGORY | STEP_CATEGORY
        physicsBody.collisionBitMask = BALL_CATEGORY | FLOOR_CATEGORY | SCENE_CATEGORY | STEP_CATEGORY
        ballNode!.physicsBody = physicsBody
        ballNode!.position = position
        ballNode!.fillColor = color
        addChild(ballNode!)
    }
    
    func increaseInDuration(node: SKNode, duration: Double) {
        node.runAction(SKAction.scaleBy(1.04, duration: duration))
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        // Select 1st touch
        var touch = touches.allObjects[0] as UITouch
        
        // Find the direction (the furthest point from the mainNode)
        let direction = findDirection(ballNode!.position, touchPos: touch.locationInNode(self))
        
        var action: SKAction?
        switch (direction) {
        case .East:
            action = SKAction.moveByX(-MOVEMENT_STEP, y: 0, duration: MOVEMENT_TIME)
        case .West:
            action = SKAction.moveByX(MOVEMENT_STEP, y: 0, duration: MOVEMENT_TIME)
        default:
            fatalError("Unrecognized direction!")
        }
        
        if let myAction = action {
            ballNode!.runAction(SKAction.repeatActionForever(myAction), withKey: ACTION_MOVEMENT)
        }
    }
    
    func findDirection(mainPos: CGPoint, touchPos: CGPoint) -> Direction {
        // East or West
        let diff = touchPos.x - mainPos.x
        if abs(diff) != diff {
            // touchPos.x < nodePos.x => East
            return Direction.East
        } else {
            return Direction.West
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        ballNode!.removeActionForKey(ACTION_MOVEMENT)
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        touchesEnded(touches, withEvent: event)
    }
    
    // Contact delegate
    func didBeginContact(contact: SKPhysicsContact) {
        let bitMaskA = contact.bodyA.categoryBitMask
        let bitMaskB = contact.bodyB.categoryBitMask
        
        // Remove ball dx velocity
        ballNode?.physicsBody?.velocity = CGVector(dx: 0, dy: ballNode!.physicsBody!.velocity.dy)
        switch (bitMaskA, bitMaskB) {
        case (BALL_CATEGORY, CEILING_CATEGORY): fallthrough
        case (CEILING_CATEGORY, BALL_CATEGORY):
            println("Ceiling contact after other: \(otherContact)")
            if !otherContact {
                if let backgroundNode = backgroundNode {
                    // Check if ball going up
                    let ballVelocity = (bitMaskA == BALL_CATEGORY) ? contact.bodyA.velocity : contact.bodyB.velocity
                    if ballVelocity.dy > 0 {
                        backgroundNode.scrollUp()
                    }
                }
            }
        case (BALL_CATEGORY, STEP_CATEGORY): fallthrough
        case (STEP_CATEGORY, BALL_CATEGORY):
            // Step contact
            
            // Check if contacted top
            let stepNode = (bitMaskA == STEP_CATEGORY) ? contact.bodyA.node : contact.bodyB.node
            if let stepNode = stepNode {
                let stepTop = convertPoint(stepNode.position, fromNode: backgroundNode!).y + stepNode.frame.height
                println("Step contact at \(contact.contactPoint.y) top is at \(stepTop)")
                
                // Modify velocity if touched the top of the step
                if contact.contactPoint.y >= stepTop {
                    ballNode?.physicsBody?.velocity = CGVector(dx: 0, dy: frame.height)
                }
            }
        case (BALL_CATEGORY, FLOOR_CATEGORY): fallthrough
        case (FLOOR_CATEGORY, BALL_CATEGORY):
            if firstScrollCompleted {
                // Death reached
                let doorsCloseX = SKTransition.doorsCloseHorizontalWithDuration(TRANSITION_DURATION)
                view?.presentScene(EndScene(size: frame.size), transition: doorsCloseX)
            } else {
                // Floor contact
                println("Floor contact at \(contact.contactPoint.y)")
                let floorHeight = (bitMaskA == FLOOR_CATEGORY) ? contact.bodyA.node?.frame.height : contact.bodyB.node?.frame.height
                ballNode?.physicsBody?.velocity = CGVector(dx: 0, dy: frame.height)
            }
        default:
            println("Other contact!")
            otherContact = true
            return
        }
        otherContact = false
    }
    
    func resize() {
        // Ceiling
        ceilingNode!.size = CGSize(width: frame.width, height: 5)
        ceilingNode!.position = CGPoint(x: 0, y: frame.height * 4.0 / 5.0) // ToDo don't hardcode
        let ceilingCenter = CGPoint(x: ceilingNode!.size.width / 2, y: ceilingNode!.size.height / 2)
        var physicsBody = SKPhysicsBody(rectangleOfSize: ceilingNode!.size, center: ceilingCenter)
        physicsBody.dynamic = false
        physicsBody.categoryBitMask = CEILING_CATEGORY
        physicsBody.contactTestBitMask = CEILING_CATEGORY | BALL_CATEGORY
        physicsBody.collisionBitMask = CEILING_CATEGORY | BALL_CATEGORY
        ceilingNode!.physicsBody = physicsBody
        
        // Background
        backgroundNode?.size = CGSize(width: frame.width, height: backgroundHeight)
        
        
        // Floor
        floorNode!.size = CGSize(width: frame.width, height: 20)
        // Prep Physics
        physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(origin: CGPoint(x: 0, y: 0), size: floorNode!.size))
        physicsBody.dynamic = false
        physicsBody.categoryBitMask = FLOOR_CATEGORY
        physicsBody.contactTestBitMask = FLOOR_CATEGORY | BALL_CATEGORY
        physicsBody.collisionBitMask = FLOOR_CATEGORY | BALL_CATEGORY
        floorNode!.physicsBody = physicsBody
        
        // Bounds
        boundingNode!.size = frame.size
        // Prep physics // Extend frame by floor's height (prepare for deadly floor)
        let extendedFrame = CGRect(origin: CGPoint(x: frame.origin.x, y: frame.origin.y - floorNode!.size.height),
            size: CGSize(width: frame.width, height: frame.height + floorNode!.size.height))
        physicsBody = SKPhysicsBody(edgeLoopFromRect: extendedFrame)
        physicsBody.dynamic = false
        boundingNode!.physicsBody = physicsBody
    
        
        
    }
    
}