//
//  PhotoViewController.swift
//  ARBeauty
//
//  Created by Huong Lam on 05/25/2021.
//

import UIKit
import CoreGraphics
import Toast_Swift
import FMPhotoPicker




protocol StartSessionProtocol{
   func startSession()
}

protocol  ReloadCollectionPhoto {
    func reloadPhoto()
}

class PhotoViewController: UIViewController, FMImageEditorViewControllerDelegate {
    
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
        let editor = FMImageEditorViewController(config: config(), sourceImage: photoImage)
        editor.delegate = self
        self.present(editor, animated: true)
    }
    
    func fmImageEditorViewController(_ editor: FMImageEditorViewController, didFinishEdittingPhotoWith photo: UIImage) {
           self.dismiss(animated: true, completion: nil)
           photoImageView.image = photo
            CustomPhotoAlbum.sharedInstance.saveImage(image: photo)
       }
       
    
    
    func config() -> FMPhotoPickerConfig {
        let selectMode: FMSelectMode  = .single
        
        var mediaTypes = [FMMediaType]()
        mediaTypes.append(.image)

        
        var config = FMPhotoPickerConfig()
        
        config.selectMode = selectMode
        config.mediaTypes = mediaTypes
        config.maxImage = 1
//        config.forceCropEnabled = forceCropEnabled.isOn
//        config.eclipsePreviewEnabled = eclipsePreviewEnabled.isOn
//
        // in force crop mode, only the first crop option is available
        config.availableCrops = [
            FMCrop.ratioSquare,
            FMCrop.ratioCustom,
            FMCrop.ratio4x3,
            FMCrop.ratio16x9,
            FMCrop.ratio9x16,
            FMCrop.ratioOrigin,
        ]
        
        // all available filters will be used
        config.availableFilters = []
        
        return config
    }
   
}

