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
    var playerRightRunFrames: [SKTexture] = []
    var playerLeftRunFrames: [SKTexture] = []
    var leftWall = SKSpriteNode()
    var rightWall = SKSpriteNode()
    let playerMask : UInt32 = 0x1
    let leftWallMask : UInt32 = 0x2
    let rightWallMask: UInt32 = 0x3
    
    //var playerPunching:[SKTexture] = []
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        idleStick()
        animateIdleStick()
        print("HELLO")
        //Initialize the physical properties of the player
        let playerGrav = SKPhysicsBody(rectangleOf: CGSize(width:
            player.size.width/7, height: player.size.height/2), center:CGPoint( x: 7, y:0))
        playerGrav.friction = 0
        playerGrav.affectedByGravity = false
        playerGrav.allowsRotation = false
        playerGrav.restitution = 0
        playerGrav.usesPreciseCollisionDetection = true
        //player.physicsBody = playerGrav
        self.rightRun()
        self.leftRun()
        var movRight: Bool = false
        var movLeft: Bool = false
        setUpBarriers()
        joystick.position = CGPoint(x:frame.midX/3, y:frame.midY/3)
        addChild(joystick)
        //Control what happens when joystick is used
        let idleVel: CGFloat = 0.0000000000000000000
        joystick.trackingHandler = { [unowned self] data in
            let prev: CGFloat = self.player.position.x
            let pos: CGPoint = CGPoint(x: self.player.position.x + (data.velocity.x*0.15), y: self.player.position.y)
           // self.player.physicsBody?.velocity.dx = data.velocity.x
           // self.player.physicsBody?.velocity.dy = 0
            
            if( pos.x == prev || data.velocity.x == idleVel){
                self.player.position = CGPoint(x: prev, y: self.player.position.y)
            }
            else{
                 self.player.position = pos
            }
        
            /*if(prev < self.player.position.x && on == false)
            {
                self.player.removeAction(forKey: "idlePlayer")
                self.animateRightRun()
                on = true
            }*/
            //self.player.removeAllActions()
            if(prev < self.player.position.x && movRight == false){
                print("right")
                movLeft=false
                movRight = true
                self.player.removeAllActions()
                //print(data.velocity.x)
                self.animateRightRun()
                
               
            }
            else if( prev > self.player.position.x && movLeft == false){
                //print("IN MOVING LEFT")
                movRight = false
                movLeft = true
                //self.player.removeAction(forKey: "idlePlayer")
                //self.player.removeAction(forKey: "rightRun")
                self.player.removeAllActions()
                print(data.velocity.x)
                print("left")
                self.animateLeftRun()
                
            }
            if(prev == self.player.position.x || (data.velocity.x * 0.15) == idleVel  )
            {
                movLeft = false
                movRight = false
                 // self.player.removeAction(forKey: "rightRun")
                  self.player.removeAction(forKey: "leftRun")
                //self.player.removeAllActions()
                //print(data.velocity.x)
                //print("velocity is 0")
               // print("prev",prev)
               // print("curr",pos.x)
               // print("player", self.player.position.x)
                self.animateIdleStick()
                
            }
            
        }
        
        joystick.beginHandler = { [unowned self] in
            print("begin handler")
           // self.animateIdleStick()
        }
        
        joystick.stopHandler = { [unowned self] in
            //print("STOP HANDLER")
            self.player.removeAllActions()
            self.animateIdleStick()
        }
        print("AFTER JOYSTICK")
        //Set up bitmasks for each physics body
        //player.physicsBody?.categoryBitMask = playerMask
        rightWall.physicsBody?.categoryBitMask = rightWallMask
        leftWall.physicsBody?.categoryBitMask = leftWallMask
        //player.physicsBody?.contactTestBitMask=leftWallMask | rightWallMask
       // player.physicsBody?.collisionBitMask = leftWallMask | rightWallMask
        physicsWorld.contactDelegate = self
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
    
    func rightRun(){
        //Set up stickman to run in the right direction
        let runAtlas = SKTextureAtlas(named: "RunRight")
        var runFrames: [SKTexture] = []
        let  numImages = 9
        for i in 1...numImages{
            let runFrameName = "RunRight000\(i)"
            runFrames.append(runAtlas.textureNamed(runFrameName))
        }
       
        playerRightRunFrames = runFrames
        //print("set frames")
        let firstFrameTexture = playerRightRunFrames[0]
        
       

    }
    func leftRun(){
        //Set up stickman to run in the left direction
        let runAtlas = SKTextureAtlas(named: "RunLeft")
        var runFrames: [SKTexture] = []
        let  numImages = 9
        for i in 1...numImages{
            let runFrameName = "RunLeft000\(i)"
            runFrames.append(runAtlas.textureNamed(runFrameName))
        }
        playerLeftRunFrames = runFrames
        let firstFrameTexture = playerLeftRunFrames[0]
        player.texture = firstFrameTexture
        
    }
    
    func animateRightRun(){
        print("Animate Right")
        player.isPaused = false
       if(player.action(forKey: "runRight") == nil){
            print("IN RUN RIGHT IN IF")
            player.run(SKAction.repeatForever(
            SKAction.animate(with: playerRightRunFrames, timePerFrame: 0.1,resize:false,restore: false)), withKey: "runRight")
        }
    }
    
    func animateLeftRun(){
        print("Animate Left")
        player.isPaused = false
       // if(player.hasActions() == false){
        if(player.action(forKey: "runLeft") == nil){
            player.run(SKAction.repeatForever(
            SKAction.animate(with: playerLeftRunFrames, timePerFrame:
                0.1, resize:false, restore:false)), withKey:"runLeft")
        }
    }
    func animateIdleStick(){
        //print("idle")
        player.run(SKAction.repeatForever(
            SKAction.animate(with: playerIdleFrames, timePerFrame: 0.1, resize:false, restore: true)), withKey: "idlePlayer")
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
            player.physicsBody?.velocity = CGVector(dx: ((player.physicsBody?.velocity.dx)! * (-1)),dy:0)
        }
        else{
            player.physicsBody?.velocity = CGVector(dx:((player.physicsBody?.velocity.dx)! * (-1)),dy:0)
        }
    
    }
    
    func setUpBarriers(){
        //Set up barriers that player can't pass
        leftWall = SKSpriteNode(color: UIColor.clear, size: CGSize(width: 1, height: frame.height))
        leftWall.position = CGPoint(x: 0, y: 0)
        leftWall.physicsBody = SKPhysicsBody( rectangleOf: leftWall.size)
        leftWall.physicsBody!.isDynamic = false
        leftWall.physicsBody?.restitution=0
        leftWall.physicsBody?.usesPreciseCollisionDetection = true
        leftWall.physicsBody?.affectedByGravity = false
        leftWall.physicsBody?.friction = 0
        addChild(leftWall)
        
        rightWall = SKSpriteNode(color: UIColor.clear, size: CGSize(width: 1, height: frame.height))
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
    }

    
    
    
}
