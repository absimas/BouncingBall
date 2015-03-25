//
//  EndScene.swift
//  BouncingBall
//
//  Created by Simas Abramovas on 3/25/15.
//  Copyright (c) 2015 Simas Abramovas. All rights reserved.
//

import SpriteKit
import Foundation

class EndScene : SKScene {
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        // End label
        var endLabel = SKLabelNode(text: "Game Over...")
        endLabel.fontName = "Optima-ExtraBlack"
        endLabel.horizontalAlignmentMode = .Left
        endLabel.verticalAlignmentMode = .Center
        endLabel.fontSize = 60
        
        endLabel.position = CGPoint(x: size.width / 2 - endLabel.frame.width / 2,
            y: size.height / 2 - endLabel.frame.height)
        let endLabelHeight = endLabel.frame.height
        addChild(endLabel)
        
        // Restart label
        let restartLabel = endLabel.copy() as SKLabelNode
        restartLabel.text = "Restart!"
        restartLabel.fontSize = 40
        restartLabel.position = CGPoint(x: restartLabel.frame.origin.x, y: restartLabel.frame.origin.y + endLabelHeight)
        addChild(restartLabel)
    }

}