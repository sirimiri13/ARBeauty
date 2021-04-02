//
//  Extension.swift
//  ARBeauty
//
//  Created by Huong Lam on 02/20/2021.
//

import Foundation
import UIKit

extension UIImage {
    func drawOutlie(imageKeof: CGFloat = 1.01, color: UIColor) -> UIImage? {

            let outlinedImageRect = CGRect(x: 0.0, y: 0.0,
                                       width: size.width * imageKeof,
                                       height: size.height * imageKeof)

            let imageRect = CGRect(x: size.width * (imageKeof - 1) * 0.5,
                               y: size.height * (imageKeof - 1) * 0.5,
                               width: size.width,
                               height: size.height)

            UIGraphicsBeginImageContextWithOptions(outlinedImageRect.size, false, imageKeof)

            draw(in: outlinedImageRect)

            guard let context = UIGraphicsGetCurrentContext() else {return nil}
            context.setBlendMode(.sourceIn)
            context.setFillColor(color.cgColor)
            context.fill(outlinedImageRect)
            draw(in: imageRect)

            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return newImage
        }
    func sRGB() -> UIImage {
    UIGraphicsImageRenderer(size: size).image { _ in
        draw(in: CGRect(origin: .zero, size: size))
    }
    }


func getPixelColor(pos: CGPoint) -> UIColor {
    let pixelData = self.cgImage!.dataProvider!.data
             let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

             let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4

             let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
             let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
             let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
             let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)

             return UIColor(red: r, green: g, blue: b, alpha: a)
    }

}


extension UIButton{
    func customGradient(){
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor.blue.cgColor, UIColor.red.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)

        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height)
        self.layer.insertSublayer(gradient, at: 0)
    }
}


extension UIView {
    func applyGradient(colours: [UIColor]) -> CAGradientLayer {
        return self.applyGradient(colours: colours, locations: nil)
    }
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
        return gradient
    }
    func addBorder(toEdges edges: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        func addBorder(toEdge edges: UIRectEdge, color: UIColor, thickness: CGFloat) {
            let border = CALayer()
            border.backgroundColor = color.cgColor
            
            switch edges {
            case .top:
                border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
            case .bottom:
                border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
            case .left:
                border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
            case .right:
                border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
            default:
                break
            }
            
            layer.addSublayer(border)
        }
        
        if edges.contains(.top) || edges.contains(.all) {
            addBorder(toEdge: .top, color: color, thickness: thickness)
        }
        
        if edges.contains(.bottom) || edges.contains(.all) {
            addBorder(toEdge: .bottom, color: color, thickness: thickness)
        }
        
        if edges.contains(.left) || edges.contains(.all) {
            addBorder(toEdge: .left, color: color, thickness: thickness)
        }
        
        if edges.contains(.right) || edges.contains(.all) {
            addBorder(toEdge: .right, color: color, thickness: thickness)
        }
    }
}

