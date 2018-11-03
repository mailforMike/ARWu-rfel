//
//  ViewController.swift
//  ARWürfel
//
//  Created by Michael Holzinger on 03.11.18.
//  Copyright © 2018 Michael Holzinger. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var würfelArray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,ARSCNDebugOptions.showWorldOrigin]
        
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        //configuration.environmentTexturing = .automatic
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @IBAction func rollButton(_ sender: UIBarButtonItem) {
        
        rollAll()
    
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
            let touchLocation = touch.location(in: sceneView)
            
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first{
                
                let würfelszene = SCNScene(named: "art.scnassets/würfel/diceCollada.scn")
                
                let würfel = würfelszene?.rootNode.childNode(withName: "Dice", recursively: true)
                würfel?.position = SCNVector3(
                    x: hitResult.worldTransform.columns.3.x,
                    y: hitResult.worldTransform.columns.3.y + (würfel?.boundingSphere.radius)!,
                    z: hitResult.worldTransform.columns.3.z
                )
                
                würfelArray.append(würfel!)
               
                sceneView.scene.rootNode.addChildNode(würfel!)
                
                roll(würfel: würfel!)
                
            }
            
        }
    }
    
    func rollAll(){
        if !würfelArray.isEmpty {
            for würfel in würfelArray {
                roll(würfel: würfel)
            }
        }
    }
    
    func roll(würfel: SCNNode){
        
        let randomX = Float(arc4random_uniform(4)+1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4)+1) * (Float.pi/2)
        
        würfel.runAction(SCNAction.rotateBy(
            x: CGFloat(randomX) * 3,
            y: 0,
            z: CGFloat(randomZ) * 3,
            duration: 2))
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            print("plane detected")
            
            let planeAnchor = anchor as! ARPlaneAnchor
            
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            let planeNode = SCNNode()
            
            planeNode.position = SCNVector3(planeAnchor.center.x,0,planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0) //rotation 90° x achse
            
            let material = SCNMaterial()
            
            material.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            plane.materials = [material]
            
            planeNode.geometry = plane
            
            //node.addChildNode(planeNode) // <-- anchor planes anzeigen
            
            
        } else {
            return
        }
    }
    
    
    
}
