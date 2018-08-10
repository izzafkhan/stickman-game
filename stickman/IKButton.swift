//
//  File.swift
//  stickman
//
//  Created by Izza Khan on 7/26/18.
//  Copyright © 2018 Izza Khan. All rights reserved.
//

import SpriteKit

class IKButton: SKNode{
    var button: SKSpriteNode
    private var mask: SKSpriteNode
    private var cropNode: SKCropNode
    private var action: () -> Void
    var isEnabled = true
    var kickPressed: Bool = false
    init(imageNamed: String, buttonAction: @escaping () -> Void){
        button = SKSpriteNode(imageNamed: imageNamed)
        
        button.alpha = 0.7
        button.setScale(0.5)
       // button.size.width = button.size.width/2
       // button.size.height = button.size.height / 2.5
       // button.size.width = button.size.width / 2.5
        mask = SKSpriteNode(color: SKColor.black, size: button.size)
        //mask.setScale(0.38)
        //mask.size.height = mask.size.height/3
        //mask.size.width = mask.size.width/3
        mask.alpha = 0.0
        cropNode = SKCropNode()
        cropNode.maskNode = button
        cropNode.zPosition = 3
        cropNode.addChild(mask)
        action = buttonAction
        
        super.init()
        isUserInteractionEnabled = true
        setUpNodes()
        addNodes()
        // addChild(SKSpriteNode(color: UIColor.black, size: button.frame.size))
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setUpNodes(){
        button.zPosition = 0
    }
    
    func addNodes(){
        addChild(button)
        addChild(cropNode)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(isEnabled == true){
            kickPressed = true
            mask.alpha = 0.5
            run(SKAction.scale(by: 1.05, duration: 0.05))
            run(SKAction.scale(by: 0.95, duration: 0.05))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (isEnabled == true){
            kickPressed = true
            for touch in touches{
                let location: CGPoint = touch.location(in: self)
                if (button.contains(location)){
                    mask.alpha = 0.5
                }
                else{
                    mask.alpha = 0.0
                }
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(isEnabled == true){
            for touch in touches{
                kickPressed = false
                let location: CGPoint = touch.location(in: self)
                if button.contains(location){
                    disable()
                    action()
                    run(SKAction.sequence([SKAction.wait(forDuration: 0.1), SKAction.run({
                       self.enable()
                    })]))
                }
            }
        }
    }
    func disable(){
        isEnabled = false
        mask.alpha = 0.3
        button.alpha = 0.6
       
    }
    
    func enable(){
        isEnabled = true
        mask.alpha = 0.0
        button.alpha = 0.7
    }
}
