//
//  ViewController.swift
//  ARBeauty
//
//  Created by Huong Lam on 02/15/2021.
//

import UIKit
import AVFoundation
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
    func checkCamera() -> Int {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
        case .authorized: return 0
        case .denied: return 1
        case .notDetermined: return 2
        default: return 3
        }
    }

    func presentCameraSettings() {
        let alertController = UIAlertController(title: "Error",
                                      message: "Camera access is denied",
                                      preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                    // Handle
                })
            }
        })

        present(alertController, animated: true)
    }
    @IBAction func nailsButtonTapped(_ sender: Any) {
        if (checkCamera() == 0){
            let nailsVC = UIStoryboard.nailsViewController()
            nailsVC?.modalPresentationStyle = .fullScreen
            self.present(nailsVC!, animated: true, completion: nil)
        } else {
            if (checkCamera() == 1){
            presentCameraSettings()
            }
            else { if (checkCamera() == 2) {
                AVCaptureDevice.requestAccess(for: .video) { success in
                    if success {
                        let nailsVC = UIStoryboard.nailsViewController()
                        nailsVC?.modalPresentationStyle = .fullScreen
                        self.present(nailsVC!, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
    
    @IBAction func lipsButtonTapped(_ sender: Any) {
        let lipsVC = UIStoryboard.lipsViewController()
        lipsVC?.modalPresentationStyle = .fullScreen
        self.present(lipsVC!, animated: true, completion: nil)
    }
    
    
    
    
}

