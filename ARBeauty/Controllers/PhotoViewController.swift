//
//  PhotoViewController.swift
//  ARBeauty
//
//  Created by Huong Lam on 05/25/2021.
//

import UIKit
import CoreGraphics
import Toast_Swift


protocol StartSessionProtocol{
   func startSession()
}
class PhotoViewController: UIViewController {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var saveImageButton: UIButton!
    @IBOutlet weak var shareImageButton: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    
    
    var delegate : StartSessionProtocol!
    var photoImage: UIImage!
    var selectedColor = UIColor()
    var model: DeeplabModel!
    var maskView: UIView!
    var photoLayer : CALayer!
    var sampleBuffer: CMSampleBuffer!
  
    
    static let imageEdgeSize = 257
    static let rgbaComponentsCount = 4
    static let rgbComponentsCount = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoImageView.image = photoImage
        model = DeeplabModel()
        let result = model.load("model_1888")
        if (result == false) {
            fatalError("Can't load model.")
        }
        
      
        photoLayer = CALayer()
        photoLayer.contents = photoImage
        photoImageView.layer.addSublayer(photoLayer)
        maskView = UIView()
        photoImageView.addSubview(maskView)
        photoImageView.bringSubviewToFront(maskView)

//        let pixelBuffer = buffer(from: photoImage)
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            processFrame(pixelBuffer: pixelBuffer)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        maskView.frame = photoImageView.bounds
        photoLayer.frame = photoImageView.bounds
    }
    
   
    func processFrame(pixelBuffer: CVPixelBuffer) {
        let convertedColor = UInt32(selectedColor.switchBlueToRed()!)
        let result: UnsafeMutablePointer<UInt8> = model.process(pixelBuffer, additionalColor: convertedColor)
        
        let buffer = UnsafeMutableRawPointer(result)
        DispatchQueue.main.async { [weak self] in
            self?.draw(buffer: buffer, size: PhotoViewController.imageEdgeSize*PhotoViewController.imageEdgeSize*PhotoViewController.rgbaComponentsCount, pixelBuffer: pixelBuffer)
        }
    }
    
    // Overlay over camera screen.
    func draw(buffer: UnsafeMutableRawPointer, size: Int, pixelBuffer: CVPixelBuffer) {
        let callback:CGDataProviderReleaseDataCallback  = { (pointer: UnsafeMutableRawPointer?, rawPointer: UnsafeRawPointer, size: Int) in }
        
        let width = PhotoViewController.imageEdgeSize
        let height = PhotoViewController.imageEdgeSize
        let bitsPerComponent = 8
        let bitsPerPixel = 32
        let bytesPerRow = PhotoViewController.rgbaComponentsCount * width
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
        
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else { return }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        transform = transform.translatedBy(x: CGFloat(width), y: 0)
        transform = transform.scaledBy(x: -1.0, y: 1.0)
        
        context.concatenate(transform)
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        maskView.layer.contents = context.makeImage()
    }
    
   
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self.delegate.startSession()
    }
    
    @IBAction func saveImageTapped(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(photoImageView.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    @IBAction func shareImageTapped(_ sender: Any) {
        let imageShare = [photoImageView.image]
        let activityViewController = UIActivityViewController(activityItems: imageShare as [Any] , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
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
