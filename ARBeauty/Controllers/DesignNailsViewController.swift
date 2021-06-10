//
//  ScanViewController.swift
//  ARBeauty
//
//  Created by Huong Lam on 05/26/2021.
//

import UIKit
import Foundation
import AVFoundation
import CoreGraphics
import PhotosUI

class DesignNailsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate, PickColorProtocol{
  
    
    @IBOutlet weak var handView: UIView!
    @IBOutlet weak var optionCollectionView: UICollectionView!
    @IBOutlet weak var handImageView: UIImageView!
    @IBOutlet weak var maskNailsView: UIView!
    
    
    
    @IBOutlet weak var thumbNailsImageView: UIImageView!
    @IBOutlet weak var littleNailsImageView: UIImageView!
    @IBOutlet weak var indexNailsImageView: UIImageView!
    @IBOutlet weak var middleNailsImageView: UIImageView!
    @IBOutlet weak var ringNailsImageView: UIImageView!
    @IBOutlet weak var scaleSlider: UISlider!
    
    
  
    
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
    
    
    let styleImageName: [String] = ["style_0",
                                    "style_1",
                                    "style_2",
                                    "style_3",
                                    "style_4",
                                    "style_5",
                                    "style_6",
                                    "style_7",]
    
    var selectedShape: String!
    var selectedStyle: String!
    
    var photoCaptured: UIImage!
    
    var isLittle: Bool = false
    var isRing: Bool = false
    var isMiddle: Bool = false
    var isIndex : Bool = false
    var isThumb: Bool = false
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        scaleSlider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2))
        print(isRightHand)
        if (isRightHand){
            self.maskNailsView.transform = CGAffineTransform(scaleX: -1, y: 1);
        }
        handImageView.image = photoCaptured
        selectedShape = shapeImageName[0]
        selectedColor = defaultColors[0]
      
        colorButton.isSelected = true
        
        
      
        
        
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
        setColorNails(color: colors[0].withAlphaComponent(0.7))
        scaleSlider.isUserInteractionEnabled = false
        scaleSlider.tintColor = UIColor.gray
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        thumbNailsImageView.transform = CGAffineTransform(rotationAngle: 40 * CGFloat(M_PI)/180);
        indexNailsImageView.transform = CGAffineTransform(rotationAngle: 10 * CGFloat(M_PI)/180);
        littleNailsImageView.transform = CGAffineTransform(rotationAngle: 350 * CGFloat(M_PI)/180);
        setGesture()
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
  
    func setGesture(){
        let littleTap = UITapGestureRecognizer(target: self, action: #selector(littleNailTapped))
        littleNailsImageView.isUserInteractionEnabled = true
        littleNailsImageView.addGestureRecognizer(littleTap)
        let littleDrag = UIPanGestureRecognizer(target: self, action: #selector(littleNaillDrag(_:)))
        littleNailsImageView.addGestureRecognizer(littleDrag)
        
        
        
        let ringTap = UITapGestureRecognizer(target: self, action: #selector(ringNailTapped))
        ringNailsImageView.isUserInteractionEnabled = true
        ringNailsImageView.addGestureRecognizer(ringTap)
        let ringDrag = UIPanGestureRecognizer(target: self, action: #selector(ringNailDrag(_:)))
        ringNailsImageView.addGestureRecognizer(ringDrag)
        
        
        let middleTap = UITapGestureRecognizer(target: self, action: #selector(middleNailTapped))
        middleNailsImageView.isUserInteractionEnabled = true
        middleNailsImageView.addGestureRecognizer(middleTap)
        let middleDrag = UIPanGestureRecognizer(target: self, action: #selector(middleNailDrag(_:)))
        middleNailsImageView.addGestureRecognizer(middleDrag)
        
        
        let indexTap = UITapGestureRecognizer(target: self, action: #selector(indexNailTapped))
        indexNailsImageView.isUserInteractionEnabled = true
        indexNailsImageView.addGestureRecognizer(indexTap)
        let indexDrag = UIPanGestureRecognizer(target: self, action: #selector(indexNailDrag(_:)))
        indexNailsImageView.addGestureRecognizer(indexDrag)
        
        let thumbTap = UITapGestureRecognizer(target: self, action: #selector(thumbNailTapped))
        thumbNailsImageView.isUserInteractionEnabled = true
        thumbNailsImageView.addGestureRecognizer(thumbTap)
        let thumbDrag = UIPanGestureRecognizer(target: self, action: #selector(thumbNailDrag(_:)))
        thumbNailsImageView.addGestureRecognizer(thumbDrag)
        
        
        let handImageTap = UITapGestureRecognizer(target: self, action: #selector(handImageViewTapped))
        handImageView.isUserInteractionEnabled = true
        handImageView.addGestureRecognizer(handImageTap)
    }

    
    @objc func littleNailTapped(){
        isLittle = true
        isRing = false
        isMiddle = false
        isIndex = false
        isThumb = false
        littleNailsImageView.layer.borderWidth = 1.5
        littleNailsImageView.layer.borderColor = UIColor.blueCustom().cgColor
        ringNailsImageView.layer.borderWidth = 0
        middleNailsImageView.layer.borderWidth = 0
        indexNailsImageView.layer.borderWidth = 0
        thumbNailsImageView.layer.borderWidth = 0
        scaleSlider.isUserInteractionEnabled = true
        scaleSlider.tintColor = UIColor.systemBlue
        print("little tap")
    }
  
    
    @objc func ringNailTapped(){
        isLittle = false
        isRing = true
        isMiddle = false
        isIndex = false
        isThumb = false
        littleNailsImageView.layer.borderWidth = 0
        ringNailsImageView.layer.borderWidth = 1.5
        ringNailsImageView.layer.borderColor = UIColor.blueCustom().cgColor
        middleNailsImageView.layer.borderWidth = 0
        indexNailsImageView.layer.borderWidth = 0
        thumbNailsImageView.layer.borderWidth = 0
        scaleSlider.isUserInteractionEnabled = true
        scaleSlider.tintColor = UIColor.systemBlue
        
    }
  
    
    @objc func middleNailTapped(){
        isLittle = false
        isRing = false
        isMiddle = true
        isIndex = false
        isThumb = false
        littleNailsImageView.layer.borderWidth = 0
        ringNailsImageView.layer.borderWidth = 0
        middleNailsImageView.layer.borderWidth = 1.5
        middleNailsImageView.layer.borderColor = UIColor.blueCustom().cgColor
        indexNailsImageView.layer.borderWidth = 0
        thumbNailsImageView.layer.borderWidth = 0
        scaleSlider.isUserInteractionEnabled = true
        scaleSlider.tintColor = UIColor.systemBlue
    }
    
    
    
    @objc func indexNailTapped(){
        isLittle = false
        isRing = false
        isMiddle = false
        isIndex = true
        isThumb = false
        littleNailsImageView.layer.borderWidth = 0
        ringNailsImageView.layer.borderWidth = 0
        middleNailsImageView.layer.borderWidth = 0
        indexNailsImageView.layer.borderWidth = 1.5
        indexNailsImageView.layer.borderColor = UIColor.blueCustom().cgColor
        thumbNailsImageView.layer.borderWidth = 0
        scaleSlider.isUserInteractionEnabled = true
        scaleSlider.tintColor = UIColor.systemBlue
    }
    
    
    @objc func thumbNailTapped(){
        isLittle = false
        isRing = false
        isMiddle = false
        isIndex = false
        isThumb = true
        
        littleNailsImageView.layer.borderWidth = 0
        ringNailsImageView.layer.borderWidth = 0
        middleNailsImageView.layer.borderWidth = 0
        indexNailsImageView.layer.borderWidth = 0
        thumbNailsImageView.layer.borderWidth = 1.5
        thumbNailsImageView.layer.borderColor = UIColor.blueCustom().cgColor
        scaleSlider.isUserInteractionEnabled = true
        scaleSlider.tintColor = UIColor.systemBlue
    }
    
    
    
    @objc func handImageViewTapped(){
        isLittle = false
        isRing = false
        isMiddle = false
        isIndex = false
        isThumb = false
        littleNailsImageView.layer.borderWidth = 0
        ringNailsImageView.layer.borderWidth = 0
        middleNailsImageView.layer.borderWidth = 0
        indexNailsImageView.layer.borderWidth = 0
        thumbNailsImageView.layer.borderWidth = 0
        
        scaleSlider.isUserInteractionEnabled = false
        scaleSlider.tintColor = UIColor.gray
    }
  
    @objc func littleNaillDrag(_ sender:UIPanGestureRecognizer){
        littleNailsImageView.layer.borderWidth = 1.5
        littleNailsImageView.layer.borderColor = UIColor.blueCustom().cgColor
        ringNailsImageView.layer.borderWidth = 0
        middleNailsImageView.layer.borderWidth = 0
        indexNailsImageView.layer.borderWidth = 0
        thumbNailsImageView.layer.borderWidth = 0
        let translation = sender.translation(in: self.view)
        if (isRightHand){
            littleNailsImageView.center = CGPoint(x: littleNailsImageView.center.x - translation.x, y: littleNailsImageView.center.y + translation.y)

        }
        else {
            littleNailsImageView.center = CGPoint(x: littleNailsImageView.center.x + translation.x, y: littleNailsImageView.center.y + translation.y)
        }
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    @objc func ringNailDrag(_ sender:UIPanGestureRecognizer){
        littleNailsImageView.layer.borderWidth = 0
        ringNailsImageView.layer.borderWidth = 1.5
        ringNailsImageView.layer.borderColor = UIColor.blueCustom().cgColor
        middleNailsImageView.layer.borderWidth = 0
        indexNailsImageView.layer.borderWidth = 0
        thumbNailsImageView.layer.borderWidth = 0
        
        let translation = sender.translation(in: self.view)
        if (isRightHand){
            ringNailsImageView.center = CGPoint(x: ringNailsImageView.center.x - translation.x, y: ringNailsImageView.center.y + translation.y)

        }
        else {
            ringNailsImageView.center = CGPoint(x: ringNailsImageView.center.x + translation.x, y: ringNailsImageView.center.y + translation.y)
        }
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    
    @objc func middleNailDrag(_ sender:UIPanGestureRecognizer){
        littleNailsImageView.layer.borderWidth = 0
        ringNailsImageView.layer.borderWidth = 0
        middleNailsImageView.layer.borderWidth = 1.5
        middleNailsImageView.layer.borderColor = UIColor.blueCustom().cgColor
        indexNailsImageView.layer.borderWidth = 0
        thumbNailsImageView.layer.borderWidth = 0
        let translation = sender.translation(in: self.view)
        if (isRightHand){
            middleNailsImageView.center = CGPoint(x: middleNailsImageView.center.x - translation.x, y: middleNailsImageView.center.y + translation.y)

        }
        else {
            middleNailsImageView.center = CGPoint(x: middleNailsImageView.center.x + translation.x, y: middleNailsImageView.center.y + translation.y)
        }
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    @objc func indexNailDrag(_ sender:UIPanGestureRecognizer){
        littleNailsImageView.layer.borderWidth = 0
        ringNailsImageView.layer.borderWidth = 0
        middleNailsImageView.layer.borderWidth = 0
        indexNailsImageView.layer.borderWidth = 1.5
        indexNailsImageView.layer.borderColor = UIColor.blueCustom().cgColor
        thumbNailsImageView.layer.borderWidth = 0
        
        let translation = sender.translation(in: self.view)
        if (isRightHand){
            indexNailsImageView.center = CGPoint(x: indexNailsImageView.center.x - translation.x, y: indexNailsImageView.center.y + translation.y)

        }
        else {
            indexNailsImageView.center = CGPoint(x: indexNailsImageView.center.x + translation.x, y: indexNailsImageView.center.y + translation.y)
        }
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    
    
    @objc func thumbNailDrag(_ sender:UIPanGestureRecognizer){
        littleNailsImageView.layer.borderWidth = 0
        ringNailsImageView.layer.borderWidth = 0
        middleNailsImageView.layer.borderWidth = 0
        indexNailsImageView.layer.borderWidth = 0
        thumbNailsImageView.layer.borderWidth = 1.5
        thumbNailsImageView.layer.borderColor = UIColor.blueCustom().cgColor
        
        let translation = sender.translation(in: self.view)
        if (isRightHand){
            thumbNailsImageView.center = CGPoint(x: thumbNailsImageView.center.x - translation.x, y: thumbNailsImageView.center.y + translation.y)

        }
        else {
            thumbNailsImageView.center = CGPoint(x: thumbNailsImageView.center.x + translation.x, y: thumbNailsImageView.center.y + translation.y)
        }
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    
    
   
    @IBAction func sliderChangeValue(_ sender: Any) {
        let scaleTransform = CGAffineTransform(scaleX: CGFloat(scaleSlider.value), y: CGFloat(scaleSlider.value))
        if (isLittle){
            littleNailsImageView.transform = CGAffineTransform(rotationAngle: 350 * CGFloat(M_PI)/180).concatenating(scaleTransform)
        }
        else{
            if (isRing){
                ringNailsImageView.transform = scaleTransform
            }
            else {
                if (isMiddle){
                    middleNailsImageView.transform = scaleTransform
                }
                else {
                    if (isIndex){
                        indexNailsImageView.transform = CGAffineTransform(rotationAngle: 10 * CGFloat(M_PI)/180).concatenating(scaleTransform)
                    }
                    else {
                        thumbNailsImageView.transform = CGAffineTransform(rotationAngle: 40 * CGFloat(M_PI)/180).concatenating(scaleTransform)
                    }
                }
            }
        }
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        littleNailsImageView.layer.borderWidth = 0
        ringNailsImageView.layer.borderWidth = 0
        middleNailsImageView.layer.borderWidth = 0
        indexNailsImageView.layer.borderWidth = 0
        thumbNailsImageView.layer.borderWidth = 0
        let image = UIImage(view: handView)
        CustomPhotoAlbum.sharedInstance.saveImage(image: image)
    }
    
    @IBAction func shareTapped(_ sender: Any) {
        let image = UIImage(view: handView)
        let imageShare = [image]
        let activityViewController = UIActivityViewController(activityItems: imageShare as [Any] , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    @IBAction func colorTapped(_ sender: Any) {
        if (styleButton.isSelected){
            setImageNails(image: UIImage(named: "Shape=short")!)
            setColorNails(color: colors[0].withAlphaComponent(0.7))
        }
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
        setColorNails(color: selectedColor)
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
                self.addColorTapped()
            }
            else {
                selectedIndex = indexPath.row
                selectedColor = UIColor.fromHex(value: colors[indexPath.row - 1].toHex(), alpha: 0.7)
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
    
    func addColorTapped() {
        let alertSheet = UIAlertController(title: "Select a color from an image", message: "", preferredStyle: .actionSheet)
        let takePhotoAction = UIAlertAction(title: "Take a photo", style: .default) { (UIAlertAction) in
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .camera;
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
        let choosePhotoFromLibraryAction = UIAlertAction(title: "From Library", style: .default) { (UIAlertAction) in
            var configuration = PHPickerConfiguration()
            configuration.filter = .images
            
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            
            self.present(picker, animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertSheet.addAction(takePhotoAction)
        alertSheet.addAction(choosePhotoFromLibraryAction)
        alertSheet.addAction(cancelAction)
        self.present(alertSheet, animated: true, completion: nil)
    }
    
    
    func didPickColor() {
        selectedIndex = 1
        setupColors()
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let pickedImage = info[.originalImage] as? UIImage
        let pickColorVC = PickerColorViewController()
        pickColorVC.modalPresentationStyle = .fullScreen
        pickColorVC.pickedImage = pickedImage
        pickColorVC.delegate = self
        self.dismiss(animated: true)
        present(pickColorVC, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        let itemProvider = results.first?.itemProvider
        
        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    guard let self = self, let image = image as? UIImage else { return }
                    let pickColorVC = PickerColorViewController()
                    pickColorVC.modalPresentationStyle = .fullScreen
                    pickColorVC.pickedImage = image
                    pickColorVC.delegate = self
                    self.present(pickColorVC, animated: true, completion: nil)
                }
            }
        }
    }
    
}

