//
//  GameScene.swift
//  stickman
//
//  Created by Izza Khan on 7/3/18.
//  Copyright © 2018 Izza Khan. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var player = SKSpriteNode(imageNamed: "player")
    let joystick = AnalogJoystick(diameter: 80, colors: (UIColor.gray,
                                                         UIColor.gray))
    //var playerPunching:[SKTexture] = []
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        player.position = CGPoint(x: frame.midX, y: frame.midY/1.9)
        player.setScale(1.2)
        addChild(player)
        idleStick()
        joystick.position = CGPoint(x:frame.midX/3, y:frame.midY/3)
        addChild(joystick)
    
        joystick.trackingHandler = { [unowned self] data in
            self.player.position = CGPoint(x: self.player.position.x + (data.velocity.x * 0.15), y: self.player.position.y)
            // Something...
            // data contains angular && velocity (data.angular, data.velocity)
        }
        
    }
    
    func idleStick(){
        
    }
    
    
}
