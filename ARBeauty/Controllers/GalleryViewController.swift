//
//  GalleryViewController.swift
//  ARBeauty
//
//  Created by Huong Lam on 06/10/2021.
//

import UIKit
import Photos


class PhotoCell: UICollectionViewCell{
    @IBOutlet weak var photoImageView: UIImageView!
}

class GalleryViewController: UIViewController {
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    var images = [UIImage]()
    let padding: CGFloat = 10
    let spacing: CGFloat = 10
    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionView()
        getPhotos()
    }
    
    func setCollectionView(){
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
          let layout = UICollectionViewFlowLayout()
          let frameWidth = view.frame.size.width
          let itemWidth = (frameWidth - (padding * 2 + spacing))/4
          let itemHeight = itemWidth
          layout.scrollDirection = .vertical
          layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
          layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
          layout.minimumLineSpacing = spacing
        photoCollectionView.collectionViewLayout = layout
      }
    func getAssetThumbnail(assets: [PHAsset]) -> [UIImage] {
            var arrayOfImages = [UIImage]()
            for asset in assets {
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                var image = UIImage()
                option.isSynchronous = true
                manager.requestImage(for: asset, targetSize: CGSize(width: 1500, height: 2102), contentMode: .default, options: option, resultHandler: {(result, info)->Void in
                    image = result!
                    arrayOfImages.append(image)
                })
            }

            return arrayOfImages
        }
    
    func getPhotos(){
       let assets = CustomPhotoAlbum.sharedInstance.getAssetsFromAlbum(albumName: "ARBeauty")
        self.images = getAssetThumbnail(assets: assets)
        photoCollectionView.reloadData()
    }
   
    @IBAction func homeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
      
    extension GalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return images.count
        }
        
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
            cell.photoImageView.image = images[indexPath.row]
            cell.photoImageView.contentMode = .scaleAspectFill
            cell.backgroundColor = UIColor.systemPink
            return cell
        }
        

        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 20
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let photoVC = UIStoryboard.photoViewController()
            photoVC.photoImage = images[indexPath.row]
            photoVC.isGallery = true
            photoVC.modalPresentationStyle = .fullScreen
            self.present(photoVC, animated: true, completion: nil)
        }

    }
