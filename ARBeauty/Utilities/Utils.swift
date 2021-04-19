//
//  Utils.swift
//  ARBeauty
//
//  Created by Trịnh Vũ Hoàng on 19/04/2021.
//

import UIKit

class Utils: NSObject {
    static func setUserColors(value: [String]) {
        UserDefaults.standard.set(value, forKey: "userColors")
    }
    
    static func getUserColors() -> [String]{
        return UserDefaults.standard.stringArray(forKey: "userColors") ?? []
    }
}
