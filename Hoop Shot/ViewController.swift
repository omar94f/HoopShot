//
//  ViewController.swift
//  Hoop Shot
//
//  Created by Omar Farooq on 4/15/18.
//  Copyright © 2018 Omar. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    
    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var hoopButton: UIButton!
    
    var sceneManager: SceneManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneManager = SceneManager(sceneView: sceneView)
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
        self.hoopButton.layer.cornerRadius = self.hoopButton.frame.width/2
    }

    
    @IBAction func hoopButtonTapped(_ sender: UIButton) {
        print("Hoop pressed")
        sceneManager.addHoop()
    }
    
}

// MARK: - AR Scene View Delegate

extension ViewController : ARSCNViewDelegate {
    
  
}

