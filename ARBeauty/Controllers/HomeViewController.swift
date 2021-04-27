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
    
    @IBAction func nailsButtonTapped(_ sender: Any) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            let nailsVC = UIStoryboard.nailsViewController()
            nailsVC?.modalPresentationStyle = .fullScreen
            present(nailsVC!, animated: true, completion: nil)
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
            AVCaptureDevice.requestAccess(for: .video) { success in
                if success {
                    let nailsVC = UIStoryboard.nailsViewController()
                    nailsVC?.modalPresentationStyle = .fullScreen
                    self.present(nailsVC!, animated: true, completion: nil)
                }
            }
        default:
            break
        }
    }
    
    @IBAction func lipsButtonTapped(_ sender: Any) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            let lipsVC = UIStoryboard.lipsViewController()
            lipsVC?.modalPresentationStyle = .fullScreen
            present(lipsVC!, animated: true, completion: nil)
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
            AVCaptureDevice.requestAccess(for: .video) { success in
                if success {
                    let nailsVC = UIStoryboard.nailsViewController()
                    nailsVC?.modalPresentationStyle = .fullScreen
                    self.present(nailsVC!, animated: true, completion: nil)
                }
            }
        default:
            break
        }
    }
    
}
