//
//  ARButton.swift
//  ARBeauty
//
//  Created by Huong Lam on 02/19/2021.
//

import Foundation
import UIKit

class ARButton: UIButton{
    required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            self.layer.cornerRadius = 5.0
            self.layer.borderWidth = 0.2
            self.titleEdgeInsets.left = 5
            self.titleEdgeInsets.right = 5
            self.titleEdgeInsets.top = 5
            self.titleEdgeInsets.bottom = 5
            self.backgroundColor = UIColor.rougePink()
            self.titleLabel?.adjustsFontSizeToFitWidth = true
            self.setTitleColor(UIColor.black, for: .normal)
            self.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
            self.layer.shadowOffset = CGSize(width: 0, height: 3)
            self.layer.shadowOpacity = 1.0
            self.layer.shadowRadius = 10.0
            self.layer.masksToBounds = false
        }

}
