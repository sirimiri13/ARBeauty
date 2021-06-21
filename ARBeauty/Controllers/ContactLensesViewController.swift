//
//  ViewController.swift
//  ARBeauty
//
// Created by Huong Lam on 05/19/2021.

//

import UIKit
import ARKit

class ContactLensesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, StartSessionProtocol{
    func startSession() {
        sceneView.session.run(faceTrackingConfiguration)
    }
    

    @IBOutlet weak var eyesCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var fakeTabbarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var showHideImageView: UIImageView!
    /// Set rendererprivate
    @IBOutlet weak var arView: UIView!
    @IBOutlet weak var eyesCollectionView: UICollectionView!
    var sceneView = ARSCNView()
    
    
    /// Declare eye nodes
    private var leftEyeNode: EyesNode?
    private var rightEyeNode: EyesNode?


    /// Specify ARConfiguration
    private let faceTrackingConfiguration = ARFaceTrackingConfiguration()

    var eyeSelected = "bicolor_eyes"
    var eyeImageName : [String] =  ["bicolor_eyes",
                                    "blue_eyes",
                                    "galaxy_eyes",
                                    "black_eyes",
                                    "pink_eyes",
                                    "purple_eyes",
                                    "brown-eyes",
                                    "babayblue_eyes",
                                    "bistre_eyes",
                                    "bistrebrown_eyes",
                                    "crystal_eyes",
                                    "grey_eyse"]
    
    var selectedIndex = 0
    var isChanged: Bool = false
    var isShowColorsCollectionView = true
    override func viewDidLoad() {
        super.viewDidLoad()
       
        guard ARFaceTrackingConfiguration.isSupported else { fatalError("A TrueDepth camera is required") }
        arView.addSubview(sceneView)

        
        
        
        //add autolayout contstraints
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.topAnchor.constraint(equalTo: self.arView.topAnchor).isActive = true
        sceneView.leftAnchor.constraint(equalTo: self.arView.leftAnchor).isActive = true
        sceneView.rightAnchor.constraint(equalTo: self.arView.rightAnchor).isActive = true
        sceneView.bottomAnchor.constraint(equalTo: self.arView.bottomAnchor).isActive = true
        sceneView.delegate = self
        eyesCollectionView.delegate = self
        eyesCollectionView.dataSource = self
        
        
        if #available(iOS 11.0, *) {
            if let window = UIApplication.shared.windows.first {
                if window.safeAreaInsets.bottom > 0 {
                    fakeTabbarBottomConstraint.constant = -53;
                }
            }
        }
        let layout = UICollectionViewFlowLayout()
        eyesCollectionView.backgroundColor = UIColor.clear
        eyesCollectionView.collectionViewLayout = layout
        eyesCollectionView.showsHorizontalScrollIndicator = false
        eyesCollectionView.backgroundColor = .clear
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.minimumLineSpacing = 10
        self.eyesCollectionView.register(UINib.init(nibName: "StyleCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "StyleCollectionViewCell")

        let showHideColorsIconTap = UITapGestureRecognizer(target: self, action: #selector(showHideColorsTapped))
        showHideImageView.addGestureRecognizer(showHideColorsIconTap)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetTracking()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        /// Pause session
        sceneView.session.pause()
    }
    
    
    
    @objc func showHideColorsTapped() {
        eyesCollectionHeight.constant = isShowColorsCollectionView ? 0 : 60
        UIView.animate(withDuration: 0.2) {
            self.showHideImageView.transform = self.isShowColorsCollectionView ? CGAffineTransform.init(rotationAngle: CGFloat.pi) : CGAffineTransform.init(rotationAngle: 0.000001)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.isShowColorsCollectionView = !self.isShowColorsCollectionView
        }

    }
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func captureTapped(_ sender: Any) {
        let image = sceneView.snapshot()
        let photoViewController = UIStoryboard.photoViewController()
        photoViewController.delegate = self
        photoViewController.photoImage = image
        photoViewController.modalPresentationStyle = .fullScreen
        present(photoViewController, animated: true, completion: nil)
    }
    
    func resetTracking() {
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        if #available(iOS 13.0, *) {
            configuration.maximumNumberOfTrackedFaces = ARFaceTrackingConfiguration.supportedNumberOfTrackedFaces
        }
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  eyeImageName.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StyleCollectionViewCell", for: indexPath) as! StyleCollectionViewCell
        cell.styleImageView.image = UIImage(named: eyeImageName[indexPath.row])
        if (selectedIndex == indexPath.row) {
            cell.setCell(isSelected: true)
        }
        else {
            cell.setCell(isSelected: false)
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        eyeSelected = eyeImageName[indexPath.row]
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                    node.removeFromParentNode()
            }
        rightEyeNode = EyesNode(width: 0.015, height: 0.015, image: UIImage(named: eyeSelected)!)
        leftEyeNode = EyesNode(width: 0.015, height: 0.015, image: UIImage(named:eyeSelected)! )
        
        rightEyeNode?.pivot = SCNMatrix4MakeTranslation(0, 0, -0.01)
        leftEyeNode?.pivot = SCNMatrix4MakeTranslation(0, 0, -0.01)
        
               
        eyesCollectionView.reloadData()
        resetTracking()
    }
    
}


extension ContactLensesViewController: ARSCNViewDelegate {
    

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {

        /// Validate anchor is an ARFaceAnchor instance
        guard anchor is ARFaceAnchor,
            let device = sceneView.device else { return nil }

        /// Create node with face geometry
        let faceGeometry = ARSCNFaceGeometry(device: device)
        let node = SCNNode(geometry: faceGeometry)

        node.geometry?.firstMaterial?.colorBufferWriteMask = []

        /// Create eye ImageNodes
       
        rightEyeNode = EyesNode(width: 0.015, height: 0.015, image: UIImage(named: eyeSelected)!)
        leftEyeNode = EyesNode(width: 0.015, height: 0.015, image: UIImage(named: eyeSelected)! )
      
        

        /// Change the origin of the eye nodes
        rightEyeNode?.pivot = SCNMatrix4MakeTranslation(0, 0, -0.01)
        leftEyeNode?.pivot = SCNMatrix4MakeTranslation(0, 0, -0.01)

        /// Add child nodes
        rightEyeNode.flatMap { node.addChildNode($0) }
        leftEyeNode.flatMap { node.addChildNode($0) }

        return node
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        /// Get face anchor as ARFaceAnchor
        guard let faceAnchor = anchor as? ARFaceAnchor,
            let faceGeometry = node.geometry as? ARSCNFaceGeometry else { return }

        /// Update the geometry displayed on screen to be now conformed by the anchor calculated
        faceGeometry.update(from: faceAnchor.geometry)
       
        /// Update node transforms
        leftEyeNode?.simdTransform = faceAnchor.leftEyeTransform
        rightEyeNode?.simdTransform = faceAnchor.rightEyeTransform
    }
    

}
