//
//  LipsViewController.swift
//  ARBeauty
//
//  Created by Huong Lam on 02/21/2021.
//

import UIKit
import Photos

class LipsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var cameraView: UIButton!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var imageButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
    }
    
    func setView(){
        navigationController?.navigationBar.isHidden = false
        cameraView.layer.cornerRadius = cameraView.bounds.height/2
        colorView.addBorder(toEdges: .top, color: UIColor.lightGray, thickness: 0.2)
        imageView.addBorder(toEdges: .top, color: UIColor.lightGray, thickness: 0.2)
        
        colorButton.setImage(UIImage(named: "lips")?.withTintColor(UIColor.flamingoPink()), for: .normal)
    }
    
    @IBAction func imageTapped(_ sender: Any) {
        selectPhotoFromGallery()
    }
    
    func selectPhotoFromGallery() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        if (checkPermission()){
            self.present(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    func checkPermission() -> Bool {
        var result = false
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            result = true;
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    result = true
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            //   let message = NSLocalizedString("FeedBack.noAccessRight", comment: "No Access Right")
            // showWarningAlert(message: message)
            print("User do not have access to photo album.")
        case .denied:
            // let message = NSLocalizedString("FeedBack.accessDenied", comment: "No Access Right")
            // showWarningAlert(message: message)
            print("User has denied the permission.")
        @unknown default:
            break
        }
        return result
    }
    
    
}
