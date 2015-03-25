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

class GameScene: SKScene, SKPhysicsContactDelegate {
    
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
    var ballNode: SKNode?
    var backgroundNode: BackgroundNode?
    
    enum ContactCategory: UInt32 {
        case Floor   = 1
        case Scene   = 2
        case Ball    = 4
        case Step    = 8
        case Ceiling = 16
    }
    
    // Limitations
    let maxScaleBy = CGFloat(4/5.0)
    let maxImpulse = CGFloat(900)
    let minImpulse = CGFloat(100)
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        scaleMode = .ResizeFill
        physicsWorld.gravity = CGVectorMake(0, -5)
        physicsBody?.categoryBitMask = ContactCategory.Scene.rawValue
        physicsBody?.contactTestBitMask = ContactCategory.Scene.rawValue | ContactCategory.Ball.rawValue
        physicsBody?.collisionBitMask = ContactCategory.Scene.rawValue | ContactCategory.Ball.rawValue
        physicsWorld.contactDelegate = self
    }
    
    override func update(currentTime: NSTimeInterval) {
        // ToDo remove steps which move outside here instead of with an action
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
    
    func addFloor(color: SKColor, size: CGSize) {
        // Add frame node (jump from sides)
        var node = SKSpriteNode(color: SKColor.clearColor(), size: size)
        node.anchorPoint = CGPoint(x: 0, y: 0)
        
        // Physics
        // Extend frame by the floor (prepare for deadly floor)
        let extendedFrame = CGRect(origin: CGPoint(x: frame.origin.x, y: frame.origin.y - size.height),
            size: CGSize(width: frame.width, height: frame.height + size.height))
        var physicsBody = SKPhysicsBody(edgeLoopFromRect: extendedFrame)
        physicsBody.dynamic = false
        node.physicsBody = physicsBody
        addChild(node)
        
        // Add floor node
        node = SKSpriteNode(color: SKColor.redColor(), size: size)
        node.anchorPoint = CGPoint(x: 0, y: 0)
        
        // Physics
        physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
        physicsBody.dynamic = false
        physicsBody.categoryBitMask = ContactCategory.Floor.rawValue
        physicsBody.contactTestBitMask = ContactCategory.Floor.rawValue | ContactCategory.Ball.rawValue
        physicsBody.collisionBitMask = ContactCategory.Floor.rawValue | ContactCategory.Ball.rawValue
        node.physicsBody = physicsBody
        node.name = FLOOR_NAME
        addChild(node)
    }
    
    func addBackground(color: SKColor, height: CGFloat, ceilPos: CGPoint) {
        backgroundNode = BackgroundNode(size: CGSize(width: frame.width, height: height), ceilPos: ceilPos)
        backgroundNode?.anchorPoint = CGPoint(x: 0, y: 0)
        addChild(backgroundNode!)
    }
    
    func addCeiling(size: CGSize, position: CGPoint) {
        let ceiling = SKSpriteNode(color: SKColor.redColor(), size: size)
        ceiling.position = position
        ceiling.anchorPoint = CGPoint(x: 0, y: 0)
        
        // Physics
        let physicsBody = SKPhysicsBody(edgeLoopFromRect: frame) // use scene frame edges
        physicsBody.dynamic = false
        physicsBody.categoryBitMask = ContactCategory.Ceiling.rawValue
        physicsBody.contactTestBitMask = ContactCategory.Ceiling.rawValue | ContactCategory.Ball.rawValue
        physicsBody.collisionBitMask = ContactCategory.Ceiling.rawValue | ContactCategory.Ball.rawValue
        ceiling.physicsBody = physicsBody
        
        addChild(ceiling)
    }
    
    func addBall(color: SKColor, radius: Int, position: CGPoint) {
        let ball = SKShapeNode(circleOfRadius: CGFloat(radius))
        ball.name = name
        // Physics
        let physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(radius))
        physicsBody.restitution = 1
        physicsBody.friction = 0.0
        physicsBody.angularDamping = 0.0
        physicsBody.linearDamping = 0.0
        physicsBody.mass = 0
        physicsBody.dynamic = true
        physicsBody.categoryBitMask = ContactCategory.Ball.rawValue
        physicsBody.contactTestBitMask = ContactCategory.Ball.rawValue | ContactCategory.Floor.rawValue | ContactCategory.Scene.rawValue | ContactCategory.Step.rawValue
        physicsBody.collisionBitMask = ContactCategory.Ball.rawValue | ContactCategory.Floor.rawValue | ContactCategory.Scene.rawValue | ContactCategory.Step.rawValue
        ball.physicsBody = physicsBody
        ball.position = position
        ball.fillColor = color
        addChild(ball)
        
        // Set the main node!
        ballNode = ball
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
            // ToDo runAction(action, withKey: String) -- save the action name to remove it specifically later
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
        let ballCat = ContactCategory.Ball.rawValue
        let stepCat = ContactCategory.Step.rawValue
        let ceilingCat = ContactCategory.Ceiling.rawValue
        let floorCat = ContactCategory.Floor.rawValue
        
        // Remove ball dx velocity
        ballNode?.physicsBody?.velocity = CGVector(dx: 0, dy: ballNode!.physicsBody!.velocity.dy)
        switch (bitMaskA, bitMaskB) {
        case (ballCat, ceilingCat): fallthrough
        case (ceilingCat, ballCat):
            println("Ceiling contact after other: \(otherContact)")
            if !otherContact {
                if let backgroundNode = backgroundNode {
                    // Check if ball going up
                    let ballVelocity = (bitMaskA == ballCat) ? contact.bodyA.velocity : contact.bodyB.velocity
                    if ballVelocity.dy > 0 {
                        backgroundNode.scrollUp()
                    }
                }
            }
        case (ballCat, stepCat): fallthrough
        case (stepCat, ballCat):
            // Step contact
            
            // Check if contacted top
            let stepNode = (bitMaskA == stepCat) ? contact.bodyA.node : contact.bodyB.node
            if let stepNode = stepNode {
                let stepTop = convertPoint(stepNode.position, fromNode: backgroundNode!).y + stepNode.frame.height
                println("Step contact at \(contact.contactPoint.y) top is at \(stepTop)")
                
                // Modify velocity if touched the top of the step
                if contact.contactPoint.y >= stepTop {
                    ballNode?.physicsBody?.velocity = CGVector(dx: 0, dy: frame.height)
                }
            }
        case (ballCat, floorCat): fallthrough
        case (floorCat, ballCat):
            if firstScrollCompleted {
                // Death reached
                println("DEATH")
                view?.presentScene(EndScene(size: frame.size))
            } else {
                // Floor contact
                println("Floor contact at \(contact.contactPoint.y)")
                let floorHeight = (bitMaskA == floorCat) ? contact.bodyA.node?.frame.height : contact.bodyB.node?.frame.height
                ballNode?.physicsBody?.velocity = CGVector(dx: 0, dy: frame.height)
            }
        default:
            println("Other contact!")
            otherContact = true
            return
        }
        otherContact = false
    }
    
    func normalize(vector : CGVector) -> CGVector {
        let length = pow(vector.dx, vector.dy)
        return CGVector(dx: vector.dx / length, dy: vector.dy / length)
    }
    
    func multiplyScalar(vector : CGVector, value : CGFloat) -> CGVector {
        return CGVector(dx: vector.dx * value, dy: vector.dy * value)
    }
    
}