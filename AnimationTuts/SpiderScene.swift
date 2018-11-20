//
//  SpiderScene.swift
//  MaFirstGame
//
//  Created by Ganesh Arora on 13/09/18.
//  Copyright © 2018 Ganesh Arora. All rights reserved.
//

import UIKit
import GameplayKit
import SpriteKit


class SpiderScene: SKScene {
    
    var gameOverNode: SKLabelNode? = nil
    
    let removeEnemyActionkey = "Move_Enemey_down"
    
    let noCategory: UInt32 = 0
    
    let accelearation = 0.9
    
    let playerCatagorie: UInt32 = 0b1 << 1
    let objectCatagorie: UInt32 = 0b1 << 2
    let lazerCategory: UInt32 = 0b1 << 3
    
    private var spiderNode : SKSpriteNode?
    private var playerNode : SKSpriteNode?
    private var objectNode : SKSpriteNode?
    
    var lazerSpawnRate : TimeInterval = 0.5
    var lastTimeIntervel : TimeInterval = 0.0
    var currentRate : TimeInterval = 0.0
    
    var moveVerticalTime = 28.0
    
    let spiderNodes: NSMutableArray = NSMutableArray()
    
    override func didMove(to view: SKView) {
        //Setup scene's physics body (setup the walls)
        super.didMove(to: view)
        self.physicsWorld.contactDelegate = self
        view.showsPhysics = true
        self.physicsBody?.isDynamic = false
        self.physicsBody?.affectedByGravity = false
        physicsWorld.gravity = CGVector.init(dx: 0, dy: -5)
       // self.backgroundColor = SKColor.red
        
        self.addPlayer()
        addPanningToPlayer()
        
        //  self.addNodes(count: 20)
        
    }
    
    func addPanningToPlayer() {
//        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("handlePanFrom:"))
//        self.view!.addGestureRecognizer(gestureRecognizer)
    }
    
    
    func addEnemyNode()  {
      //  let enemyScene = SKScene(fileNamed: "Enemey")
        objectNode = childNode(withName: "enemy") as? SKSpriteNode
        objectNode?.physicsBody?.categoryBitMask = objectCatagorie
        objectNode?.physicsBody?.collisionBitMask = lazerCategory
       // objectNode?.move(toParent: self)
        
    }
    
    func addAndRunActions() {
        
        let moveActionLeft: SKAction = SKAction.moveBy(x: 200, y: 0, duration: 0.868)
        moveActionLeft.timingMode = .easeInEaseOut
        
        let reposition = SKAction.move(to: CGPoint.init(x: -108.3, y: 500), duration: 0)
        
        let moveActionRight: SKAction = moveActionLeft.reversed()
        
        let leftRightActionSequesce: SKAction  = SKAction.sequence([moveActionLeft,moveActionRight])
        
        let leftRightActionForever : SKAction = SKAction.repeatForever(leftRightActionSequesce)
        
        moveVerticalTime = moveVerticalTime*accelearation
        
        let moveVerticallyDown: SKAction = SKAction.moveBy(x: 0, y: -1265, duration: moveVerticalTime)
        
        let completeActionSequence: SKAction = SKAction.group([reposition,moveVerticallyDown,leftRightActionForever])
        
        self.objectNode!.run(completeActionSequence, withKey: removeEnemyActionkey)
    }
    func addEnemyNodeWithActions()  {
        addEnemyNode()
        self.addAndRunActions()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//        
//        }
    }
    
    func addPlayer() {
        playerNode = childNode(withName: "player") as? SKSpriteNode
        
        playerNode?.physicsBody?.categoryBitMask = playerCatagorie
        playerNode?.physicsBody?.collisionBitMask = noCategory
        playerNode?.physicsBody?.contactTestBitMask = objectCatagorie
        
        addEnemyNodeWithActions()
    }
    override func update(_ currentTime: TimeInterval) {
        checkIfEnemyCrossthePlayer()
        spawnLazerAtTime(timeIntervel: currentTime - lastTimeIntervel)
        lastTimeIntervel = currentTime
    }
    
    func checkIfEnemyCrossthePlayer() {
        
        let playerPositionYInt:Int = Int((playerNode?.position.y)!)
        let enemyPositionYInt:Int = Int((objectNode?.position.y)!)
    
        if(playerPositionYInt > enemyPositionYInt) {
            showGameOver()
            stopLazerSpawning()
            
        }
    }
    
    func stopLazerSpawning() {
        lazerSpawnRate = 4444444444
    }
    
    func showGameOver()  {
        gameOverNode = SKLabelNode.init(text: "Game Over")
        gameOverNode?.position = self.position
        gameOverNode!.alpha = 0.0
        gameOverNode!.run(SKAction.fadeIn(withDuration: 2.0))
        addChild(gameOverNode!)
    }
    func spawnLazerAtTime(timeIntervel: TimeInterval){
        currentRate = currentRate + timeIntervel
        
        if (currentRate < lazerSpawnRate ) {
            return
        }
        spawnLazer()
        
        currentRate = 0
    }
    
    func spawnLazer() {
        let scene = SKScene.init(fileNamed: "Lager")
        let lagerCapsule = scene?.childNode(withName: "lagerCapsule")
        lagerCapsule?.physicsBody?.categoryBitMask = lazerCategory
        lagerCapsule?.physicsBody?.collisionBitMask = noCategory
        lagerCapsule?.physicsBody?.contactTestBitMask = objectCatagorie
        lagerCapsule?.position = (playerNode?.position)!
        lagerCapsule?.move(toParent: self)
        
    }
    
    func addNodes(count:NSInteger) {
//        for i in 0 ..< count {
//            self.spiderNode = SKSpriteNode.init(imageNamed: "SlidingPane")
//            self.spiderNode?.position = CGPoint.init(x: 0, y: (view?.frame.size.height)!/2)
//            self.spiderNode?.physicsBody = SKPhysicsBody.init(circleOfRadius: (self.spiderNode?.size.width)!/2)
//            self.spiderNode?.physicsBody?.restitution = 0.75
//            self.addChild(self.spiderNode!)
//            spiderNodes.add(self.spiderNode)
//        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
        // applyImpulse(atPint : pos)
     //   playerNode?.position = pos
    }
    func applyImpulse(atPint : CGPoint) {
        for i in 0 ..< spiderNodes.count {
            let spiderNode = spiderNodes.object(at: i) as! SKSpriteNode
            spiderNode.physicsBody?.applyImpulse(CGVector.init(dx:10*(atPint.x/abs(atPint.x)), dy: 10*(atPint.y/abs(atPint.y))), at: atPint)
        }
    }
        
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first as UITouch?
        let positionInScene = touch!.location(in: self)
        let previousPosition = touch!.previousLocation(in: self)
        let translation = CGPoint(x: positionInScene.x - previousPosition.x, y: positionInScene.y - previousPosition.y)
        playerNode?.position = CGPoint.init(x: (playerNode?.position.x)! + translation.x, y: (playerNode?.position.y)! + translation.y)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
}

extension SpiderScene : SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let A_NodeBitmask = contact.bodyA.categoryBitMask
        let B_NodeBitmask = contact.bodyB.categoryBitMask
       // SKAction..removen
        if(A_NodeBitmask == lazerCategory || B_NodeBitmask == lazerCategory) {
            let otherNode = (A_NodeBitmask == lazerCategory) ? contact.bodyB.node :  contact.bodyA.node
            handleTherNode(otherNode:otherNode!)
//            contact.bodyA.node?.removeFromParent()
//            contact.bodyB.node?.removeFromParent()
//            objectNode = nil
            repositionEnemy(enemyNode: otherNode!)
        }
//        contact.bodyA.node?.removeFromParent()
//        contact.bodyB.node?.removeFromParent()
        print("collision detected")
    }
    func repositionEnemy (enemyNode: SKNode) {
        //addEnemyNodeWithActions()
        enemyNode.removeAction(forKey: removeEnemyActionkey)
        addAndRunActions()
        
    }
    
    func handleTherNode(otherNode: SKNode) {
        let explosion = SKEmitterNode(fileNamed: "MyParticle")
        explosion?.position = otherNode.position
        self.addChild(explosion!)
    }
}
