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
        endLabel!.verticalAlignmentMode = .Bottom
        // 60 or fit to width
        endLabel!.fontSize = 60
        while (endLabel?.frame.width > frame.width) {
            --endLabel!.fontSize
        }
        addChild(endLabel!)
        
        // Restart label
        restartLabel = ClickableLabel(text: "Restart!", began: nil) { () -> () in
            firstScrollCompleted = false
            let doorsOpenX = SKTransition.doorsOpenHorizontalWithDuration(TRANSITION_DURATION)
            self.view?.presentScene(GameScene(size: self.size), transition: doorsOpenX)
        }
        restartLabel!.fontName = "Optima-ExtraBlack"
        restartLabel!.horizontalAlignmentMode = .Left
        restartLabel!.verticalAlignmentMode = .Bottom
        restartLabel!.fontColor = UIColor.redColor()
        // 40 or fit to width
        restartLabel!.fontSize = 60
        while (restartLabel?.frame.width > frame.width) {
            --restartLabel!.fontSize
        }
        addChild(restartLabel!)
        
        resize()
    }
    
    func resize() {
        if let endLabel = endLabel {
            endLabel.position = CGPoint(x: size.width / 2 - endLabel.frame.width / 2,
                y: size.height / 2 - endLabel.frame.size.height / 2)
            
            if let restartLabel = restartLabel {
                restartLabel.position = CGPoint(x: size.width / 2 - restartLabel.frame.width / 2,
                    y: size.height / 2 - restartLabel.frame.height / 2 - endLabel.frame.height * 2)
            }
        }
    }

}