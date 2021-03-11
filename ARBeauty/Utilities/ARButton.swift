//
//  ARButton.swift
//  ARBeauty
//
//  Created by Huong Lam on 02/19/2021.
//

import Foundation
import UIKit

class ARButton: UIButton{
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = self.bounds.height/4
        self.layer.borderWidth = 0.2
        self.titleEdgeInsets.left = 5
        self.titleEdgeInsets.right = 5
        self.titleEdgeInsets.top = 5
        self.titleEdgeInsets.bottom = 5
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.setTitleColor(UIColor.white, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 10.0
        self.layer.masksToBounds = false
        self.titleLabel?.font = UIFont(name: "Noteworthy-Bold", size: 20)
    }
    private lazy var gradientLayer: CAGradientLayer = {
        let l = CAGradientLayer()
        l.frame = self.bounds
        l.colors = [UIColor.flamingoPink().cgColor, UIColor.blueCustom().cgColor]
        l.startPoint = CGPoint(x: -0.5, y: -0.5)
        l.endPoint = CGPoint(x: 1.5, y: 1.5)
        l.cornerRadius = self.bounds.height/4
        layer.insertSublayer(l, at: 0)
        return l
    }()
}
