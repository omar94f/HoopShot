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
    
    var sceneManager: SceneManager!
    
    var swipe : SwipeInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneManager = SceneManager(sceneView: sceneView)
        sceneManager.delegate = self
        self.sceneView.scene.physicsWorld.contactDelegate = self
        setupUI()
        let box1 = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        box1.materials = [material]
        let box1Node = SCNNode(geometry: box1)
        box1Node.name = "Barrier1"
        box1Node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        box1Node.physicsBody?.categoryBitMask = ObjectType.hoop.rawValue
        box1Node.position = SCNVector3(0,0,-0.8)
        self.sceneView.scene.rootNode.addChildNode(box1Node)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        let configuration = ARWorldTrackingConfiguration()
//        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    func setupUI()  {
        self.hoopButton.layer.cornerRadius = self.hoopButton.frame.width/2
//        self.registerGestureRecognizers()
    }
    
    
    private func registerGestureRecognizers() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(gesture:)))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        
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
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard swipe!.startTouch != nil else { return }
        
        guard let firstTouch = touches.first else { return }
        
        swipe!.endTouch = firstTouch
        swipe!.endTime = Date().timeIntervalSince1970
        swipe!.endLocation = firstTouch.location(in: sceneView)
        sceneManager.shoot(swipeInfo: swipe!)
    }
    
    
}


// MARK: - AR Physics Contact Delegate

extension ViewController : SCNPhysicsContactDelegate {
    
   
  
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        sceneManager.collisionDetected(contact: contact, delegate: setScore)
    }
}


extension ViewController : SceneMangerDelegate {
    
    func setScore(score : Int) {
        DispatchQueue.main.async {
            self.scoreLabel.text = "Score: \(score)"
        }
        
    }
}
