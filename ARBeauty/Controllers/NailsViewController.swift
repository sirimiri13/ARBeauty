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

enum PixelError: Error {
    case canNotSetupAVSession
}

class NailsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var navigationBar: NavigationBarFakeView!
    @IBOutlet var cameraView: UIView!
    @IBOutlet weak var pickerColorButton: UIButton!
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
    
    let colorDefault : [UIColor] = [UIColor.red,UIColor.green,UIColor.yellow,UIColor.orange,UIColor.purple,UIColor.gray]
    var colorPicked = UserDefaults.standard.getColorPicked()
    var colorDefaultString: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.colorsCollectionView.register(UINib.init(nibName: "ColorCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ColorCollectionViewCell")
        colorsCollectionView.delegate = self
        colorsCollectionView.dataSource = self
        
        
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
        
        setNavigationBar()
        
        setCollectionView()
        print("color picked: \(colorPicked.count)")
        
    }
    
    func setNavigationBar() {
        navigationBar.titleLabel.text = "NAILS"
        navigationBar.leftButton.setImage(UIImage(systemName: "house.fill"), for: .normal)
        navigationBar.leftButton.addTarget(self, action: #selector(homeTapped), for: .touchUpInside)
    }
    
    @objc func homeTapped() {
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
        let result: UnsafeMutablePointer<UInt8> = model.process(pixelBuffer)
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
    
    
    
    func setCollectionView(){
        // let padding : CGFloat = 5
        let spacing: CGFloat = 10
        colorsCollectionView.showsHorizontalScrollIndicator = false
        
        let layout = UICollectionViewFlowLayout()
        // let frameWidth = colorsCollectionView.frame.size.width
        let itemWidth : CGFloat = 60
        let itemHeight : CGFloat = 60
        colorsCollectionView.backgroundColor = .clear
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumLineSpacing = spacing
        colorsCollectionView.collectionViewLayout = layout
    }
    
    
    func addColorTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        let alertSheet = UIAlertController(title: "Choose color from image", message: "", preferredStyle: .actionSheet)
        let takePhotoAction = UIAlertAction(title: "Take a photo", style: .default) { (action:UIAlertAction) in
            
            imagePickerController.sourceType = .camera;
            self.present(imagePickerController, animated: true, completion: nil)
            
        }
        let choosePhotoFromLibraryAction = UIAlertAction(title: "From Library", style: .default) { (UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("total color : \(colorPicked.count + colorDefault.count + 1)")
        return  colorPicked.count + colorDefault.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCollectionViewCell", for: indexPath) as! ColorCollectionViewCell
        if (indexPath.row == 0) {
            cell.addColorImageView.isHidden = false
        }
        else {
            if (colorPicked.count == 0){
                cell.colorView.backgroundColor = colorDefault[indexPath.row - 1]
            }
            else {
                if (indexPath.row <= colorPicked.count) {
                    let color = UIColor(hexString: colorPicked[indexPath.row - 1])
                    cell.colorView.backgroundColor = color
                }
                else {
                    cell.colorView.backgroundColor = colorDefault[indexPath.row - colorPicked.count - 1]
                }
            }
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath.row == 0){
            self.addColorTapped()
        }
        else {
            
        }
    }
}

extension NailsViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            processFrame(pixelBuffer: pixelBuffer)
        }
    }
}

extension NailsViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate  {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let tempImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.dismiss(animated: true)
        let pickColorVC = UIStoryboard.pickColorViewController()
        pickColorVC?.modalPresentationStyle = .fullScreen
        pickColorVC?.imagePicked = tempImage
        pickColorVC?.delegate = self
        present(pickColorVC!, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension NailsViewController: PickColorProtocol{
    func finishPickColor() {
        // print(UserDefaults.standard.getColorPicked())
        colorPicked = UserDefaults.standard.getColorPicked()
        colorsCollectionView.reloadData()
    }
}
