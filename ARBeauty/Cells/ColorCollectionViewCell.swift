//
//  ColorCollectionViewCell.swift
//  ARBeauty
//
//  Created by Trịnh Vũ Hoàng on 19/04/2021.
//

import UIKit

class ColorCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var addColorImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.colorView.layer.cornerRadius = self.colorView.layer.frame.height / 2
            self.addColorImageView.tintColor = UIColor.blue
            self.addColorImageView.isHidden = true
        }
    }

}
