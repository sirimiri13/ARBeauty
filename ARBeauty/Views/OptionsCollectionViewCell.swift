//
//  OptionsCollectionViewCell.swift
//  ARBeauty
//
//  Created by Huong Lam on 04/18/2021.
//

import UIKit

class OptionsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var optionView: UIView!
    override func awakeFromNib() {
           super.awakeFromNib()
        optionView.layer.cornerRadius = optionView.frame.height * 0.5
           
       }
}
