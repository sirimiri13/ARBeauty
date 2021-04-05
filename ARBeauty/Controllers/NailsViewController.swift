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


class OptionCollectionViewCell: UICollectionViewCell{
    @IBOutlet weak var optionView: UIView!
    override func awakeFromNib() {
           super.awakeFromNib()
        optionView.layer.cornerRadius = optionView.frame.height * 0.5
           
       }

    
}


enum PixelError: Error {
    case canNotSetupAVSession
}

class NailsViewController: UIViewController{
    
    @IBOutlet var cameraView: UIView!
    @IBOutlet weak var pickerColorButton: UIButton!
    @IBOutlet weak var optionCollectionView: UICollectionView!
    
    var model: NailsDeeplabModel!
    var session: AVCaptureSession!
    var videoDataOutput: AVCaptureVideoDataOutput!
    var cameraViewLayer: AVCaptureVideoPreviewLayer!
    var maskView: UIView!
    var selectedDevice: AVCaptureDevice?
    
    static let imageEdgeSize = 257
    static let rgbaComponentsCount = 4
    static let rgbComponentsCount = 3
    
    
    
    let colorDefault : [UIColor] = [UIColor.rougePink(),UIColor.red,UIColor.green,UIColor.yellow,UIColor.orange,UIColor.purple,UIColor.gray]
    let colorPicked = UserDefaults.standard.getColorPicked()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(colorPicked)
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
        
        setCollectionView()
        
        
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
        optionCollectionView.showsHorizontalScrollIndicator = false
    
            let layout = UICollectionViewFlowLayout()
           // let frameWidth = optionCollectionView.frame.size.width
            let itemWidth : CGFloat = 60
            let itemHeight : CGFloat = 60
            optionCollectionView.backgroundColor = .clear
            layout.scrollDirection = .horizontal
            layout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
            layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
            layout.minimumLineSpacing = spacing
        optionCollectionView.collectionViewLayout = layout
        }

    
    func addColorTapped(){
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
    
    // MARK: - Button actions
    @IBAction func homeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension NailsViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            processFrame(pixelBuffer: pixelBuffer)
        }
    }
}

extension NailsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorDefault.count + colorPicked.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OptionCollectionViewCell", for: indexPath) as! OptionCollectionViewCell
        if (indexPath.row == 0){
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: "plus.circle")?.withTintColor(UIColor.black)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            cell.optionView.addSubview(imageView)
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: cell.optionView.topAnchor),
                imageView.bottomAnchor.constraint(equalTo: cell.optionView.bottomAnchor),
                imageView.rightAnchor.constraint(equalTo: cell.optionView.rightAnchor),
                imageView.leftAnchor.constraint(equalTo: cell.optionView.leftAnchor),
            ])
            cell.optionView.backgroundColor = UIColor.clear

        }
        else{
            if (colorPicked.count == 0){
                cell.optionView.backgroundColor = colorDefault[indexPath.row - 1]
            }
            else {
                if indexPath.row <= colorPicked.count {
                    cell.optionView.backgroundColor = UIColor(hexString: colorPicked[indexPath.row - 1])
                }
                else{
                    cell.optionView.backgroundColor = colorDefault[indexPath.row - colorPicked.count]
                }
            }
        }
        
       
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath.row == 0){
            self.addColorTapped()
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
        print(UserDefaults.standard.getColorPicked())
        DispatchQueue.main.async { [self] in
            optionCollectionView.reloadData()
        }
       
    }
    
    
}
