//
//  ColorCollectionViewCell.swift
//  ARBeauty
//
//  Created by Trịnh Vũ Hoàng on 19/04/2021.
//

import UIKit

class ColorCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var outlineView: UIView!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var addColorImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        colorView.layer.cornerRadius = colorView.layer.frame.height / 2
        addColorImageView.tintColor = UIColor.white
        addColorImageView.isHidden = true
        outlineView.layer.cornerRadius = outlineView.layer.frame.height / 2
        outlineView.layer.borderColor = UIColor.white.cgColor
        outlineView.layer.borderWidth = 3
        outlineView.isHidden = true
    }
    
    func setCell(color: UIColor, isSelected: Bool, showAddButton: Bool) {
        colorView.layer.backgroundColor = color.cgColor
        if (isSelected) {
            outlineView.isHidden = false
        }
        else {
            outlineView.isHidden = true
        }
        addColorImageView.isHidden = !showAddButton
    }
}
