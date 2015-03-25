//
//  EndScene.swift
//  BouncingBall
//
//  Created by Simas Abramovas on 3/25/15.
//  Copyright (c) 2015 Simas Abramovas. All rights reserved.
//

import SpriteKit
import Foundation

class EndScene : SKScene, Resizable {
    
    var endLabel : SKLabelNode?
    var restartLabel : ClickableLabel?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        scaleMode = .AspectFit

        endLabel = SKLabelNode(text: "Game Over...")
        endLabel!.fontName = "Optima-ExtraBlack"
        endLabel!.horizontalAlignmentMode = .Left
        endLabel!.verticalAlignmentMode = .Center
        endLabel!.fontSize = 60
        addChild(endLabel!)
        
        // Restart label
        restartLabel = ClickableLabel(text: "Restart!", began: nil) { () -> () in
            firstScrollCompleted = false
            let doorsOpenX = SKTransition.doorsOpenHorizontalWithDuration(TRANSITION_DURATION)
            self.view?.presentScene(GameScene(size: self.frame.size), transition: doorsOpenX)
        }
        restartLabel!.fontName = "Optima-ExtraBlack"
        restartLabel!.horizontalAlignmentMode = .Left
        restartLabel!.verticalAlignmentMode = .Center
        restartLabel!.fontColor = UIColor.redColor()
        restartLabel!.fontSize = 40
        addChild(restartLabel!)
        
        resize()
    }
    
    func resize() {
        endLabel!.position = CGPoint(x: size.width / 2 - endLabel!.frame.width / 2,
            y: size.height / 2 - endLabel!.frame.height)
        
        restartLabel!.position = CGPoint(x: size.width / 2 - restartLabel!.frame.width / 2,
            y: size.height / 2 - restartLabel!.frame.height / 2 - endLabel!.frame.height * 2)
    }

}