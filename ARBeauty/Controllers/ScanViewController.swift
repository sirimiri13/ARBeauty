//
//  ScanViewController.swift
//  ARBeauty
//
//  Created by Huong Lam on 05/26/2021.
//

import UIKit
import Foundation
import AVFoundation

class ScanViewController: UIViewController {
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var handView: UIView!
    @IBOutlet weak var handImageView: UIImageView!
    
    @IBOutlet weak var flipButton: UIButton!
    
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    var maskView = UIView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        customCamera()
        handImageView.image = UIImage(named: "hand-left")
    
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
    
}
