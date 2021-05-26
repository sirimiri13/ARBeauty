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
    var maskView = UIView()
    var photoLayer : CALayer!
    var sampleBuffer: CMSampleBuffer!
    
  
  
    
    static let imageEdgeSize = 257
    static let rgbaComponentsCount = 4
    static let rgbComponentsCount = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoImageView.image = photoImage
    }
    
    
   
    
   
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self.delegate.startSession()
    }
    
    @IBAction func saveImageTapped(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(photoImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    @IBAction func shareImageTapped(_ sender: Any) {

        let imageShare = [photoImage]
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
