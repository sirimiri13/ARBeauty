//
//  Extension.swift
//  ARBeauty
//
//  Created by Huong Lam on 02/20/2021.
//

import Foundation
import UIKit

extension UIImage { func sRGB() -> UIImage {
    UIGraphicsImageRenderer(size: size).image { _ in
        draw(in: CGRect(origin: .zero, size: size))
    }
}


func getPixelColor(pos: CGPoint) -> UIColor {
    guard let cgImage = cgImage,
        let dataProvider = cgImage.dataProvider,
        let data = dataProvider.data else { return .white }
    let pixelData: UnsafePointer<UInt8> = CFDataGetBytePtr(data)

    let remaining = 8 - ((Int(size.width) * 2) % 8)
    let padding = (remaining < 8) ? remaining : 0
    let pixelInfo: Int = (((Int(size.width) * 2 + padding) * Int(pos.y * 2)) + Int(pos.x) * 2) * 4
        
    let r = CGFloat(pixelData[pixelInfo]) / CGFloat(255.0)
    let g = CGFloat(pixelData[pixelInfo+1]) / CGFloat(255.0)
    let b = CGFloat(pixelData[pixelInfo+2]) / CGFloat(255.0)
    let a = CGFloat(pixelData[pixelInfo+3]) / CGFloat(255.0)
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


extension UIView{
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

