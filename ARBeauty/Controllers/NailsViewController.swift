//
//  NailsViewController.swift
//  ARBeauty
//
//  Created by Trịnh Vũ Hoàng on 11/03/2021.
//

import UIKit

import Foundation
import AVFoundation
import CoreVideo
import CoreGraphics
import SCLAlertView
import Photos

enum PixelError: Error {
    case canNotSetupAVSession
}

class NailsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PickColorProtocol {
    
    @IBOutlet var cameraView: UIView!
    @IBOutlet weak var colorsCollectionView: UICollectionView!
    
    var model: NailsDeeplabModel!
    var session: AVCaptureSession!
    var videoDataOutput: AVCaptureVideoDataOutput!
    var cameraViewLayer: AVCaptureVideoPreviewLayer!
    var maskView: UIView!
    var selectedDevice: AVCaptureDevice?
    
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
        
        // Setup model and camera
        model = NailsDeeplabModel()
        let result = model.load()
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
        session.sessionPreset = .hd1920x1080
        
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
    
    // Receive result from a model.
    func processFrame(pixelBuffer: CVPixelBuffer) {
        let convertedColor = UInt32(selectedColor.switchBlueToRed()!)
        let result: UnsafeMutablePointer<UInt8> = model.process(pixelBuffer, additionalColor: convertedColor)
        let buffer = UnsafeMutableRawPointer(result)
        DispatchQueue.main.async {
            self.draw(buffer: buffer, size: NailsViewController.imageEdgeSize*NailsViewController.imageEdgeSize*NailsViewController.rgbaComponentsCount)
        }
    }
    
    // Overlay over camera screen.
    func draw(buffer: UnsafeMutableRawPointer, size: Int) {
        let callback:CGDataProviderReleaseDataCallback  = { (pointer: UnsafeMutableRawPointer?, rawPointer: UnsafeRawPointer, size: Int) in }
        
        let width = NailsViewController.imageEdgeSize
        let height = NailsViewController.imageEdgeSize
        let bitsPerComponent = 8
        let bitsPerPixel = 32
        let bytesPerRow = NailsViewController.rgbaComponentsCount * width
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
    func checkLibraryAccess() -> Int {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        switch authStatus {
        case .authorized: return 0
        case .denied: return 1
        case .notDetermined: return 2
        default: return 3
        }
    }
    
    func presentLibrarySettings() {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
    
        alertView.addButton("Settings", target:self, selector:#selector(settingAccess))
        alertView.addButton("Cancel") {
            self.dismiss(animated: true, completion: nil)
        }
        alertView.showWarning("Photo Library Access", subTitle: "This app need photo library access")
    }

    @objc func settingAccess(){
        if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                        })
                    }
    }
    func addColorTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        let alertSheet = UIAlertController(title: "Choose color from image", message: "", preferredStyle: .actionSheet)
        
        let takePhotoAction = UIAlertAction(title: "Take a photo", style: .default) { (action:UIAlertAction) in
            imagePickerController.sourceType = .camera;
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
        let choosePhotoFromLibraryAction = UIAlertAction(title: "From Library", style: .default) { [self] (UIAlertAction) in
            if (self.checkLibraryAccess() == 0){
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            } else {
                if (self.checkLibraryAccess() == 1){
                    self.presentLibrarySettings()
                }
                else { if (self.checkLibraryAccess() == 2) {
                    AVCaptureDevice.requestAccess(for: .video) { success in
                        if success {
                            imagePickerController.sourceType = .photoLibrary
                            self.present(imagePickerController, animated: true, completion: nil)                    }
                    }
                }
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertSheet.addAction(takePhotoAction)
        alertSheet.addAction(choosePhotoFromLibraryAction)
        alertSheet.addAction(cancelAction)
        self.present(alertSheet, animated: true)
    }
    
    func showAlert(withTitle title: String, andMessage message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
        })
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: {() -> Void in
            alert.view.tintColor = UIColor.green
        })
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
    }
}


extension NailsViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            processFrame(pixelBuffer: pixelBuffer)
        }
    }
}

extension NailsViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
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
}
