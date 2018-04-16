//
//  GameScene.swift
//  Hoop Shot
//
//  Created by Omar Farooq on 4/15/18.
//  Copyright © 2018 Omar. All rights reserved.
//

import Foundation

import ARKit



class SceneManager {
    
    var sceneView : ARSCNView!
    var scene = SCNScene()
    
    var currentHoop : SCNNode?
    
    init(sceneView : ARSCNView) {
        self.sceneView = sceneView
        self.sceneView?.scene = self.scene
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]
        

    }
    
    func addHoop() {
        
        if let hoop = currentHoop { hoop.removeFromParentNode() }
        
        guard let origin = sceneView?.session.currentFrame?.camera.transform else {
            fatalError("Could not find current frame while adding hoop")
        }
        let ring = makeHoop()
        var transform = ring.simdTransform
        transform.columns.3.z = -0.4
        ring.simdTransform = matrix_multiply(origin, transform)
        
        scene.rootNode.addChildNode(ring)
        
        currentHoop = ring
        
    }
    
}

// MARK: - AR Scene View Delegate



// MARK: - Game object creators
extension SceneManager {
    
 func makeHoop() -> SCNNode {
        let ring = SCNTorus(ringRadius: 0.1, pipeRadius: 0.001)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.orange
        ring.materials = [material]
    
        let ringNode = SCNNode(geometry: ring)
        ringNode.name = "Ring"
        let shape = SCNPhysicsShape(geometry: ring, options: nil)
        ringNode.physicsBody = SCNPhysicsBody(type: .static, shape: shape)
        ringNode.physicsBody?.isAffectedByGravity = false
        ringNode.eulerAngles.x = Float.pi/2
        
        return ringNode
    }
}





