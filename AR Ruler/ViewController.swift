//
//  ViewController.swift
//  AR Ruler
//
//  Created by Jeff on 11/10/20.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        //MARK: - Note 1: Detecting the start and end points of our measurment. Delete or comment out the unnecessary template code from Apple: three lines of code below and all the session functions at the bottom. Then add some debug options: 'sceneView.debutOptions = [ARSCNViewDebugOptions.FeaturePoints]'. This will help us auto detect which part of our scene is on a continuous surface for us to measure something. Next add the method for touches began: 'override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { }', you can do a test to see when a touch is dected by 'print("touch detected")'. Now we want to grab the location of the touch, use optional binding to do so, 'if let touchLocation = touches.first?.location(in: sceneView)', 'touches' is that set of UI touches Set<UITouches> we get back when the user touches the screen. In this set, grab the first one if it exists and then check for its location inside the sceneView. If that succeeds, then we'll have this object 'touchLocation' and then perfrom a hit test (now ray casting) using 'touchLocaiton' and see if it corresponds to a feature point by, 'let hitTestResults = sceneView.hitTest(point: CGPoint##CGPoint, types: ARHitTestResult.ResultType)'. However, now, this must be replaced by raycastQuery, 'guard let raycastResults = sceneView.raycastQuery(from: CGPoint, allowing: ARRaycastQuery.Target, alignment: ARRaycastQuery.TargetAlignment) -> ARRaycastQuery?' which is used like: 'guard let raycastResults = sceneView.raycastQuery(from: touchLocation, allowing: .existingPlantInfinite, alignment: .any) else { return }'. Then we store the results from 'sceneView.scene.raycast(raycastResults)' in a object, 'let raycastResults = sceneView.scene.raycast(raycastResults)'. Next, use the first location the user the user pressed on the scene, store it in a new object, and then call a method to create a red sphere where the user tapped:  'if let rayResult = raycastResults.first { addDot(at rayResult: ARRaycastResult) }'. Next, create a new geometry, the red dot where the user tapped stored in a function with sphere radius, define the material contents, assigne this to dotGeometry, create a node using our dotGeometry, finally assign the postion detected by the users touch in 2D into 3D by using (hitTest) raycastQuery and pass it into the addDot method and give it a position: 'func redDot(at rayResult: ARRaycastResult) { let dotGeometory = SCNNode(radius: 0.005), let material = SCNMaterial(), material.diffuse.contents = UIColor.red, dotGeometry.materials = [material], let dotNode = SCNNode(geometry: dotGeometry), dotNode.position = SCNVector3((CGFloat(rayResult.worldTransform.columns.3.x), CGFloat(rayResult.worldTransform.columns.3.y), CGFloat(rayResult.worldTransform.columns.3.z))'. Finally for this part, add this into the scene, 'sceneView.scene.rootNode.addChildNode(dotNode)

//        // Show statistics such as fps and timing information
//        sceneView.showsStatistics = true
//
//        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
//
//        // Set the scene to the view
//        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchLocation = touches.first?.location(in: sceneView) {
//            let hitTestResultsOrRayCastingResults = sceneView.hitTest(T##point: CGPoint##CGPoint, types: T##ARHitTestResult.ResultType)
            guard let raycastResutls = sceneView.raycastQuery(from: touchLocation, allowing: .existingPlaneInfinite, alignment: .any) else {
                return
            }
            
            let raycastResult = sceneView.session.raycast(raycastResutls)
            if let rayResult = raycastResult.first {
                addDot(at: rayResult)
            }
            
            }
        }
    func addDot(at rayResult: ARRaycastResult) {
        let dotGeometry = SCNSphere(radius: 0.005)
        
        let material = SCNMaterial()
        
        material.diffuse.contents = UIColor.red
        
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        
        dotNode.position = SCNVector3(CGFloat(rayResult.worldTransform.columns.3.x), CGFloat(rayResult.worldTransform.columns.3.y), CGFloat(rayResult.worldTransform.columns.3.z))
        
//            This is how the geometry property can be called and used outside the SCNode() initilization without parameters.
//            node.geometry = dotGeometry
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            calculator()
        }
        
    }
    
    func calculator() {
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        let distance = sqrt(pow(end.position.x - start.position.x, 2) + pow(end.position.y - start.position.y, 2) + pow(end.position.z - start.position.z, 2))
        
        updateText(text: "\(abs(distance))", atPosition: end.position)
    }
    
    //MARK: - Note 2: Calculate the distance between dotNodes. First, create a new variable, at the top of this view controller, to store an array of SCNode and initialize it to an empty array: 'var dotNodes = [SCNNodes]()', this will keep track of all the nodes we put onto the scene. Inside the method, 'func addDot(at rayResult: ARRaycastResult)', where we add new nodes to the scene, appened each new node into this new array, 'dotNodes.append(dotNode)'. Next, check to see if there are two or more (grater than or equal to 2) 'dotNode' in the array; if dotNodes count property is grater than or equal to 2 then call a function called calculate which takes not inputs (needs to be created): 'if dotNodes.count >= 2 { calculate() }'. Calculate method has a constant, start, which is set to the the first item in the array at the 0th position, this is our first dot on the scene. Next, createa a second constant for our end position to measure: 'func calculate() { let start = dotNodes[0], let end = dotNodes[1] }'. First print the start and end position to the console to see what they look like. These start and end positions have x, y, and z. Next we need to figure out the distance between the two in 3D space. In 2D we can use Pythagoras' theorem: in a right sided triangle that is 90 degrees the hypotenuse is the line oppsite line (h) which can be calculated by, h = square root a^2 + b^2, it the root of the square of the two sides. For 3D, picture a square and two points at oppsite ends, we need a, b, and c at one position which we have as x, y, and z. Use a variant of Pythagoras theorem, d = square root a^2 + b^2 + c^2, d is the distance between the two points and provided we have all the positions of the two points, find the difference between each x, y, and z positions (a, b, c respectively) then use the formula, d = square root a^2 + b^2 + c^2. In "code equation" this looks like: distance equels square ((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2), now this needs to be converted to swift code: Replace the print statment with this, 'let a = end.position.x - start.position.x, let b = end.position.y - start.position.y, let c = end.position.z - start.position.z, let distance = sqrt(pow(a, 2} + pow(b, 2} + pow(c, 2}', sqrt or square root is a function avilable through UIKit, and inside we want a Double data types wraped in a power function which take two values. This can made more succinct by removing the a, b, and c let constants adding them to the 'let distance = sqrt(pow(end.position.x - start.position.x, 2) + pow(end.position.y - start.position.y, 2) + pow(end.position.z - start.position.z, 2))'. Finally, print the abolute value |x| of our distance: 'print(abs(distance))', (autocomplete abs(Int32)) by using this sign we're ignoring a negative sign or value in front of the value cause we dont know if the start/end value is more or less that the second positions start/end value. Next module, 3D text in our ARScene.
    
    //MARK: - Note 3: Creating 3D text in ARScene. 
    func updateText(text: String, atPosition position: SCNVector3) {
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        
        let material = SCNMaterial()
        
        material.diffuse.contents = UIColor.red
        
        textGeometry.materials = [material]
        
        let textNode = SCNNode(geometry: textGeometry)
        
        textNode.position = SCNVector3(position.x, position.y, position.z)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
//    func session(_ session: ARSession, didFailWithError error: Error) {
//        // Present an error message to the user
//
//    }
//
//    func sessionWasInterrupted(_ session: ARSession) {
//        // Inform the user that the session has been interrupted, for example, by presenting an overlay
//
//    }
//
//    func sessionInterruptionEnded(_ session: ARSession) {
//        // Reset tracking and/or remove existing anchors if consistent tracking is required
//
//    }
}


