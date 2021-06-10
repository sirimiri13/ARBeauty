//
//  CustomAlbum.swift
//  ARBeauty
//
//  Created by Huong Lam on 06/10/2021.
//

import Foundation
import Photos
import Toast_Swift


class CustomPhotoAlbum {

    static let albumName = "ARBeauty"
    static let sharedInstance = CustomPhotoAlbum()

    var assetCollection: PHAssetCollection!

    init() {

        func fetchAssetCollectionForAlbum() -> PHAssetCollection! {

            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

            if let firstObject: AnyObject = collection.firstObject {
                return collection.firstObject as! PHAssetCollection
            }

            return nil
        }

        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }

        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: CustomPhotoAlbum.albumName)
        }) { success, _ in
            if success {
                self.assetCollection = fetchAssetCollectionForAlbum()
            }
        }
    }

    func saveImage(image: UIImage) {
        let topVC = UIApplication.getTopViewController()
        if assetCollection == nil {
            topVC?.view.makeToast("Can not save this photo", duration: 3.0, position: .bottom)
            return   // If there was an error upstream, skip the save.
        }
        topVC?.view.makeToast("Save Photo Successful", duration: 3.0, position: .bottom)
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            albumChangeRequest!.addAssets([assetPlaceholder] as NSFastEnumeration)
        }, completionHandler: nil)
    }


}
