//
//  ScanViewController.swift
//  ARBeauty
//
//  Created by Huong Lam on 05/26/2021.
//

import UIKit
import Foundation
import AVFoundation



class DesignNailsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    @IBOutlet weak var handView: UIView!
    @IBOutlet weak var optionCollectionView: UICollectionView!
    @IBOutlet weak var handImageView: UIImageView!
    @IBOutlet weak var maskNailsView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    
    
    
    @IBOutlet weak var thumbNailsImageView: UIImageView!
    @IBOutlet weak var littleNailsImageView: UIImageView!
    @IBOutlet weak var indexNailsImageView: UIImageView!
    @IBOutlet weak var middleNailsImageView: UIImageView!
    @IBOutlet weak var ringNailsImageView: UIImageView!
    
    
    @IBOutlet weak var testNailsView: NailView!
    
    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var shapeButton: UIButton!
    @IBOutlet weak var styleButton: UIButton!
    var isChooseColor: Bool = true
    var isChooseShape: Bool = false
    
    var isRightHand : Bool = false
    
    var colors: [UIColor] = []
    let defaultColors: [UIColor] = [UIColor.fromHex(value: "FF0000"),
                                    UIColor.fromHex(value: "006699"),
                                    UIColor.fromHex(value: "00FF00"),
                                    UIColor.fromHex(value: "FF6600"),
                                    UIColor.fromHex(value: "330033"),
                                    UIColor.fromHex(value: "99CCCC"),
                                    UIColor.fromHex(value: "FFCC33")]
    
    var selectedIndex: Int = 1
    var selectedColor = UIColor()
    
    
    let shapeImageName : [String] = ["Shape=short",
                                     "Shape=almond",
                                     "Shape=arrowhead",
                                     "Shape=ballerina",
                                     "Shape=lipstick",
                                     "Shape=oval",
                                     "Shape=rounded",
                                     "Shape=stiletto"]
    
    
    let styleImageName: [String] = ["Layer1",
                                    "Layer0",
                                    "nails_inner",
                                    "nails_style0",
                                    "nails_style1",
                                    "nails_style2",
                                    "nails_style3",
                                    "nails_style4",
                                    "nails_style5",
                                    "nails_style6",
                                    "nails_style7"]
    
    var selectedShape: String!
    var selectedStyle: String!
    
    var photoCaptured: UIImage!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        testNailsView.nailImageView.image = UIImage(named: "Shape=almond")
        testNailsView.isUserInteractionEnabled = true
        print(isRightHand)
        if (isRightHand){
            self.maskNailsView.transform = CGAffineTransform(scaleX: -1, y: 1);
        }
        handImageView.image = photoCaptured
        selectedShape = shapeImageName[0]
        selectedColor = defaultColors[0]
      
        colorButton.isSelected = true
        
        
        middleNailsImageView.isUserInteractionEnabled = true
        let pinchMethod = UIPinchGestureRecognizer(target: self, action: #selector(pinchImage(_:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(dragImg(_:)))
        middleNailsImageView.addGestureRecognizer(pinchMethod)
        middleNailsImageView.addGestureRecognizer(panGesture)
        
        
        self.optionCollectionView.register(UINib.init(nibName: "ColorCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ColorCollectionViewCell")
        self.optionCollectionView.register(UINib.init(nibName: "ShapeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ShapeCollectionViewCell")
        self.optionCollectionView.register(UINib.init(nibName: "StyleCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "StyleCollectionViewCell")
        optionCollectionView.delegate = self
        optionCollectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        optionCollectionView.backgroundColor = UIColor.clear
        optionCollectionView.collectionViewLayout = layout
        optionCollectionView.showsHorizontalScrollIndicator = false
        optionCollectionView.backgroundColor = .clear
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.minimumLineSpacing = 10
        
        
        setupColors()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        thumbNailsImageView.transform = CGAffineTransform(rotationAngle: 40 * CGFloat(M_PI)/180);
        littleNailsImageView.transform = CGAffineTransform(rotationAngle: 350 * CGFloat(M_PI)/180);
        
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    

    
    
    @objc func pinchImage(_ sender: UIPinchGestureRecognizer) {
        if sender.state != .changed {
            return
        }
        let scale = sender.scale
        let location = sender.location(in: view)
        let scaleTransform = middleNailsImageView.transform.scaledBy(x: scale, y: scale)
        middleNailsImageView.transform = scaleTransform

        let dx = middleNailsImageView.frame.midX - location.x
        let dy = middleNailsImageView.frame.midY - location.y
        let x = dx * scale - dx
        let y = dy * scale - dy


        let translationTransform = CGAffineTransform(translationX: x, y: y)
        middleNailsImageView.transform = middleNailsImageView.transform.concatenating(translationTransform)

        sender.scale = 1.0

    }
    
    
    @objc func dragImg(_ sender:UIPanGestureRecognizer){
        let translation = sender.translation(in: self.view)
        middleNailsImageView.center = CGPoint(x: middleNailsImageView.center.x + translation.x, y: middleNailsImageView.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func captureTapped(_ sender: Any) {
            let image = UIImage(view: handView)
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func shareTapped(_ sender: Any) {
        let image = UIImage(view: handView)
        let imageShare = [image]
        let activityViewController = UIActivityViewController(activityItems: imageShare as [Any] , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    @IBAction func colorTapped(_ sender: Any) {
        colorButton.isSelected = true
        
        shapeButton.isSelected = false
        styleButton.isSelected = false
        selectedIndex = 1
        middleNailsImageView.image = UIImage(named: selectedShape)
        optionCollectionView.reloadData()
    }
    @IBAction func shapeTapped(_ sender: Any) {
        colorButton.isSelected = false
        shapeButton.isSelected = true
        styleButton.isSelected = false
        selectedIndex = 0
        optionCollectionView.reloadData()
    }
    @IBAction func styleTapped(_ sender: Any) {
        colorButton.isSelected = false
        shapeButton.isSelected = false
        styleButton.isSelected = true
        selectedIndex = 0
        optionCollectionView.reloadData()
    }
    

    
    func setupColors() {
        colors.removeAll()
        let userColors:[String] = Utils.getUserColors()
        for color in userColors {
            colors.append(UIColor.fromHex(value: color))
        }
        colors += defaultColors
        selectedColor = UIColor.fromHex(value: colors[0].toHex(), alpha: 0.7)
        optionCollectionView.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if colorButton.isSelected{
            return  colors.count + 1
        }
        else {
            if shapeButton.isSelected{
                return shapeImageName.count
            }
            else {
                return styleImageName.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if colorButton.isSelected {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCollectionViewCell", for: indexPath) as! ColorCollectionViewCell
            if (indexPath.row == 0) {
                cell.setCell(color: UIColor.clear, isSelected: false, showAddButton: true)
            }
            else {
                if (selectedIndex == indexPath.row) {
                    cell.setCell(color: colors[indexPath.row - 1], isSelected: true, showAddButton: false)
                }
                else {
                    cell.setCell(color: colors[indexPath.row - 1], isSelected: false, showAddButton: false)
                }
            }
            return cell
        }
        else{
            if shapeButton.isSelected{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShapeCollectionViewCell", for: indexPath) as! ShapeCollectionViewCell
                cell.shapeImageView.image = UIImage(named: shapeImageName[indexPath.row])
                if (selectedIndex == indexPath.row) {
                    cell.setCell(isSelected: true)
                }
                else {
                    cell.setCell(isSelected: false)
                }
                return cell
            }
            else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StyleCollectionViewCell", for: indexPath) as! StyleCollectionViewCell
                cell.styleImageView.image = UIImage(named: styleImageName[indexPath.row])
    
                    if (selectedIndex == indexPath.row) {
                        cell.setCell(isSelected: true)
                    }
                    else {
                        cell.setCell(isSelected: false)
                    }
                return cell
            }
            
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if colorButton.isSelected{
            if (indexPath.row == 0) {
                //            self.addColorTapped()
            }
            else {
                selectedIndex = indexPath.row
                selectedColor = UIColor.fromHex(value: colors[indexPath.row - 1].toHex(), alpha: 1)
                setColorNails(color: selectedColor)
                optionCollectionView.reloadData()
            }
        }
        else {
            if shapeButton.isSelected{
                setImageNails(image: UIImage(named: shapeImageName[indexPath.row])!)
                selectedIndex = indexPath.row
                selectedShape = shapeImageName[indexPath.row]
                optionCollectionView.reloadData()
            }
            else {
                setImageNails(image: UIImage(named: styleImageName[indexPath.row])!)
                selectedIndex = indexPath.row
                optionCollectionView.reloadData()
            }
        }
    }
    
    func setImageNails(image: UIImage){
        middleNailsImageView.image =  image
        thumbNailsImageView.image = image
        littleNailsImageView.image = image
        indexNailsImageView.image = image
        ringNailsImageView.image = image
    }
    
    func setColorNails(color: UIColor){
        middleNailsImageView.tintColor =  color
        thumbNailsImageView.tintColor = color
        littleNailsImageView.tintColor = color
        indexNailsImageView.tintColor = color
        ringNailsImageView.tintColor = color
    }
    
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {

        if let error = error {
            view.makeToast("ERROR: Failed to save", duration: 3.0, position: .bottom)
            print(error.localizedDescription)

        } else {
            view.makeToast("Save Photo Successful", duration: 3.0, position: .bottom)
           
        }
    }
    
}
