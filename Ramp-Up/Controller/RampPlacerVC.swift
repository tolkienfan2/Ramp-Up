//
//  ViewController.swift
//  Ramp-Up
//
//  Created by Minni K Ang on 2017-09-15.
//  Copyright © 2017 CreativeIce. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class RampPlacerVC: UIViewController, ARSCNViewDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var controls: UIStackView!
    @IBOutlet weak var rotateBtn: UIButton!
    @IBOutlet weak var upBtn: UIButton!
    @IBOutlet weak var downBtn: UIButton!
    
    var selectedRamp: String!
    var selectedRampNode: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        
        sceneView.showsStatistics = false
        
        sceneView.antialiasingMode = .multisampling4X
        
        let scene = SCNScene(named: "art.scnassets/main.scn")!
        sceneView.autoenablesDefaultLighting = true
        
        sceneView.scene = scene
        
        let gesture1 = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(gesture:)))
        let gesture2 = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(gesture:)))
        let gesture3 = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(gesture:)))
        gesture1.minimumPressDuration = 0.1
        gesture2.minimumPressDuration = 0.1
        gesture3.minimumPressDuration = 0.1
        rotateBtn.addGestureRecognizer(gesture1)
        upBtn.addGestureRecognizer(gesture2)
        downBtn.addGestureRecognizer(gesture3)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    

    // Override to create and configure nodes for anchors added to the view's session.
//    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
//        let node = SCNNode()
//        return node
//    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    @IBAction func rampBtnPressed(_ sender: UIButton) {
        let rampPickerVC = RampPickerVC(size: CGSize(width: 250, height: 500))
        rampPickerVC.rampPlacerVC = self
        rampPickerVC.modalPresentationStyle = .popover
        rampPickerVC.popoverPresentationController?.delegate = self
        rampPickerVC.popoverPresentationController?.sourceView = sender
        rampPickerVC.popoverPresentationController?.sourceRect = sender.bounds
        present(rampPickerVC, animated: true, completion: nil)
    }
    
    func onRampSelected(_ rampName: String) {
        selectedRamp = rampName
    }
    
    func placeRamp(position: SCNVector3, name: String) -> SCNNode {
        let obj = SCNScene(named: "art.scnassets/\(name).dae")
        let node = obj?.rootNode.childNode(withName: name, recursively: true)
        selectedRampNode = node
        return selectedRampNode!
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let results = sceneView.hitTest(touch.location(in: sceneView), types: [.featurePoint])
        guard let hitFeature = results.last else {
            dismiss(animated: true, completion: nil)
            popUpWarning()
            return
        }
        let hitTransform = SCNMatrix4(hitFeature.worldTransform)
        let hitPosition = SCNVector3Make(hitTransform.m41, hitTransform.m42, hitTransform.m43)
        if let rampName = selectedRamp {
            let newRampNode = placeRamp(position: hitPosition, name: rampName)
            sceneView.scene.rootNode.addChildNode(newRampNode)
        }
    }
    
    func popUpWarning() {
        let popUp = UIAlertController(title: "Insufficient context!", message: "Move your device around so it can see more features in your environment", preferredStyle: .alert)
        let popUpAction = UIAlertAction(title: "OK", style: .cancel)
        popUp.addAction(popUpAction)
        present(popUp, animated: true, completion: nil)
    }
    
    @IBAction func removeBtnPressed(_ sender: Any) {
        if let ramp = selectedRampNode {
            ramp.removeFromParentNode()
            selectedRampNode = nil
        }
    }
    
    @objc func onLongPress(gesture: UILongPressGestureRecognizer) {
        if let ramp = selectedRampNode {
            if gesture.state == .ended {
                ramp.removeAllActions()
            } else if gesture.state == .began {
                if gesture.view === rotateBtn {
                    let rotate = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat(0.08 * Double.pi), z: 0, duration: 0.1))
                    ramp.runAction(rotate)
                } else if gesture.view === upBtn {
                    let move = SCNAction.repeatForever(SCNAction.moveBy(x: 0, y: 0.08, z: 0, duration: 0.1))
                    ramp.runAction(move)
                } else if gesture.view === downBtn {
                    let move = SCNAction.repeatForever(SCNAction.moveBy(x: 0, y: -0.08, z: 0, duration: 0.1))
                    ramp.runAction(move)
                }
            }
        }
    }
    
    @IBAction func rotateBtnPressed(_ sender: Any) {
    }
    
    @IBAction func upArrowPressed(_ sender: Any) {
    }
    
    @IBAction func downArrowPressed(_ sender: Any) {
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
