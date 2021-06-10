//
//  ViewController.swift
//  ARBeauty
//
//  Created by Huong Lam on 02/15/2021.
//

import UIKit
import AVFoundation
import SCLAlertView

class HomeViewController: UIViewController {
    
    @IBOutlet weak var menuBoxView: UIView!
    
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
                    self.present(vc!, animated: true, completion: nil)
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
        checkCameraAuthorizationStatusAndPresentVC(1)
    }
    
    @IBAction func galleryButtonTapped(_ sender: Any) {
        let galleryVC = UIStoryboard.galleryViewController()
        galleryVC.modalPresentationStyle = .fullScreen
        self.present(galleryVC, animated: true, completion: nil)
    }
}
