//
//  Colors.swift
//  ARBeauty
//
//  Created by Huong Lam on 02/19/2021.
//

import Foundation
import UIKit


extension UIColor {
    convenience init(hexString: String) {
            let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            var int = UInt64()
            Scanner(string: hex).scanHexInt64(&int)
            let a, r, g, b: UInt64
            switch hex.count {
            case 3: // RGB (12-bit)
                (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            case 6: // RGB (24-bit)
                (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
            case 8: // ARGB (32-bit)
                (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
            default:
                (a, r, g, b) = (255, 0, 0, 0)
            }
            self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
        }
    
    
    func toRGBAString(uppercased: Bool = true) -> String {
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            self.getRed(&r, green: &g, blue: &b, alpha: &a)
            let rgba = [r, g, b, a].map { $0 * 255 }.reduce("", { $0 + String(format: "%02x", Int($1)) })
            return uppercased ? rgba.uppercased() : rgba
        }
    
    
    static func rougePink() -> UIColor{
        return UIColor(hexString: "#ffb4b4")
    }
    static func flamingoPink() -> UIColor{
        return UIColor(hexString: "#f78fb3")
    }
    
    static func blueCustom() -> UIColor{
        return UIColor(hexString: "#2d98da")
    }
    
    
}   
