//
//  Utils.swift
//  ARBeauty
//
//  Created by Trịnh Vũ Hoàng on 19/04/2021.
//

import UIKit

class Utils: NSObject {
    static func addUserColors(value: String) {
        var userColors = Utils.getUserColors()
        let newColor = value
        userColors.insert(String(newColor), at: 0)
        if (userColors.count > 5) {
            userColors.removeLast()
        }
        UserDefaults.standard.set(userColors, forKey: "userColors")
    }
    
    static func getUserColors() -> [String] {
        return UserDefaults.standard.stringArray(forKey: "userColors") ?? []
    }
    
}
