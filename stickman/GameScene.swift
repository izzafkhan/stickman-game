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
    
    //var playerPunching:[SKTexture] = []
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        player.position = CGPoint(x: frame.midX, y: frame.midY/1.9)
        player.setScale(1.2)
        addChild(player)
        idleStick()
    }
    
    func idleStick(){
        
    }
    
    
}
