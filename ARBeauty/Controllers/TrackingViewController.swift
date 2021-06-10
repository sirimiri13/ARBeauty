//
//  TrackingViewController.swift
//  ARBeauty
//
//  Created by Trịnh Vũ Hoàng on 11/03/2021.
//

import UIKit

import Foundation
import AVFoundation
import CoreVideo
import CoreGraphics
import PhotosUI


enum PixelError: Error {
    case canNotSetupAVSession
}

class TrackingViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PickColorProtocol, StartSessionProtocol {
   
    
    @IBOutlet var cameraView: UIView!
    @IBOutlet weak var colorsCollectionView: UICollectionView!
    @IBOutlet weak var designButton: UIButton!
    
    @IBOutlet weak var titleNavBarTitle: UILabel!
    
    
    var model: DeeplabModel!
    var session: AVCaptureSession!

    var videoDataOutput: AVCaptureVideoDataOutput!
    
    var cameraViewLayer: AVCaptureVideoPreviewLayer!
    var maskView: UIView!
    var selectedDevice: AVCaptureDevice?
    let previewLayerConnection : AVCaptureConnection! = nil
    var photoOutput = AVCapturePhotoOutput()
    var stillImageOutput = AVCapturePhotoOutput()
    
    var isCapture = false
    var captureImage : UIImage!
    var isNail: Bool = true
    
    
    
    static let imageEdgeSize = 257
    static let rgbaComponentsCount = 4
    static let rgbComponentsCount = 3
    
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        // Setup CollectionView
        self.colorsCollectionView.register(UINib.init(nibName: "ColorCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ColorCollectionViewCell")
        colorsCollectionView.delegate = self
        colorsCollectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        colorsCollectionView.backgroundColor = UIColor.clear
        colorsCollectionView.collectionViewLayout = layout
        colorsCollectionView.showsHorizontalScrollIndicator = false
        colorsCollectionView.backgroundColor = .clear
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.minimumLineSpacing = 10
        
        setupColors()
        
        designButton.setTitleColor(UIColor.flamingoPink(), for: .normal)
        
        // Setup model and camera
        
        loadModel()
       
        if !isNail {
            designButton.isHidden = true
            titleNavBarTitle.text = "LIPS"
        }
    }
    
    
    func loadModel(){
        model = DeeplabModel()
        if (isNail){
            let result = model.load("model_1900")
            if (result == false) {
                fatalError("Can't load model.")
            }
            do {
                try setupAVCapture(position: .back)
            }
            catch {
                print(error)
            }
        }
        else {
            let result = model.load("model002")
            if (result == false) {
                fatalError("Can't load model.")
            }
            do {
                try setupAVCapture(position: .front)
            }
            catch {
                print(error)
            }
        }
        
    }
    
    
    func setupColors() {
        colors.removeAll()
        let userColors:[String] = Utils.getUserColors()
        for color in userColors {
            colors.append(UIColor.fromHex(value: color))
        }
        colors += defaultColors
        selectedColor = UIColor.fromHex(value: colors[0].toHex(), alpha: 0.7)
        colorsCollectionView.reloadData()
    }
    
    @IBAction func homeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Setup AVCapture session and AVCaptureDevice.
    func setupAVCapture(position: AVCaptureDevice.Position) throws {
        
        if let existedSession = session, existedSession.isRunning {
            existedSession.stopRunning()
        }
        
        session = AVCaptureSession()
        session.sessionPreset = .hd1280x720
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: position) else {
            throw PixelError.canNotSetupAVSession
        }
        selectedDevice = device
        let deviceInput = try AVCaptureDeviceInput(device: device)
        guard session.canAddInput(deviceInput) else {
            throw PixelError.canNotSetupAVSession
        }
        session.addInput(deviceInput)
        
        videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA]
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        
        guard session.canAddOutput(videoDataOutput) else {
            throw PixelError.canNotSetupAVSession
        }
        
        session.addOutput(videoDataOutput)
        
        guard let connection = videoDataOutput.connection(with: .video) else {
            throw PixelError.canNotSetupAVSession
        }
        
        connection.isEnabled = true
        preparecameraViewLayer(for: session)
        session.startRunning()
    }
    
    
    func setupLivePreview() {
        cameraViewLayer = AVCaptureVideoPreviewLayer(session: session)
        cameraViewLayer.videoGravity = .resizeAspect
        cameraViewLayer.connection?.videoOrientation = .portrait
        cameraView.layer.addSublayer(cameraViewLayer)
        
    }
    
    // Setup cameraView screen.
    func preparecameraViewLayer(for session: AVCaptureSession) {
        guard cameraViewLayer == nil else {
            cameraViewLayer.session = session
            return
        }
        
        cameraViewLayer = AVCaptureVideoPreviewLayer(session: session)
        cameraViewLayer.backgroundColor = UIColor.black.cgColor
        cameraViewLayer.videoGravity = .resizeAspectFill
        cameraView.layer.addSublayer(cameraViewLayer)
        
        maskView = UIView()
        cameraView.addSubview(maskView)
        cameraView.bringSubviewToFront(maskView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        maskView.frame = cameraView.bounds
        cameraViewLayer.frame = cameraView.bounds
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.session.stopRunning()
    }
    
    // Receive result from a model.
    func processFrame(pixelBuffer: CVPixelBuffer) {
        let convertedColor = UInt32(selectedColor.switchBlueToRed()!)
        let result: UnsafeMutablePointer<UInt8> = model.process(pixelBuffer, additionalColor: convertedColor)
        let buffer = UnsafeMutableRawPointer(result)
        DispatchQueue.main.async { [weak self] in
            self?.draw(buffer: buffer, size: TrackingViewController.imageEdgeSize*TrackingViewController.imageEdgeSize*TrackingViewController.rgbaComponentsCount, pixelBuffer: pixelBuffer)
        }
    }
    
    // Overlay over camera screen.
    func draw(buffer: UnsafeMutableRawPointer, size: Int, pixelBuffer: CVPixelBuffer) {
        let callback:CGDataProviderReleaseDataCallback  = { (pointer: UnsafeMutableRawPointer?, rawPointer: UnsafeRawPointer, size: Int) in }
        
        let width = TrackingViewController.imageEdgeSize
        let height = TrackingViewController.imageEdgeSize
        let bitsPerComponent = 8
        let bitsPerPixel = 32
        let bytesPerRow = TrackingViewController.rgbaComponentsCount * width
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let bitmapInfo: CGBitmapInfo = CGBitmapInfo(rawValue: CGImageByteOrderInfo.orderDefault.rawValue).union(CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue))
        
        let renderingIntent: CGColorRenderingIntent = CGColorRenderingIntent.defaultIntent
        guard let provider = CGDataProvider(dataInfo: nil,
                                            data: buffer,
                                            size: size,
                                            releaseData: callback) else { return }
        
        guard let cgImage = CGImage(width: width,
                                    height: height,
                                    bitsPerComponent: bitsPerComponent,
                                    bitsPerPixel: bitsPerPixel,
                                    bytesPerRow: bytesPerRow,
                                    space: colorSpace,
                                    bitmapInfo: bitmapInfo,
                                    provider: provider,
                                    decode: nil,
                                    shouldInterpolate: false,
                                    intent: renderingIntent) else { return }
        
        if let device = selectedDevice, device.position == .front {
            maskView.layer.contents = cgImage
            return
        }
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else { return }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        transform = transform.translatedBy(x: CGFloat(width), y: 0)
        transform = transform.scaledBy(x: -1.0, y: 1.0)
        
        context.concatenate(transform)
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))

        maskView.layer.contents = context.makeImage()
        
        
        
    }
    
    // MARK: - Handle tap events
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
    
    // MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  colors.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath.row == 0) {
            self.addColorTapped()
        }
        else {
            selectedIndex = indexPath.row
            selectedColor = UIColor.fromHex(value: colors[indexPath.row - 1].toHex(), alpha: 0.7)
            colorsCollectionView.reloadData()
        }
    }
    
    // MARK: - PickColorProtocol
    func didPickColor() {
        selectedIndex = 1
        setupColors()
        session.startRunning()
    }
    
    
    @IBAction func captureButtonTapped(_ sender: Any) {
        isCapture = true
        let shutterView = UIView(frame: cameraView.frame)
        shutterView.backgroundColor = UIColor.white
        view.addSubview(shutterView)
        UIView.animate(withDuration: 0.8, animations: {
            shutterView.alpha = 0
        }, completion: { (_) in
            shutterView.removeFromSuperview()
        })
    }
    
    @IBAction func desginTapped(_ sender: Any) {
        weak var pvc = self.presentingViewController
        self.dismiss(animated: true, completion: {
            let vc =  UIStoryboard.scanViewController()
            vc.modalPresentationStyle = .fullScreen
            pvc?.present(vc, animated: true, completion: nil)
        })
    }
    
    func getImageFromSampleBuffer (buffer:CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect) {
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
            
        }
        
        return nil
    }
    
    func startSession() {
        session.startRunning()
    }
   
}


extension TrackingViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("running.......")
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            processFrame(pixelBuffer: pixelBuffer)
        }
        if isCapture {
            isCapture = false
            if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer) {
                DispatchQueue.main.async { [self] in
                let reversedImage : UIImage!
                let resultImage : UIImage!
                let maskImage = UIImage(view: maskView)
                if !isNail{
                    reversedImage = UIImage(cgImage: image.cgImage!, scale: 1, orientation: .leftMirrored)
                    resultImage = Utils.overlayLayerToImage(image:reversedImage, overlay:(maskImage), scaleOverlay:true)!
                }
                else {
                    resultImage = Utils.overlayLayerToImage(image:image, overlay:(maskImage), scaleOverlay:true)!
                }
                    let photoViewController = UIStoryboard.photoViewController()
                    photoViewController.delegate = self
                    photoViewController.photoImage = resultImage
                    photoViewController.modalPresentationStyle = .fullScreen
                    present(photoViewController, animated: true, completion: nil)
                  
                }
            }
            
            
        }
    }
}


extension TrackingViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate {
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
