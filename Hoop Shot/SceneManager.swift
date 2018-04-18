//
//  GameScene.swift
//  Hoop Shot
//
//  Created by Omar Farooq on 4/15/18.
//  Copyright © 2018 Omar. All rights reserved.
//

import Foundation

import ARKit


enum ObjectType : Int{
    case hoop = 1
    case ball = 2
}

protocol SceneMangerDelegate {
    func setScore(score: Int)
}

class SceneManager {
    
    var sceneView : ARSCNView!
    var scene = SCNScene()
    
    var currentHoop : SCNNode?
    var shotBall : SCNNode?
    
    let velocityInverse: Double = 5
    
    var delegate : SceneMangerDelegate?
    
    
    var score = 0 {
        didSet {
            self.delegate?.setScore(score: score)
        }
    }
    
    init(sceneView : ARSCNView) {
        self.sceneView = sceneView
        self.sceneView?.scene = self.scene
//        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]
        

    }
    
    func collisionDetected(contact : SCNPhysicsContact, delegate: (Int)->Void){
        score += 1
        
    }
    
    
    
    func addHoop() {
        
        if let hoop = currentHoop {
            hoop.removeFromParentNode() }
        
        let ring = makeHoop()
//        let cube = makeCube()
        
//        positionNode(node: cube, at: -0.4)
        positionNode(node: ring, at: -0.4)
        
        scene.rootNode.addChildNode(ring)
//        scene.rootNode.addChildNode(cube)
        
        currentHoop = ring
//        currentHoop = cube
        
        
    }
    
    func shoot(swipeInfo: SwipeInfo) {
        
        // Remove ball present in the scene
        if let ball = shotBall {
            ball.removeFromParentNode() }
        
        // Make and place ball at point of starting touch
        
        let ball = makeBall()
        self.positionNode(node: ball, at: -0.7)
        
        
        // Calculate velocity
        let timeDifference = swipeInfo.endTime - swipeInfo.startTime
        let velocity = Float( velocityInverse/timeDifference)
        
        // Create force vector
        let forceVector = SCNVector3(ball.worldFront.x * velocity,
                                     ball.worldFront.y  * velocity,
                                      ball.worldFront.z * velocity )
        
        ball.physicsBody?.applyForce(forceVector, asImpulse: true)
        
        scene.rootNode.addChildNode(ball)
        
        shotBall = ball
    }
    
}


// MARK: - Game objects
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
        ringNode.physicsBody?.categoryBitMask = ObjectType.hoop.rawValue
        
        ringNode.eulerAngles.x = Float.pi/2
        
        return ringNode
    }
    
    func makeCube() -> SCNNode {
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        box.materials = [material]
      
        let boxNode = SCNNode(geometry: box)
        boxNode.name = "Barrier1"
        boxNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        boxNode.physicsBody?.categoryBitMask = ObjectType.hoop.rawValue
        return boxNode
    }
    
    func makeBall() -> SCNNode {
        let sphere = SCNSphere(radius: 1)
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.name = "Ball"
        sphereNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        sphereNode.physicsBody?.categoryBitMask = ObjectType.ball.rawValue
        sphereNode.physicsBody?.contactTestBitMask = ObjectType.hoop.rawValue
        sphereNode.physicsBody?.isAffectedByGravity = true
        
        return sphereNode
    }
    
    private func positionNode(node: SCNNode ,at distance: Float) {
        guard let origin = sceneView?.session.currentFrame?.camera.transform else {
            fatalError("Could not find current frame while positioning \(String(describing: node.name ))")
        }
        var transform = node.simdTransform
        transform.columns.3.z = distance
        node.simdTransform = matrix_multiply(origin, transform)
    }
}

// MARK: - Scene utility methods
extension SceneManager {
    
    private func pointToSCNVector3(depth: Float, point: CGPoint) -> SCNVector3 {
        let projectedOrigin = sceneView.projectPoint(SCNVector3Make(0, 0, depth))
        let locationWithz   = SCNVector3Make(Float(point.x), Float(point.y), projectedOrigin.z)
        return sceneView.unprojectPoint(locationWithz)
    }

}





