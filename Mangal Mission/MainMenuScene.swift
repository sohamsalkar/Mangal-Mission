//
//  MainMenuScene.swift
//  Mangal Mission
//
//  Created by Soham Salkar on 03/11/20.
//

import Foundation
import SpriteKit
class MainMenuScene: SKScene
{
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.size=self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        let gameBy = SKLabelNode(fontNamed: "Shiny Signature")
        gameBy.text = "SOHAM SALKAR'S"
        gameBy.fontSize = 45
        gameBy.fontColor = SKColor.white
        gameBy.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.75)
        gameBy.zPosition = 1
        self.addChild(gameBy)
        
        let gameName1 = SKLabelNode(fontNamed: "Shiny Signature")
        gameName1.text = "MANGAL"
        gameName1.fontSize = 200
        gameName1.fontColor = SKColor.white
        gameName1.position = CGPoint(x: self.size.width/2, y:self.size.height*0.65 )
        gameName1.zPosition = 1
        self.addChild(gameName1)
        
        let gameName2 = SKLabelNode(fontNamed: "Shiny Signature")
        gameName2.text = "MISSION"
        gameName2.fontSize = 200
        gameName2.fontColor = SKColor.white
        gameName2.position = CGPoint(x: self.size.width/2, y:self.size.height*0.55 )
        gameName2.zPosition = 1
        self.addChild(gameName2)
        
        let startGame = SKLabelNode(fontNamed: "Shiny Signature")
        startGame.text = "START MISSION"
        startGame.fontSize = 120
        startGame.fontColor = SKColor.white
        startGame.position = CGPoint(x: self.size.width/2, y:self.size.height*0.3)
        startGame.zPosition = 1
        startGame.name = "startButton"
        self.addChild(startGame)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches
        {
            let pointOfTouch = touch.location(in: self)
            let nodeITapped = atPoint(pointOfTouch)
            if nodeITapped.name == "startButton"
            {
                let sceneToMove = GameScene(size: self.size)
                sceneToMove.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMove,transition: myTransition)
            }
//            nodeITapped.run(SKAction)
        }
    }
    
}
