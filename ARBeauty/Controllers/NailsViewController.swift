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

class NailsViewController: UIViewController {
    
    @IBOutlet var cameraView: UIView!
    
    var model: NailsDeeplabModel!
    var session: AVCaptureSession!
    var videoDataOutput: AVCaptureVideoDataOutput!
    var cameraViewLayer: AVCaptureVideoPreviewLayer!
    var maskView: UIView!
    var selectedDevice: AVCaptureDevice?
    
    static let imageEdgeSize = 257
    static let rgbaComponentsCount = 4
    static let rgbComponentsCount = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
