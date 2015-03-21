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

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    enum Direction {
        case North
        case South
        case East
        case West
    }
    
    var ballJumpHeight : CGFloat?
    var minStepHeight : Int?
    let FLOOR_NAME = "floor_node"
    let MOVEMENT_STEP = 50 as CGFloat
    let MOVEMENT_TIME = 0.2
    let GROW_TIME = 0.1
    let OBSTACLE_WIDTH = 20 as CGFloat
    let COLLISION_SCALE = 0.7 as CGFloat
    let COLLISION_SCALE_DURATION = 0.2
    let ACTION_MOVEMENT = "action_movement"
    
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
    
    override func update(currentTime: NSTimeInterval) {
        // ToDo remove steps which move outside here instead of with an action
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
    
    override func didMoveToView(view: SKView) {
        backgroundNode?.addStepsFrom(ballJumpHeight!)
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
        let floor = SKSpriteNode(color: color, size: size)
        floor.anchorPoint = CGPoint(x: 0, y: 0)
        
        // Physics
        let physicsBody = SKPhysicsBody(edgeLoopFromRect: frame) // use scene frame edges
        physicsBody.dynamic = false
        physicsBody.categoryBitMask = ContactCategory.Floor.rawValue
        physicsBody.contactTestBitMask = ContactCategory.Floor.rawValue | ContactCategory.Ball.rawValue
        physicsBody.collisionBitMask = ContactCategory.Floor.rawValue | ContactCategory.Ball.rawValue
        floor.physicsBody = physicsBody
        floor.name = FLOOR_NAME
        addChild(floor)
    }
    
    func addBackground(color: SKColor, height: CGFloat) {
        backgroundNode = BackgroundNode(size: CGSize(width: frame.width, height: height))
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
        
        ballJumpHeight = position.y
        println("height \(ballJumpHeight)")
        
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
        
        println("Impulse : \(contact.collisionImpulse)")
        if ((bitMaskA == ballCat && bitMaskB == ceilingCat) || (bitMaskB == ballCat && bitMaskA == ceilingCat)) {
            // Ceiling contact
            println("Ceiling contact at \(contact.contactPoint.y)")
            if let bgNode = backgroundNode {
                bgNode.scrollUp()
            }
        } else if ((bitMaskA == ballCat && bitMaskB == stepCat) || (bitMaskA == stepCat && bitMaskB == ballCat)) {
            // Step contact
            var bodyTop = self.convertPoint(contact.bodyA.node!.position, fromNode: backgroundNode!).y
            bodyTop += (bitMaskA == stepCat) ? contact.bodyA.node!.frame.height : contact.bodyB.node!.frame.height
            println("Step contact at \(contact.contactPoint.y) top is at \(bodyTop)")
            pushBallOnContact(contact.contactPoint, bodyTop: bodyTop)
        } else if ((bitMaskA == ballCat && bitMaskB == floorCat) || (bitMaskA == floorCat && bitMaskB == ballCat)) {
            // Floor contact
            println("Floor contact at \(contact.contactPoint.y)")
            if contact.contactPoint.y < 4 {
                ballNode?.physicsBody?.velocity = CGVector(dx: 0, dy: 668.750183105469)
            }
        }
    }
    
    func pushBallOnContact(contactPoint: CGPoint, bodyTop: CGFloat) {
        if contactPoint.y >= bodyTop {
            // Modify velocity if touched the top of the step
            ballNode?.physicsBody?.velocity = CGVector(dx: 0, dy: 668.750183105469)
        } else {
            // Otherwise just remove the x axis velocity
            ballNode?.physicsBody?.velocity = CGVector(dx: 0, dy: ballNode!.physicsBody!.velocity.dy)
        }
    }
    
    func normalize(vector : CGVector) -> CGVector {
        let length = pow(vector.dx, vector.dy)
        return CGVector(dx: vector.dx / length, dy: vector.dy / length)
    }
    
    func multiplyScalar(vector : CGVector, value : CGFloat) -> CGVector {
        return CGVector(dx: vector.dx * value, dy: vector.dy * value)
    }
    
}