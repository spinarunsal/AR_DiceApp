//
//  ViewController.swift
//  ARDicee
//
//  Created by Pinar Unsal on 2018-07-21.
//  Copyright © 2018 S Pinar Unsal. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    var diceArray = [SCNNode]()

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        //default lightening
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        //plane detection property
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
 
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
//MARK: - Dice Rendering Methods
    //detect touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            //add dice
            if let hitResult = results.first {
                //print(hitResult)
                // Create a new scene
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")
                
                if let diceNode = diceScene?.rootNode.childNode(withName: "Dice", recursively: true) {
                    //set its position
                    diceNode.position = SCNVector3(
                        x: hitResult.worldTransform.columns.3.x,
                        y: hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                        z: hitResult.worldTransform.columns.3.z)
                    
                    diceArray.append(diceNode)
                    sceneView.scene.rootNode.addChildNode(diceNode)
                    
                    roll(dice: diceNode)
                }
            }
        }
    }
    
    // roll
    func roll(dice: SCNNode) {
        //rotate dice x and z axis
        //create random num betw 1-4
        //rotate along x axis show faces equally lightly thats why shift +1 and
        //dice turns 90 degrees pi/2
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        dice.runAction(
            SCNAction.rotateBy(x: CGFloat(randomX * 2),
                               y: 0,
                               z: CGFloat(randomZ * 2),
                               duration: 0.5) // 0.5 duration half a second
        )
    }
    
    //rollAll
    func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }

    //rollAgain
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    //Motion detector
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    
//MARK: - ARCNViewDelegateMethods
    //detect horizontal surface - delegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
//        if anchor is ARPlaneAnchor {
//            print("Plane detected")
//            let planeAnchor = anchor as! ARPlaneAnchor
//
//        } else {
//            return
//        }
//***** instead if/else --> use guard and createPlane functionality
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        node.addChildNode(planeNode)
        
    }
    
    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        planeNode.transform =  SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named:"art.scnassets/grid.png")
        plane.materials = [gridMaterial]
        planeNode.geometry = plane
        
        return planeNode
    }
}
