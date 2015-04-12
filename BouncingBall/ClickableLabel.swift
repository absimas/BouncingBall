//
//  ClickableLabel.swift
//  BouncingBall
//
//  Created by Simas Abramovas on 3/25/15.
//  Copyright (c) 2015 Simas Abramovas. All rights reserved.
//

import SpriteKit
import Foundation

class ClickableLabel : SKLabelNode {
    
    // Optional touch callbacks
    let callbackBegan : (()->())?
    let callbackEnded : (()->())?
    
    // Color variables
    var hue : CGFloat = 0
    var saturation : CGFloat = 0
    var brightness : CGFloat = 0
    var colorAlpha : CGFloat = 0
    var colorInitialized = false
    override var fontColor: UIColor {
        didSet {
            // Fetch info about this new color
            if !colorInitialized {
                if (fontColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &colorAlpha)) {
                    colorInitialized = true
                } else {
                    println("Failed to convert color!")
                }
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(text: String, began: (()->())?, ended: (()->())?) {
        callbackBegan = began
        callbackEnded = ended
        super.init()
        userInteractionEnabled = true
        self.text = text
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        // Darken color
        fontColor = SKColor(hue: hue, saturation: saturation, brightness: brightness, alpha: colorAlpha - 0.3)
        if let callbackBegan = callbackBegan {
            callbackBegan()
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        // Revert to normal
        fontColor = SKColor(hue: hue, saturation: saturation, brightness: brightness, alpha: colorAlpha)
        if let callbackEnded = callbackEnded {
            callbackEnded()
        }
    }
    
}