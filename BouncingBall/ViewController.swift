//
//  ViewController.swift
//  BouncingBall
//
//  Created by Simas Abramovas on 3/18/15.
//  Copyright (c) 2015 Simas Abramovas. All rights reserved.
//

import UIKit
import SpriteKit

let TRANSITION_DURATION = 0.3

class ViewController: UIViewController {

    @IBOutlet weak var skView: SKView!

    var shapeNode : SKShapeNode?
    var touchHash : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Debug
        skView.showsPhysics = true
        skView.showsFPS = true
        skView.showsDrawCount = true
        skView.showsNodeCount = true
        skView.showsQuadCount = true
        
        skView.presentScene(GameScene(size: view.frame.size))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Auto layout methods
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willAnimateRotationToInterfaceOrientation(toInterfaceOrientation, duration: duration)
        updateSceneSize(toInterfaceOrientation)
    }

    func updateSceneSize(toInterfaceOrientation: UIInterfaceOrientation) {
        skView.scene?.size = view.frame.size
        if let scene = skView.scene as? Resizable {
            scene.resize()
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

