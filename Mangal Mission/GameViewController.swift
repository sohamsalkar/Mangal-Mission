//
//  GameViewController.swift
//  Mangal Mission
//
//  Created by Soham Salkar on 31/10/20.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class GameViewController: UIViewController {
    
    var backingAudio = AVAudioPlayer()

    override func viewDidLoad() {
           
   super.viewDidLoad()
        
        let filePath = Bundle.main.path(forResource: "Backing Audio", ofType: "mp3")
        let audioNSURL = NSURL(fileURLWithPath: filePath!)
        
        do {
            backingAudio = try AVAudioPlayer(contentsOf: audioNSURL as URL)
        }
        catch{
            return print("CANNOT FIND AUDIO")
        }
        backingAudio.numberOfLoops = -1
        backingAudio.volume = 0.8
        backingAudio.play()
           
           if let view = self.view as! SKView? {

               // Load the SKScene from 'GameScene.sks'

               let scene = MainMenuScene(size: CGSize(width: 1536, height: 2048))

                   // Set the scale mode to scale to fit the window

                   scene.scaleMode = .aspectFill
                   
                   // Present the scene

                   view.presentScene(scene)
               
               view.ignoresSiblingOrder = true
               
               view.showsFPS = false

               view.showsNodeCount = false
           }

       }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
