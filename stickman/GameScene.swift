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
    var enemyP = SKSpriteNode()
    var up: Bool = false
    var touched: Bool = true
    var kickButton : IKButton = {
        var button = IKButton(imageNamed: "KickButton", buttonAction: {
            animateKick()
        })
        button.zPosition = 1
        return button
    }()
    let joystick = AnalogJoystick(diameter: 80, colors: (UIColor.gray,
                                                UIColor.gray))

    var playerIdleFrames: [SKTexture] = []
    var playerRightRunFrames: [SKTexture] = []
    var playerLeftRunFrames: [SKTexture] = []
    var playerLeftKickFrames: [SKTexture] = []
    var playerJumpFrames: [SKTexture] = []
    var leftWall = SKSpriteNode()
    var rightWall = SKSpriteNode()
    var floor = SKSpriteNode()
    let playerMask : UInt32 = 0x1
    let enemyMask : UInt32 = 0x2
    //let leftWallMask : UInt32 = 0x2
    //let rightWallMask: UInt32 = 0x3
    let floorMask: UInt32 = 0x3
    //var playerPunching:[SKTexture] = []
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        idleStick()
        animateIdleStick()
        //createButtons()
        kickButton.position = CGPoint(x: frame.maxX - frame.maxX/5 , y: frame.midY/3)
       // kickButton.setScale(0.38)
        addChild(kickButton)
        
        
        //Initialize the physical properties of the player
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        let playerGrav = SKPhysicsBody(rectangleOf: CGSize(width:
            player.size.width/7, height: player.size.height/2), center:CGPoint( x: 7, y:8))
        playerGrav.friction = 0
        playerGrav.affectedByGravity = true
        playerGrav.allowsRotation = false
        playerGrav.restitution = 0
        playerGrav.usesPreciseCollisionDetection = true
        player.physicsBody = playerGrav
        self.rightRun()
        self.leftRun()
        self.jump()
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
            //print(data.velocity)
            print(self.touched)
            if( data.velocity.y < 45 && data.velocity.y > 20 && self.up == false){
                self.up = true
                self.touched = false
                //print("inside")
                self.removeAllActions()
                //self.player.run(SKAction.sequence([moveUp,moveDown]))
                //self.player.physicsBody!.applyImpulse(CGVector(dx:0, dy:10))
                //SKAction.wait(forDuration: 3)
                //print("HERE")
                //self.player.physicsBody!.velocity = CGVector(dx:0, dy:0)
                self.physicsWorld.gravity = CGVector(dx: 0, dy: -5)
                self.player.physicsBody!.applyImpulse(CGVector(dx:0, dy:100))
                self.animateJump()
                
            }
            if(self.up == false && self.touched == true && data.velocity.x < 10){
                //self.animateIdleStick()
                //self.animateJump()
               // self.player.removeAllActions()
                //self.player.texture = SKTexture(imageNamed: "fall")
            }
            if( pos.x == prev || data.velocity.x == idleVel){
                self.player.position = CGPoint(x: prev, y: self.player.position.y)
            }
            else{
                 self.player.position = pos
            }
           
            //self.player.physicsBody?.applyImpulse(CGVector(dx: data.velocity.x * 0.15 , dy: 0))
            if(prev < self.player.position.x && movRight == false && self.up == false && self.touched == true ){
                movLeft=false
                movRight = true
                self.player.removeAllActions()
                self.animateRightRun()
            }
            else if( prev > self.player.position.x && movLeft == false && self.up == false &&
                self.touched == true){
                movRight = false
                movLeft = true
                self.player.removeAllActions()
                self.animateLeftRun()
            }
            if(prev == self.player.position.x || (data.velocity.x * 0.15) == idleVel  && self.up == false && self.touched == true){
                movLeft = false
                movRight = false
                self.player.removeAllActions()
                self.animateIdleStick()
            }
        }


        joystick.beginHandler = { [unowned self] in
           // print("begin handler")
           // self.animateIdleStick()
        }
        
        joystick.stopHandler = { [unowned self] in
            self.player.removeAllActions()
            if(self.up == false){
            //self.animateIdleStick()
            }
            else{
            //self.animateJump()
            }
            //self.up = false
            self.animateIdleStick()
        }
        //print("AFTER JOYSTICK")
        //Set up bitmasks for each physics body
        player.physicsBody?.categoryBitMask = playerMask
        //rightWall.physicsBody?.categoryBitMask = rightWallMask
        
        //leftWall.physicsBody?.categoryBitMask = leftWallMask
        enemyP.physicsBody?.categoryBitMask = enemyMask
        player.physicsBody?.contactTestBitMask = enemyMask | floorMask
        player.physicsBody?.collisionBitMask = floorMask
        
       
        physicsWorld.contactDelegate = self
         //self.player.physicsBody!.applyImpulse(CGVector(dx:0, dy:10))
       /*run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addEnemy),
                SKAction.wait(forDuration: 1.0)
                ])
        ))*/
        //addEnemy()
     
        
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
        let runAtlas = SKTextureAtlas(named: "RunRightNew")
        var runFrames: [SKTexture] = []
        let  numImages = 9
        for i in 1...numImages{
            let runFrameName = "RunRightNew000\(i)"
            runFrames.append(runAtlas.textureNamed(runFrameName))
        }
       
        playerRightRunFrames = runFrames
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
    func leftKick(){
        let runAtlas = SKTextureAtlas(named: "kickLeft")
        var runFrames: [SKTexture] = []
        let  numImages = 9
        for i in 1...numImages{
            let runFrameName = "kickLeft000\(i)"
            runFrames.append(runAtlas.textureNamed(runFrameName))
        }
        playerLeftKickFrames = runFrames
        let firstFrameTexture = playerLeftKickFrames[0]
        player.texture = firstFrameTexture
    }
    func jump(){
        let runAtlas = SKTextureAtlas(named: "Jump")
        var runFrames: [SKTexture] = []
        let  numImages = 1
        for i in 1...numImages{
            let runFrameName = "Jump000\(i)"
            runFrames.append(runAtlas.textureNamed(runFrameName))
        }
        playerJumpFrames = runFrames
        let firstFrameTexture = playerJumpFrames[0]
        player.texture = firstFrameTexture
    }
    
    func animateJump(){
        if(player.action(forKey: "jump") == nil){
            player.run(SKAction.repeatForever(SKAction.animate(with: playerJumpFrames, timePerFrame: 0.1, resize:false, restore: false)), withKey: "jump")
        }
   
    }
    
    func animateLeftKick(){
        player.isPaused = false
        if(player.action(forKey: "leftKick") == nil){
            player.run(SKAction.repeatForever(
            SKAction.animate(with: playerLeftKickFrames, timePerFrame: 0.1,resize:false,restore: false)), withKey: "leftKick")
        }
    }
    
    func animateRightRun(){
        player.isPaused = false
       if(player.action(forKey: "runRight") == nil){
            player.run(SKAction.repeatForever(
            SKAction.animate(with: playerRightRunFrames, timePerFrame: 0.1,resize:false,restore: false)), withKey: "runRight")
        }
    }
    
    func animateLeftRun(){
        player.isPaused = false
        //if(player.hasActions() == false){
        if(player.action(forKey: "runLeft") == nil){
            player.run(SKAction.repeatForever(
            SKAction.animate(with: playerLeftRunFrames, timePerFrame:
                0.1, resize:false, restore:false)), withKey:"runLeft")
        }
    }
    func animateIdleStick(){
        player.run(SKAction.repeatForever(
            SKAction.animate(with: playerIdleFrames, timePerFrame: 0.1, resize:false, restore: true)), withKey: "idlePlayer")
    }
    
   func didBegin(_ contact: SKPhysicsContact){
        //Identify which object have come in contact
        var firstObj: SKPhysicsBody
        var secondObj: SKPhysicsBody
        
        if (contact.bodyA.contactTestBitMask < contact.bodyB.contactTestBitMask) {
            firstObj = contact.bodyA
            secondObj = contact.bodyB
        }
        else{
            firstObj = contact.bodyB
            secondObj = contact.bodyA
        }
        if (firstObj.contactTestBitMask == playerMask && secondObj.contactTestBitMask == enemyMask){

            player.physicsBody?.velocity = CGVector(dx: 0,dy: 0)
            enemyP.removeAllActions()
            enemyP.removeFromParent()
            //self.up = false
        }
        else{
            //print(firstObj.collisionBitMask)
            //print(secondObj.collisionBitMask)
            enemyP.removeFromParent()
            /*player.physicsBody?.velocity = CGVector(dx:0,dy:(player.physicsBody?.velocity.dy)! * (-1))*/
           
            //player.removeAllActions()
            if(self.touched == false){
                //animateIdleStick()
            }
            up = false
            self.touched = true
            
        }
    
    }
    
    func setUpBarriers(){
        floor = SKSpriteNode(color: UIColor.white, size: CGSize(width:frame.width*2
            , height: 1))
        floor.position.y = player.position.y/2 + 4
        floor.physicsBody = SKPhysicsBody( rectangleOf: floor.size)
        floor.physicsBody!.isDynamic = false
        floor.physicsBody!.restitution = 0
        floor.physicsBody!.usesPreciseCollisionDetection = true
        floor.physicsBody!.contactTestBitMask = playerMask
        floor.physicsBody!.collisionBitMask = playerMask
        floor.physicsBody!.categoryBitMask = floorMask
        addChild(floor)
        
        let xRange = SKRange(lowerLimit: leftWall.position.x + 15,upperLimit: frame.maxX - 30)
        let yRange = SKRange(lowerLimit: floor.position.y,upperLimit:size.height)
        player.constraints = [SKConstraint.positionX(xRange,y:yRange)]

    }
    
    func randomRange(min: CGFloat, max: CGFloat) -> CGFloat {
        assert(min < max)
        return CGFloat(arc4random()) / 0xFFFFFFFF * (max - min) + min
    }

    func addEnemy(){
        let enemy = SKSpriteNode(imageNamed: "playa")
       // enemy.physicsBody = SKPhysicsBody.init(rectangleOf:enemy.size)
        enemy.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width:
            player.size.width/7, height: player.size.height/2), center:CGPoint( x: 7, y:0))
        enemy.setScale(0.5)
        enemy.physicsBody?.isDynamic = true
        enemy.physicsBody?.affectedByGravity = true
        enemy.physicsBody?.friction = 0
        enemy.physicsBody?.restitution = 0
        //enemy.physicsBody?.mass = 1
       
       
        let initEnPosY = randomRange(min: frame.minY, max: frame.maxY)
        let initEnPosX = randomRange(min: frame.midX, max: frame.maxX)
        enemy.position = CGPoint(x: frame.maxX + enemy.size.width/2 , y: frame.maxY)
       // enemy.position = CGPoint(x: frame.midX + 100 , y: initEnPosY)
        addChild(enemy)
        
        enemy.physicsBody?.applyImpulse(CGVector(dx: -50, dy: -50))
   
        let yRange = SKRange(lowerLimit: frame.midY/1.9 , upperLimit: initEnPosY)
        enemy.constraints = [SKConstraint.positionY(yRange)]
        
        let moveToPlayer = SKAction.move(to: CGPoint(x: initEnPosX , y: player.position.y) , duration: 1)
        let moveAway = SKAction.move(to: CGPoint(x: frame.minX - enemy.size.width/2,
                                                 y: player.position.y), duration: 1)
      //  CGPoint(x: frame.midX, y: frame.midY/1.9)
        let actionMoveDone = SKAction.removeFromParent()
        //enemy.run(moveToPlayer)
      // enemy.run(SKAction.sequence([moveToPlayer,moveAway,actionMoveDone]))
        enemyP = enemy
        // print(enemyP.position.x.distance(to: player.position.x))
        //enemyP.physicsBody?.categoryBitMask = enemyMask
       // enemyP.physicsBody?.collisionBitMask = playerMask
        player.physicsBody?.contactTestBitMask = enemyMask
       // player.physicsBody?.collisionBitMask = enemyMask
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesBegan(touches, with: event)
    }
    
    func createButtons(){
        let kickButton = SKSpriteNode(imageNamed: "KickButton")
        kickButton.position = CGPoint(x: frame.maxX - frame.maxX/5 , y: frame.midY/3)
        kickButton.setScale(0.38)
        kickButton.name = "kickButton"
        addChild(kickButton)
    }
    
    
    

    
    
    
}
