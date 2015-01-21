//
//  GameOverScene.swift
//  SpaceShips
//
//  Created by Rafael Francisco on 21/01/15.
//  Copyright (c) 2015 Pixelgrounds. All rights reserved.
//

import UIKit
import SpriteKit

class GameOverScene: SKScene {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(size:CGSize, won:Bool){
        super.init(size: size)
        
        self.backgroundColor = SKColor.blackColor()
        
        var message:NSString = NSString()
        
        if(won){
            message = "You won !!!"
        }else{
            message = "A ship escaped :("
        }
        
        var label:SKLabelNode = SKLabelNode(fontNamed: "Futura-MediumItalic")
        label.text = message
        label.fontColor = SKColor.whiteColor()
        label.position = CGPointMake(self.size.width/2, self.size.height/2)
        
        self.addChild(label)
        
        self.runAction(SKAction.sequence([SKAction.waitForDuration(4.5), SKAction.runBlock({
            var transition:SKTransition = SKTransition.flipHorizontalWithDuration(0.5)
            var scene:SKScene = GameScene(size: self.size)
            self.view?.presentScene(scene, transition: transition)
        })]))
    }
}
