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
