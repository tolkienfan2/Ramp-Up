//
//  RampPickerVC.swift
//  Ramp-Up
//
//  Created by Minni K Ang on 2017-09-16.
//  Copyright © 2017 CreativeIce. All rights reserved.
//

import UIKit
import SceneKit

class RampPickerVC: UIViewController {
    
    var sceneView: SCNView!
    var size: CGSize!
    var cameraNode: SCNNode!
    weak var rampPlacerVC: RampPlacerVC!
    
    let rotate = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat(0.01 * Double.pi), z: 0, duration: 0.1))
    
    init(size: CGSize) {
        super.init(nibName: nil, bundle: nil)
        self.size = size
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.frame = CGRect(origin: CGPoint.zero, size: size)
        sceneView = SCNView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        view.insertSubview(sceneView, at: 0)
        
        preferredContentSize = size
        view.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        view.layer.borderWidth = 3.0
        
        let scene = SCNScene(named: "art.scnassets/ramps.scn")!
        sceneView.scene = scene

        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        scene.rootNode.camera = camera
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tap)
        
        var node = addNode(name: "pipe", scale: SCNVector3Make(0.0015, 0.0015, 0.0015), position: SCNVector3Make(-0.8, 2.5, -1), delay: 0.0)
        scene.rootNode.addChildNode(node)
        
        node = addNode(name: "pyramid", scale: SCNVector3Make(0.004, 0.004, 0.004), position: SCNVector3Make(-0.8, 1.85, -1), delay: 1.0)
        scene.rootNode.addChildNode(node)
        
        node = addNode(name: "quarter", scale: SCNVector3Make(0.004, 0.004, 0.004), position: SCNVector3Make(-0.8, 1.2, -1), delay: 2.0)
        scene.rootNode.addChildNode(node)
    }
    
    func addNode(name: String, scale: SCNVector3, position: SCNVector3, delay: Double) -> SCNNode {
        let obj = SCNScene(named: "art.scnassets/\(name).dae")
        let node = obj?.rootNode.childNode(withName: name, recursively: true)
        delayActionBy(delay) {
            node?.runAction(self.rotate)
        }
        node?.scale = scale
        node?.position = position
        return node!
    }
    
    func delayActionBy(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    @objc func handleTap(_ gestureRecognizer: UIGestureRecognizer) {
        let p = gestureRecognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
        if hitResults.count > 0 {
            let node = hitResults[0].node
            rampPlacerVC.onRampSelected(node.name!)
            dismiss(animated: true, completion: nil)
        }
    }
}
