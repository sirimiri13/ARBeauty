//
//  Nails.swift
//  ARBeauty
//
//  Created by Huong Lam on 06/16/2021.
//

import Foundation
import UIKit

class Nails {
    var isSelect = Bool()
    var isTap = Bool()
    var degree = CGFloat()
    var rotateValue = Float()
    var scale = CGAffineTransform()
    var scaleValue = Float()
    
    init (isSelect: Bool, isTap: Bool, degree: CGFloat, rotateValue: Float, scale: CGAffineTransform, scaleValue: Float){
        self.isSelect = isSelect
        self.isTap = isTap
        self.degree = degree
        self.rotateValue = rotateValue
        self.scale = scale
        self.scaleValue = scaleValue
    }
}
