//
//  ShapeCollectionViewCell.swift
//  ARBeauty
//
//  Created by Huong Lam on 05/29/2021.
//

import UIKit

class ShapeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var outlineView: UIView!
    @IBOutlet weak var shapeImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        outlineView.layer.cornerRadius = outlineView.layer.frame.height / 2
        outlineView.layer.borderColor = UIColor.white.cgColor
        outlineView.layer.backgroundColor = UIColor.clear.cgColor
        outlineView.layer.borderWidth = 3
        outlineView.isHidden = true
        shapeImageView.tintColor = UIColor.flamingoPink()
    }
    
    func setCell(isSelected: Bool) {
        if (isSelected) {
            outlineView.isHidden = false
        }
        else {
            outlineView.isHidden = true
        }
    }
}
