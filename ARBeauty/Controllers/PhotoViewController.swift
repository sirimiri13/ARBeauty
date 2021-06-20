//
//  PhotoViewController.swift
//  ARBeauty
//
//  Created by Huong Lam on 05/25/2021.
//

import UIKit
import CoreGraphics
import Toast_Swift
import Sharaku



protocol StartSessionProtocol{
   func startSession()
}

protocol  ReloadCollectionPhoto {
    func reloadPhoto()
}

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var saveImageButton: UIButton!
    @IBOutlet weak var shareImageButton: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    
    var delegate : StartSessionProtocol!
    var reloadPhotoDelegate: ReloadCollectionPhoto!
    var photoImage: UIImage!
    var selectedColor = UIColor()
    var model: DeeplabModel!
    var maskView = UIView()
    var photoLayer : CALayer!
    var sampleBuffer: CMSampleBuffer!
    var isGallery: Bool = false
    
    static let imageEdgeSize = 257
    static let rgbaComponentsCount = 4
    static let rgbComponentsCount = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoImageView.image = photoImage
        if isGallery {
            saveImageButton.isHidden = true
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        if !isGallery {
            self.delegate.startSession()
        }
        else{
            self.reloadPhotoDelegate.reloadPhoto()
        }
        
    }
    
    @IBAction func saveImageTapped(_ sender: Any) {
        CustomPhotoAlbum.sharedInstance.saveImage(image: photoImage)
    }
    
    @IBAction func shareImageTapped(_ sender: Any) {
        let imageShare = [photoImage]
        let activityViewController = UIActivityViewController(activityItems: imageShare as [Any] , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func filterTapped(_ sender: Any) {
        let vc = SHViewController(image:photoImage)
        vc.modalPresentationStyle = .fullScreen
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
}

extension PhotoViewController: SHViewControllerDelegate {
    func shViewControllerImageDidFilter(image: UIImage) {
        CustomPhotoAlbum.sharedInstance.saveImage(image: image)
        photoImageView.image = image
    }
    func shViewControllerDidCancel() {
    }
}
