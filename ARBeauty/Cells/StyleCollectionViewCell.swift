//
//  StyleCollectionViewCell.swift
//  ARBeauty
//
//  Created by Huong Lam on 05/30/2021.
//

import UIKit

class StyleCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var outlineView: UIView!
    @IBOutlet weak var styleImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        outlineView.layer.cornerRadius = outlineView.layer.frame.height / 2
        outlineView.layer.borderColor = UIColor.white.cgColor
        outlineView.layer.backgroundColor = UIColor.clear.cgColor
        outlineView.layer.borderWidth = 3
        outlineView.isHidden = true
        styleImageView.layer.cornerRadius = styleImageView.layer.frame.height / 2
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
