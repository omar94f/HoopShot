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
    case ball = 0
    case hoop = 2
    
}

protocol SceneMangerDelegate {
    func setScore(score: Int)
    func setTimer(count: Int)
}

class SceneManager {
    
    var sceneView : ARSCNView!
    var scene = SCNScene()
    
    var currentHoop : SCNNode?
    var currentBalls : [SCNNode?] = [nil,nil]
    
    let velocityFactor: Double = 10
    
    var timer : Timer?
    var timerCount: Int = 0 {
        didSet {
            self.delegate?.setTimer(count: timerCount)
        }
    }
    
    
    
    var delegate : SceneMangerDelegate?
    
    
    var score = 0 {
        didSet {
            self.delegate?.setScore(score: score)
        }
    }
    
    init(sceneView : ARSCNView) {
        self.sceneView = sceneView
        self.sceneView?.scene = self.scene
        
        let box1 = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        box1.materials = [material]
        let box1Node = SCNNode(geometry: box1)
        box1Node.name = "Barrier1"
        box1Node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        box1Node.physicsBody?.categoryBitMask = ObjectType.hoop.rawValue
        box1Node.position = SCNVector3(0,0,-0.8)
        scene.rootNode.addChildNode(box1Node)

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
    
    func touchBegan() {
        self.startTimer()
    }
    
    func touchEnded() {
        self.stopTimer()
    }
    
    
    func shoot(swipeInfo: SwipeInfo) {
        
//         Remove ball present in the scene
        if currentBalls.count > 1 {
            let ball = currentBalls.removeFirst()
            ball?.removeFromParentNode()
        }

        // Make and place ball at point of starting touch

        let ball = makeBall(radius: 0.04 )
        self.positionNode(node: ball, at: -0.1)


        // Calculate velocity
        let timeDifference = min(max(swipeInfo.endTime - swipeInfo.startTime, 1),5)
        let velocity = Float( velocityFactor*timeDifference)

        // Create force vector
        let forceVector = SCNVector3(ball.worldFront.x * velocity,
                                     ball.worldFront.y  * velocity,
                                      ball.worldFront.z * velocity )

        ball.physicsBody?.applyForce(forceVector, asImpulse: true)

        scene.rootNode.addChildNode(ball)

        currentBalls.append(ball)
       
        
    }
    
}


// MARK: - Game objects
extension SceneManager {
    
    private func makeHoop() -> SCNNode {
        let ring = SCNTorus(ringRadius: 0.2, pipeRadius: 0.01)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.orange
        ring.materials = [material]
        
        let ringNode = SCNNode(geometry: ring)
        ringNode.name = "Hoop"
        let shape = SCNPhysicsShape(geometry: ring, options: nil)
        ringNode.physicsBody = SCNPhysicsBody(type: .static, shape: shape)
        ringNode.physicsBody?.isAffectedByGravity = false
        ringNode.physicsBody?.categoryBitMask = ObjectType.hoop.rawValue
        
        ringNode.eulerAngles.x = Float.pi/2
        
        return ringNode
    }
    
    private func makeCube() -> SCNNode {
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
    
    private func makeBall(radius: CGFloat) -> SCNNode {
        let sphere = SCNSphere(radius: radius)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.yellow
        sphere.materials = [material]
        
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


// MARK: - Timer Controls

extension SceneManager {
    
    private func startTimer() {
        
        timer = Timer(timeInterval: 1, target: self, selector: #selector(incrementCounter), userInfo: nil, repeats: true)
        timer?.fire()
    
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timerCount = 0
    }
    
    @objc private func incrementCounter() {
        timerCount += 1
    }
    
}




