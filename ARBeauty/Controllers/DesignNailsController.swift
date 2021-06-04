//
//  ScanViewController.swift
//  ARBeauty
//
//  Created by Huong Lam on 05/26/2021.
//

import UIKit
import Foundation
import AVFoundation



class DesignNailsController: UIViewController, AVCapturePhotoCaptureDelegate , UICollectionViewDataSource, UICollectionViewDelegate{
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var handView: UIView!
    @IBOutlet weak var optionCollectionView: UICollectionView!
    @IBOutlet weak var handImageView: UIImageView!
    @IBOutlet weak var maskNailsView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    
    
    @IBOutlet weak var flipButton: UIButton!
    
    @IBOutlet weak var thumbNailsImageView: UIImageView!
    @IBOutlet weak var littleNailsImageView: UIImageView!
    @IBOutlet weak var indexNailsImageView: UIImageView!
    @IBOutlet weak var middleNailsImageView: UIImageView!
    @IBOutlet weak var ringNailsImageView: UIImageView!
    
    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var shapeButton: UIButton!
    @IBOutlet weak var styleButton: UIButton!
    var isChooseColor: Bool = true
    var isChooseShape: Bool = false
    
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
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
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedShape = shapeImageName[0]
        selectedColor = defaultColors[0]
      
        colorButton.isSelected = true
        
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
        customCamera()
       // handImageView.image = UIImage(named: "handleft")
        thumbNailsImageView.transform = CGAffineTransform(rotationAngle: 40 * CGFloat(M_PI)/180);
        
        littleNailsImageView.transform = CGAffineTransform(rotationAngle: 350 * CGFloat(M_PI)/180);
        
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    
   
    
    
    func customCamera(){
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        else {
            print("Unable to access back camera!")
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            stillImageOutput = AVCapturePhotoOutput()
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
        
        
    }
    
    func setupLivePreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        cameraView.layer.addSublayer(videoPreviewLayer)
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.cameraView.bounds
            }
        }
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
        let translation = sender.translation(in: self.handView)
        middleNailsImageView.center = CGPoint(x: middleNailsImageView.center.x + translation.x, y: middleNailsImageView.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    
    @IBAction func flippedTapped(_ sender: Any) {
        if flipButton.isSelected{
            flipButton.isSelected = false
            self.handView.transform = CGAffineTransform(scaleX: 1, y: 1);
            
        }
        else {
            flipButton.isSelected = true
            self.handView.transform = CGAffineTransform(scaleX: -1, y: 1);
            
        }
    }
    
    @IBAction func captureTapped(_ sender: Any) {
        if captureButton.isSelected{
            captureButton.isSelected = false
            let image = UIImage(view: handView)
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        else{
            captureButton.isSelected = true
            let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
            stillImageOutput.capturePhoto(with: settings, delegate: self)
            middleNailsImageView.isUserInteractionEnabled = true
        }
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
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation()
        else { return }
        
        let image = UIImage(data: imageData)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = handView.frame
        handImageView.removeFromSuperview()
        handView.addSubview(imageView)
        handView.bringSubviewToFront(maskNailsView)
        
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
//                var maskView = NailMask()
//                maskView.image = UIImage(named: styleImageName[indexPath.row])
//                maskView.shape = selectedShape
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
