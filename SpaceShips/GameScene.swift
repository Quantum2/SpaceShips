//
//  GameScene.swift
//  SpaceShips
//
//  Created by Rafael Francisco on 21/01/15.
//  Copyright (c) 2015 Pixelgrounds. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player:SKSpriteNode = SKSpriteNode()
    var lastYieldTimeInterval:NSTimeInterval = NSTimeInterval()
    var lastUpdateTimerInterval:NSTimeInterval = NSTimeInterval()
    var aliensDestroyed:Int = 0
    
    let alienCategory:UInt32 = 0x1 << 1
    let photonTorpedo:UInt32 = 0x1 << 0
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!";
        myLabel.fontSize = 65;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        
        self.addChild(myLabel)*/
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size:CGSize){
        super.init(size: size)
        self.backgroundColor = SKColor.blackColor()
        player = SKSpriteNode(imageNamed: "shuttle")
        
        player.position = CGPointMake(self.frame.size.width/2, player.size.height/2 + 20)
        
        self.addChild(player)
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
    }
    
    func addAlien(){
        
        var alien:SKSpriteNode = SKSpriteNode(imageNamed: "alien")
        alien.physicsBody = SKPhysicsBody(rectangleOfSize: alien.size)
        alien.physicsBody?.dynamic = true
        
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = photonTorpedo
        alien.physicsBody?.collisionBitMask = 0
        
        let minX = alien.size.width/2
        let maxX = self.frame.size.width - alien.size.width/2
        let rangeX = maxX - minX
        let position:CGFloat = CGFloat(arc4random()) % CGFloat(rangeX) + CGFloat(minX)
        
        alien.position = CGPointMake(position, self.frame.size.height+alien.size.height)
        
        self.addChild(alien)
        
        let minDuration = 2
        let maxDuration = 4
        let rangeDuration = maxDuration - minDuration
        var duration = UInt32(arc4random()) % UInt32(rangeDuration) + UInt32(maxDuration)
        //let duration = Int(arc4random()) % Int(rangeDuration) + Int(minDuration)
        
        var actionArray:NSMutableArray = NSMutableArray()
        actionArray.addObject(SKAction.moveTo(CGPointMake(position, -alien.size.height), duration: NSTimeInterval(duration)))
        actionArray.addObject(SKAction.runBlock({
            var transition:SKTransition = SKTransition.flipHorizontalWithDuration(0.5)
            var gameOverScene:SKScene = GameOverScene(size: self.size, won: false)
            self.view?.presentScene(gameOverScene, transition: transition)
        }))
        actionArray.addObject(SKAction.removeFromParent())
        
        alien.runAction(SKAction.sequence(actionArray))
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate:CFTimeInterval){
        lastYieldTimeInterval += timeSinceLastUpdate
        
        if(lastYieldTimeInterval > 1){
            lastYieldTimeInterval = 0
            addAlien()
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        self.runAction(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
        
        var touch:UITouch = touches.anyObject() as UITouch
        var location:CGPoint = touch.locationInNode(self)
        
        var torpedo:SKSpriteNode = SKSpriteNode(imageNamed: "torpedo")
        torpedo.position = player.position
        
        torpedo.physicsBody = SKPhysicsBody(circleOfRadius: torpedo.size.width/2)
        torpedo.physicsBody?.dynamic = true
        torpedo.physicsBody?.categoryBitMask = photonTorpedo
        torpedo.physicsBody?.contactTestBitMask = alienCategory
        torpedo.physicsBody?.collisionBitMask = 0
        torpedo.physicsBody?.usesPreciseCollisionDetection = true
        
        var offset:CGPoint = vecSub(location, b: torpedo.position)
        
        if(offset.y < 0){
            return
        }
        
        self.addChild(torpedo)
        
        var direction:CGPoint = vecNormalize(offset)
        
        var shotLength:CGPoint = vecMult(direction, b: 1000)
        
        var finalDestination:CGPoint = vecAdd(shotLength, b: torpedo.position)
        
        let velocity = 568/1
        let moveDuration:Float = Float(self.size.width) / Float(velocity)
        
        var actionArray:NSMutableArray = NSMutableArray()
        actionArray.addObject(SKAction.moveTo(finalDestination, duration: NSTimeInterval(moveDuration)))
        actionArray.addObject(SKAction.removeFromParent())
        
        torpedo.runAction(SKAction.sequence(actionArray))
    }
    
    func torpedoDidCollideWithAlien(torpedo:SKSpriteNode, alien:SKSpriteNode){
        println("HIT")
        torpedo.removeFromParent()
        alien.removeFromParent()
        
        aliensDestroyed++
        
        if(aliensDestroyed > 10){
            // Transition to game over page
            var transition:SKTransition = SKTransition.flipHorizontalWithDuration(0.5)
            var gameOverScene:SKScene = GameOverScene(size: self.size, won: true)
            self.view?.presentScene(gameOverScene, transition: transition)
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        if(contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask){
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if((firstBody.categoryBitMask & photonTorpedo) != 0 && (secondBody.categoryBitMask & alienCategory) != 0){
            torpedoDidCollideWithAlien(firstBody.node as SKSpriteNode, alien: secondBody.node as SKSpriteNode)
        }
    }
    
    func vecAdd(a:CGPoint, b:CGPoint)->CGPoint{
        return CGPointMake(a.x + b.x, a.y + b.y)
    }
    
    func vecSub(a:CGPoint, b:CGPoint)->CGPoint{
        return CGPointMake(a.x - b.x, a.y - b.y)
    }
    
    func vecMult(a:CGPoint, b:CGFloat)->CGPoint{
        return CGPointMake(a.x * b, a.y * b)
    }
    
    func vecLength(a:CGPoint)->CGFloat{
        return CGFloat(sqrtf(CFloat(a.x) * CFloat(a.x) + CFloat(a.y) * CFloat(a.y)))
    }
    
    func vecNormalize(a:CGPoint)->CGPoint{
        var length:CGFloat = vecLength(a)
        return CGPointMake(a.x / length, a.y / length)
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        var timeSinceLastUpdate = currentTime - lastUpdateTimerInterval
        lastUpdateTimerInterval = currentTime
        
        if(timeSinceLastUpdate > 1){
            timeSinceLastUpdate = 1/60
            lastUpdateTimerInterval = currentTime
        }
        
        updateWithTimeSinceLastUpdate(timeSinceLastUpdate)
    }
}
