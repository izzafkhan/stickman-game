//
//  GameScene.swift
//  stickman
//
//  Created by Izza Khan on 7/3/18.
//  Copyright © 2018 Izza Khan. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player = SKSpriteNode()
    let joystick = AnalogJoystick(diameter: 80, colors: (UIColor.gray,
                                                UIColor.gray))
    var playerIdleFrames: [SKTexture] = []
    let playerMask : UInt32 = 0x1
    let leftWallMask : UInt32 = 0x2
    let rightWallMask: UInt32 = 0x3
    
    //var playerPunching:[SKTexture] = []
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        idleStick()
        animateIdleStick()
        
        //Initialize the physical properties of the player
        let playerGrav = SKPhysicsBody(rectangleOf: CGSize(width:
            player.size.width/7, height: player.size.height/2), center:CGPoint( x: 7, y:0))
        playerGrav.friction = 0
        playerGrav.affectedByGravity = false
        playerGrav.allowsRotation = false
        playerGrav.restitution = 0
        player.physicsBody = playerGrav
        
        
        player.physicsBody?.usesPreciseCollisionDetection = true

        //Set up barriers that player can't pass
        let leftWall = SKSpriteNode(color: UIColor.clear, size: CGSize(width: 1, height: frame.height))
        leftWall.position = CGPoint(x: 0, y: 0)
        leftWall.physicsBody = SKPhysicsBody( rectangleOf: leftWall.size)
        leftWall.physicsBody!.isDynamic = false
        leftWall.physicsBody?.restitution=0
        leftWall.physicsBody?.usesPreciseCollisionDetection = true
        leftWall.physicsBody?.affectedByGravity = false
        leftWall.physicsBody?.friction = 0
        addChild(leftWall)
        
        let rightWall = SKSpriteNode(color: UIColor.clear, size: CGSize(width: 1, height: frame.height))
        rightWall.position = CGPoint(x: frame.maxX, y: 0)
        rightWall.physicsBody = SKPhysicsBody( rectangleOf: rightWall.size)
        rightWall.physicsBody!.isDynamic = false
        rightWall.physicsBody?.usesPreciseCollisionDetection = true
        rightWall.physicsBody?.restitution=0
        rightWall.physicsBody?.affectedByGravity = false
        rightWall.physicsBody?.friction = 0
        addChild(rightWall)
 
        let xRange = SKRange(lowerLimit:0,upperLimit: rightWall.position.x)
        let yRange = SKRange(lowerLimit:0,upperLimit:size.height)
        player.constraints = [SKConstraint.positionX(xRange,y:yRange)]
 
        
        joystick.position = CGPoint(x:frame.midX/3, y:frame.midY/3)
        addChild(joystick)
        //Control what happens when joystick is used
        joystick.trackingHandler = { [unowned self] data in
        self.player.position = CGPoint(x: self.player.position.x + (data.velocity.x*0.15), y: self.player.position.y)
        }
     
        //Set up bitmasks for each physics body
        player.physicsBody?.categoryBitMask = playerMask
        rightWall.physicsBody?.categoryBitMask = rightWallMask
        leftWall.physicsBody?.categoryBitMask = leftWallMask
        player.physicsBody?.contactTestBitMask=leftWallMask | rightWallMask
        player.physicsBody?.collisionBitMask = leftWallMask | rightWallMask
        physicsWorld.contactDelegate = self
        let maxSpeed : CGFloat = 1.0
        if((player.physicsBody?.velocity.dx)! >= maxSpeed){
            print("IN MAZ SPEED")
            print( (player.physicsBody?.velocity.dx)!)
            player.physicsBody?.velocity = CGVector(dx:0,dy:0)
            
        }
    
    }
    func idleStick(){
        //Set up stickman at idle position
        let idleAtlas = SKTextureAtlas(named: "IdleSize")
        var idleFrames: [SKTexture] = []
        let numImages = 6
        for i in 1...numImages{
            let idleFrameName = "idle000\(i)"
            idleFrames.append(idleAtlas.textureNamed(idleFrameName))
        }
        playerIdleFrames = idleFrames
        
        let firstFrameTexture = playerIdleFrames[0]
        player = SKSpriteNode(texture: firstFrameTexture)
        player.position = CGPoint(x: frame.midX, y: frame.midY/1.9)
        player.setScale(0.5)
        addChild(player)
    }
    
    func animateIdleStick(){
        player.run(SKAction.repeatForever(
        SKAction.animate(with: playerIdleFrames, timePerFrame: 0.1, resize:false,
            restore: true)), withKey: "idlePlayer")
    }
    
   func didBegin(_ contact: SKPhysicsContact){
        //Identify which object have come in contact
        var firstObj: SKPhysicsBody
        var secondObj: SKPhysicsBody
        
        if(contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
            firstObj = contact.bodyA
            secondObj = contact.bodyB
        }
        else{
            firstObj = contact.bodyB
            secondObj = contact.bodyA
        }
        if (firstObj.categoryBitMask == playerMask && secondObj.categoryBitMask == leftWallMask){
            //print("LEFT WALL")
            player.physicsBody?.velocity = CGVector(dx: 0, dy:0)
        }
        else{
             //print("RIGHT WALL")
            player.physicsBody?.velocity = CGVector(dx:((player.physicsBody?.velocity.dx)! * (-1)),dy:0)
        }
    
    }

    
    
    
}
