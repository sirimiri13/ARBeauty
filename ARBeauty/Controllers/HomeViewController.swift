//
//  ViewController.swift
//  ARBeauty
//
//  Created by Huong Lam on 02/15/2021.
//

import UIKit
import AVFoundation
import SCLAlertView
import ARKit


class HomeViewController: UIViewController {
    
    @IBOutlet weak var menuBoxView: UIView!
    @IBOutlet weak var nailsButton: ARButton!
    @IBOutlet weak var lipsButton: ARButton!
    @IBOutlet weak var lensButton: ARButton!
    @IBOutlet weak var galleryButton: ARButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        // menu box view
        menuBoxView.layer.cornerRadius = 30
        menuBoxView.layer.shadowRadius = 30
        menuBoxView.layer.shadowColor = UIColor.lightGray.cgColor
        menuBoxView.layer.shadowOffset = CGSize(width: 0, height: 2)
        menuBoxView.layer.shadowOpacity = 1
        
        // menu button
        nailsButton.imageView?.contentMode = .scaleAspectFit
        lipsButton.imageView?.contentMode = .scaleAspectFit
        lensButton.imageView?.contentMode = .scaleAspectFit
        galleryButton.imageView?.contentMode = .scaleAspectFit
    }
    
    func checkCameraAuthorizationStatusAndPresentVC(_ option: NSInteger) {
        let vc = UIStoryboard.trackingViewController()
        vc?.isNail = (option == 0) ? true : false
        vc?.modalPresentationStyle = .fullScreen
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            present(vc!, animated: true, completion: nil)
        case .denied:
            let alertView = SCLAlertView(appearance: SCLAlertView.SCLAppearance(
                showCloseButton: false
            ))
            alertView.addButton("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                    })
                }
            }
            alertView.addButton("Cancel") {
            }
            alertView.showWarning("ACCESS DENIED", subTitle: "\"ARBeauty\" Couldn't Access Your Camera")
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.present(vc!, animated: true, completion: nil)
                    }
                }
            }
        default:
            break
        }
    }
    
    @IBAction func nailsButtonTapped(_ sender: Any) {
        checkCameraAuthorizationStatusAndPresentVC(0)
    }
    
    @IBAction func lipsButtonTapped(_ sender: Any) {
        let lipsVC = UIStoryboard.lipsViewController()
        lipsVC.modalPresentationStyle = .fullScreen
        self.present(lipsVC, animated: true, completion: nil)
    }
    
    
    @IBAction func lensButtonTapped(_ sender: Any) {
        if !ARFaceTrackingConfiguration.isSupported{
            let alertVC = SCLAlertView(appearance: SCLAlertView.SCLAppearance(
                showCloseButton: false
            ))

            alertVC.addButton("OK") {
            }
            alertVC.showError("Unsupported Device", subTitle: "This feature requires a device with a TrueDepth front-facing camera")
        }
        else {
            let lenVC = UIStoryboard.lensesViewController()
            lenVC.modalPresentationStyle = .fullScreen
            self.present(lenVC, animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func galleryButtonTapped(_ sender: Any) {
        let galleryVC = UIStoryboard.galleryViewController()
        galleryVC.modalPresentationStyle = .fullScreen
        self.present(galleryVC, animated: true, completion: nil)
    }
}
