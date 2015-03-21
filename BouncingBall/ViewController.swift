//
//  ViewController.swift
//  BouncingBall
//
//  Created by Simas Abramovas on 3/18/15.
//  Copyright (c) 2015 Simas Abramovas. All rights reserved.
//

import UIKit
import SpriteKit

// Shift + Cmd + ' = jump and fix next issue

class ViewController: UIViewController {

    @IBOutlet weak var skView: SKView!

    var shapeNode : SKShapeNode?
    var touchHash : Int?
    var scene : GameScene?
    var sceneWidth : CGFloat!
    var sceneHeight : CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Debug
        skView.showsPhysics = true
        skView.showsFPS = true
        skView.showsDrawCount = true
        skView.showsNodeCount = true
        skView.showsQuadCount = true
        
        // Scene
        createSceneInitial()
        
        // Add objects
        scene!.addFloor(SKColor.blackColor(), size: CGSize(width: sceneWidth, height: 20))
        scene!.addBall(SKColor.blueColor(), radius: 30,
                position: CGPoint(x: sceneWidth / 2, y: sceneHeight / 2))
        scene!.addCeiling(CGSize(width: sceneWidth, height: 10),
            position: CGPoint(x: 0, y: sceneHeight * 4 / 5))
        scene!.addBackground(SKColor.clearColor(), height: 5000)
        
        // Animate scene entry
        let doorOpenX = SKTransition.doorsOpenHorizontalWithDuration(10.0)
        skView.presentScene(scene, transition: doorOpenX)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willAnimateRotationToInterfaceOrientation(toInterfaceOrientation, duration: duration)
        updateSceneSize(toInterfaceOrientation)
    }
    
    // Auto layout methods
    func createSceneInitial() {
        scene = GameScene(size: skView.frame.size)
        scene!.scaleMode = .AspectFit
        // Sace scene size to properties
        sceneWidth = view.frame.width
        sceneHeight = view.frame.height
        // Update orientation
        if sceneWidth < sceneHeight {
            updateSceneSize(.Portrait)
        } else {
            updateSceneSize(.LandscapeRight)
        }
    }
    
    func updateSceneSize(toInterfaceOrientation: UIInterfaceOrientation) {
        switch toInterfaceOrientation {
        case .LandscapeLeft: fallthrough
        case .LandscapeRight:
            scene!.size.width = sceneHeight
            scene!.size.height = sceneWidth
            println("scene!.children count = \(scene!.children.count)")
            for node in scene!.children as [SKNode] {
                if let nodeName = node.name {
                    if nodeName == "floor_node" {
                        node.runAction(SKAction.moveTo(CGPoint(x: 0, y: 0), duration: 0))
                    }
                }
            }
        case .Portrait: fallthrough
        case .PortraitUpsideDown:
            scene!.size.width = sceneWidth
            scene!.size.height = sceneHeight
            for node in scene!.children as [SKNode] {
                if let nodeName = node.name {
                    if nodeName == "floor_node" {
                        node.runAction(SKAction.moveTo(CGPoint(x: 0, y: 0), duration: 0))
                    }
                }
            }
        case .Unknown:
            println("Unrecognized orientation!")
        }
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.All.rawValue)
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}

