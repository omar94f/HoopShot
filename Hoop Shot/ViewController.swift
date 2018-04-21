//
//  ViewController.swift
//  Hoop Shot
//
//  Created by Omar Farooq on 4/15/18.
//  Copyright © 2018 Omar. All rights reserved.
//

import UIKit
import ARKit

struct SwipeInfo {
    var startTouch : UITouch!
    var endTouch : UITouch!
    var startTime : TimeInterval!
    var endTime : TimeInterval!
    var startLocation : CGPoint!
    var endLocation : CGPoint!
}


class ViewController: UIViewController {

    
    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var hoopButton: UIButton!
    @IBOutlet weak var sightImageView: UIImageView!
    @IBOutlet weak var timerLabel: UILabel!
    
    
    var sceneManager: SceneManager!
    
    var swipe : SwipeInfo?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneManager = SceneManager(sceneView: sceneView)
        sceneManager.delegate = self
        self.sceneView.scene.physicsWorld.contactDelegate = self
        setupUI()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    func setupUI()  {
        hoopButton.layer.cornerRadius = self.hoopButton.frame.width/2
        sightImageView.image =  UIImage(named:"Sight")!.withRenderingMode(.alwaysTemplate)
        sightImageView.tintColor = UIColor.orange
        
    }
    
    
    @objc func viewTapped(gesture: UIGestureRecognizer) {
        print("Shoot pressed")
//        sceneManager.shoot()
    }

    
    @IBAction func hoopButtonTapped(_ sender: UIButton) {
        print("Hoop pressed")
        sceneManager.addHoop()
    }
    
}

// MARK: - Touches Methods

extension ViewController {
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        swipe = SwipeInfo()
        
        guard let firstTouch = touches.first else { return }
        
        swipe!.startTouch = firstTouch
        swipe!.startTime = Date().timeIntervalSince1970
        swipe!.startLocation = firstTouch.location(in: sceneView)
        sceneManager.touchBegan()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard swipe!.startTouch != nil else { return }
        
        guard let firstTouch = touches.first else { return }
        
        swipe!.endTouch = firstTouch
        swipe!.endTime = Date().timeIntervalSince1970
        swipe!.endLocation = firstTouch.location(in: sceneView)
        sceneManager.shoot(swipeInfo: swipe!)
        sceneManager.touchEnded()
    }
    
    
}


// MARK: - AR Physics Contact Delegate

extension ViewController : SCNPhysicsContactDelegate {
    
   
  
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        
        let green = createMaterial(color: .green)
        colorBall(contact: contact, color: green)
        
        sceneManager.collisionDetected(contact: contact, delegate: setScore)
    }
    
   
    func createMaterial(color : UIColor) -> SCNMaterial {
        let material  = SCNMaterial()
        material.diffuse.contents = color
        return material
    }
    
    func colorBall(contact: SCNPhysicsContact, color: SCNMaterial) {
        if(contact.nodeA.name == "Ball"){
            let hoop = contact.nodeA.geometry
            hoop?.materials = [color]
            
        } else {
            let hoop = contact.nodeB.geometry
            hoop?.materials = [color]
        }
    }
}


extension ViewController : SceneMangerDelegate {
    
    func setScore(score : Int) {
        DispatchQueue.main.async {
            self.scoreLabel.text = "Score: \(score)"
        }
        
    }
    
    func setTimer(count: Int) {
        if(count > 0) {
            timerLabel.isHidden = false
            timerLabel.text = count.description
        } else {
            timerLabel.isHidden = true
        }
    }
}
