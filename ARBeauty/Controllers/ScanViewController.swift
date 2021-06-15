//
//  ScanViewController.swift
//  ARBeauty
//
//  Created by Huong Lam on 06/04/2021.
//

import UIKit

class ScanViewController: UIViewController, AVCapturePhotoCaptureDelegate{
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var flipHandButton: UIButton!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var handImageView: UIImageView!
    @IBOutlet weak var fakeTabbarBottomConstraint: NSLayoutConstraint!
    
    var delegate: StartSessionProtocol!
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    var isCurrentLeftHand = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            if let window = UIApplication.shared.windows.first {
                if window.safeAreaInsets.bottom > 0 {
                    fakeTabbarBottomConstraint.constant = -53;
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.handImageView.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handImageView.isHidden = true
        customCamera()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    func customCamera() {
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
    
    
    @IBAction func flipTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.2) {
            self.handImageView.transform =  self.isCurrentLeftHand ? CGAffineTransform(scaleX: -1, y: 1) : CGAffineTransform.identity
        } completion: { _ in
            self.isCurrentLeftHand = !self.isCurrentLeftHand
            self.flipHandButton.setTitle(self.isCurrentLeftHand ? "Right" : "Left", for: .normal)
        }
    }
    
    @IBAction func captureTapped(_ sender: Any) {
        captureButton.isSelected = true
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @IBAction func backToHomeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self.delegate.startSession()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        let image = UIImage(data: imageData)
        let designVC = UIStoryboard.designNailsViewController()
        designVC.photoCaptured = image
        designVC.isRightHand = !isCurrentLeftHand
        designVC.modalPresentationStyle = .fullScreen
        self.present(designVC, animated: true, completion: nil)
    }

}
