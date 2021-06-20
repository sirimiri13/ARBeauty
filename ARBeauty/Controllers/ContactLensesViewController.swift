//
//  ViewController.swift
//  ARContactLenses
//
//  Created by Leonardo Garcia  on 4/8/19.
//

import UIKit
import ARKit

final class ContactLensesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{

    @IBOutlet weak var eyesCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var fakeTabbarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var showHideImageView: UIImageView!
    /// Set rendererprivate
    @IBOutlet weak var arView: UIView!
    @IBOutlet weak var eyesCollectionView: UICollectionView!
    //    let sceneView = ARSCNView(frame: .zero)
    var sceneView = ARSCNView()
    /// Declare eye nodes
    private var leftEyeNode: ImageNode?
    private var rightEyeNode: ImageNode?


    /// Specify ARConfiguration
    private let faceTrackingConfiguration = ARFaceTrackingConfiguration()

    var eyeSelected = "bicolor_eyes"
    var eyeImageName : [String] =  ["bicolor_eyes",
                                    "blue_eyes",
                                    "green_eyes",
                                    "galaxy_eyes",
                                    "black_eyes",
                                    "pink_eyes",
                                    "purple_eyes",
                                    "brown_eyes"]
    
    var selectedIndex = 0
    var isChanged: Bool = false
    var isShowColorsCollectionView = true
    override func viewDidLoad() {
        super.viewDidLoad()
       
        guard ARFaceTrackingConfiguration.isSupported else { fatalError("A TrueDepth camera is required") }
        /// Set sceneView delegate
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
        /// Run session
        sceneView.session.run(faceTrackingConfiguration)
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
        isChanged = true
        eyeSelected = eyeImageName[indexPath.row]
        selectedIndex = indexPath.row
        eyesCollectionView.reloadData()
      
    }
    
}


extension ContactLensesViewController: ARSCNViewDelegate {
    

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {

        // Note: - You must compile this project with an iPhone with TrueDepth camera as target device, otherwise it will mark that sceneView has no `device` member

        /// Validate anchor is an ARFaceAnchor instance
        guard anchor is ARFaceAnchor,
            let device = sceneView.device else { return nil }

        /// Create node with face geometry
        let faceGeometry = ARSCNFaceGeometry(device: device)
        let node = SCNNode(geometry: faceGeometry)

        node.geometry?.firstMaterial?.colorBufferWriteMask = []

        /// Create eye ImageNodes
       
        rightEyeNode = ImageNode(width: 0.015, height: 0.015, image: UIImage(named: eyeImageName[0])!)
        leftEyeNode = ImageNode(width: 0.015, height: 0.015, image: UIImage(named: eyeImageName[0])! )
      
        

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
