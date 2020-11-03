//
//  GameScene.swift
//  Mangal Mission
//
//  Created by Soham Salkar on 31/10/20.
//

import SpriteKit
import GameplayKit
var gameScore = 0

class GameScene: SKScene , SKPhysicsContactDelegate{
    
    
    let scoreLabel = SKLabelNode(fontNamed: "Shiny Signature")
    
    var livesNumber = 15
    let livesLabel = SKLabelNode(fontNamed: "Shiny Signature")
    
    var levelNumber = 0
    
    let player = SKSpriteNode(imageNamed: "ourship" )
    let bulletSound = SKAction.playSoundFileNamed("burst.wav", waitForCompletion: false)
    let explosionSound = SKAction.playSoundFileNamed("blast.wav", waitForCompletion: false)
    let tapToStartLabel = SKLabelNode(fontNamed: "Shiny Signature")
    
    enum gameState{
        case preGame
        case inGame
        case afterGame
    }
    
    var currentGameState = gameState.preGame
    
    struct PhysicsCategories
    {
        static let None : UInt32 = 0
        static let Player : UInt32 = 0b1
        static let Bullet : UInt32 = 0b10
        static let Enemy : UInt32 = 0b100
    }
    
    func random() -> CGFloat
    {
            return CGFloat( Float( arc4random() ) / 0xFFFFFFFF )
    }
    func random(min : CGFloat , max : CGFloat ) -> CGFloat
    {
        return random() * (max - min) + min
    }
    
    var gameArea: CGRect
    override init(size: CGSize)
    {
        let maxAspectRatio : CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0 , width: playableWidth, height: size.height)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to: SKView)
    {
        gameScore = 0
        self.physicsWorld.contactDelegate = self
        
        for i in 0...1
        {
            let background = SKSpriteNode(imageNamed: "backgroundm" )
            background.size=self.size
            background.anchorPoint = CGPoint(x: 0.5, y: 0)
            background.position = CGPoint(x: self.size.width/2, y: self.size.height*CGFloat(i))
            background.zPosition = 0
            background.name = "Background"
            self.addChild(background)
        }
        
        player.setScale(0.4)
//        self.size.height/8
        player.position = CGPoint(x: self.size.width/2, y: 0 - player.size.height)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(player)
        
        scoreLabel.text = "SCORE: 0"
        scoreLabel.fontSize = 60
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
//          *0.95
        scoreLabel.position = CGPoint(x: self.size.width*0.3, y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 10
        self.addChild(scoreLabel)
        
        livesLabel.text = "LIVES: 15"
        livesLabel.fontSize = 60
        livesLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
//          *0.95
        livesLabel.position = CGPoint(x: self.size.width*0.8, y: self.size.height + livesLabel.frame.size.height)
        livesLabel.zPosition = 10
        self.addChild(livesLabel)
        
        let moveToScreenAction = SKAction.moveTo(y: self.size.height*0.95 , duration: 0.4)
        scoreLabel.run(moveToScreenAction)
        livesLabel.run(moveToScreenAction)
        
        tapToStartLabel.text = "TAP TO BEGIN"
        tapToStartLabel.fontSize = 90
        tapToStartLabel.fontColor = SKColor.white
        tapToStartLabel.zPosition = 1
        tapToStartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        tapToStartLabel.alpha = 0
        self.addChild(tapToStartLabel)
        
        let fadeInAction = SKAction.fadeIn(withDuration: 0.4)
        tapToStartLabel.run(fadeInAction)
        
//        startNewLevel()
    }
    var lastUpdateTime: TimeInterval = 0
    var deltaFrameTime: TimeInterval = 0
    var amountToMovePerSecond : CGFloat = 600.0
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0
        {
            lastUpdateTime = currentTime
        }
        else
        {
            deltaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        let amountToMoveBackground = amountToMovePerSecond * CGFloat(deltaFrameTime)
        self.enumerateChildNodes(withName: "Background")
        {
            (background , stop) in
            if self.currentGameState == gameState.inGame{
                background.position.y -= amountToMoveBackground
            }
            if background.position.y < -self.size.height
            {
                background.position.y += self.size.height*2
            }
        }
        
    }
    
    func startGame()
    {
        currentGameState = gameState.inGame
        
        let fadeOutAction = SKAction.fadeIn(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction,deleteAction])
        tapToStartLabel.run(deleteAction)
        
        let moveShipToScreenAction = SKAction.moveTo(y: self.size.height/8, duration: 0.5)
        let startLevelAction = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([moveShipToScreenAction,startLevelAction])
        player.run(startGameSequence)
        
    }
    
    func loseALife()
    {
        livesNumber -= 1
        livesLabel.text = "LIVES: \(livesNumber)"
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.15)
        let scaleDown = SKAction.scale(to: 1, duration: 0.15)
        let scaleSequence = SKAction.sequence([scaleUp,scaleDown])
        livesLabel.run(scaleSequence)
        
        if livesNumber == 0
        {
            runGameOver()
        }
    }
    
    func addScore()
    {
        gameScore += 1
        scoreLabel.text = "SCORE: \(gameScore)"
        
        if gameScore == 5 || gameScore == 10 || gameScore == 15 || gameScore == 20 || gameScore == 27 || gameScore == 40 || gameScore == 50
        {
            startNewLevel()
        }
    }
    
    func runGameOver()
    {
        currentGameState = gameState.afterGame
        
        self.removeAllActions()
        self.enumerateChildNodes(withName: "Bullet"){
            (bullet, stop) in
            bullet.removeAllActions()
        }
        self.enumerateChildNodes(withName: "Enemy"){
            (enemy , stop)in
            enemy.removeAllActions()
        }
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene,changeSceneAction])
        self.run(changeSceneAction)
    }
    
    func changeScene()
    {
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(with: UIColor.systemGray , duration: 0.5)
        self.view!.presentScene(sceneToMoveTo,transition: myTransition)
    }
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            body1 = contact.bodyA
            body2 = contact.bodyB
        }
        else{
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy
        {
//            if player hits enemy
            if body1.node != nil{
            spawnExplosion(spawnPosition: body1.node!.position)
            }
            if body2.node != nil{
            spawnExplosion(spawnPosition: body2.node!.position)
            }
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            runGameOver()
            
        }
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy
//            && (body2.node?.position.y)! > self.size.height
        {
//            if bullet hits enemy
            addScore()
            if body2.node != nil{
            spawnExplosion(spawnPosition: body2.node!.position)
            }
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
    }
    
    func spawnExplosion(spawnPosition: CGPoint)
    {
        let explosion = SKSpriteNode(imageNamed: "explosion")
        
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        let scaleIn = SKAction.scale(to: 0.5, duration: 0.15)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        let explosionSequence = SKAction.sequence([explosionSound,scaleIn,fadeOut,delete])
        explosion.run(explosionSequence)
        
    }
    
    func startNewLevel()
    {
        levelNumber += 1
        if self.action(forKey: "spawningEnemies") != nil{
            self.removeAction(forKey: "spawningEnemies")
        }
        var levelDuration = TimeInterval()
        
        switch levelNumber{
        case 1 : levelDuration = 2.5
        case 2 : levelDuration = 2
        case 3 : levelDuration = 1.75
        case 4 : levelDuration = 1.5
        case 5 : levelDuration = 1.25
        case 6 : levelDuration = 1
        case 7 : levelDuration = 0.75
        case 8 : levelDuration = 0.5
            
        default : levelDuration = 1
            print("level error ")
        }
        
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpawn,spawn ])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever ,withKey: "spawningEnemies" )
    }
    
    func fireBullet()
    {
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.name = "Bullet"   //reference
        bullet.setScale(0.1)
        bullet.position = player.position
        bullet.zPosition = 1        
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1.2)
        let deleteBullet = SKAction.removeFromParent()
        
        let bulletSequence = SKAction.sequence([bulletSound,moveBullet,deleteBullet])
        bullet.run(bulletSequence)
        
    }
    
    func spawnEnemy()
    {
        let randomXStart = random(min: gameArea.minX , max:gameArea.maxX)
        let randomXEnd = random (min: gameArea.minX , max: gameArea.maxX )
        let startPoint = CGPoint(x: randomXStart, y: self.size.height )
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height )
        let enemy = SKSpriteNode(imageNamed: "enemyspaceship")
        enemy.name = "Enemy"
        enemy.setScale(0.4)
        enemy.zPosition=2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet

        enemy.position = startPoint
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 2.5)
        let deleteEnemy = SKAction.removeFromParent()
        let loseALifeAction = SKAction.run(loseALife)
        let enemySequence = SKAction.sequence([moveEnemy,deleteEnemy, loseALifeAction])
        
        if currentGameState == gameState.inGame{
            enemy.run(enemySequence)
        }
        
        let dx =  endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if currentGameState == gameState.preGame
        {
            startGame()
        }
        else if currentGameState == gameState.inGame{
            fireBullet()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            if currentGameState == gameState.inGame{
                player.position.x += amountDragged
            }
            
            if player.position.x > gameArea.maxX - player.size.width/2
            {
                player.position.x = gameArea.maxX - player.size.width/2
            }
            if player.position.x < gameArea.minX + player.size.width/2
            {
                player.position.x = gameArea.minX + player.size.width/2
            }
        }
    }
}
