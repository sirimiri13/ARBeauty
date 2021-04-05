//
//  StoryboardManager.swift
//  ARBeauty
//
//  Created by Huong Lam on 02/21/2021.
//

import Foundation
import UIKit

extension UIStoryboard{
    class func mainStoryboard() -> UIStoryboard {
           return UIStoryboard(name: "Main", bundle: Bundle.main)
       }
    
    class func homeViewController() -> HomeViewController? {
          return mainStoryboard().instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
      }
    
    class func nailsViewController() -> NailsViewController?{
        return mainStoryboard().instantiateViewController(withIdentifier: "NailsViewController") as? NailsViewController
    }
    
    class func lipsViewController() -> LipsViewController?{
        return mainStoryboard().instantiateViewController(withIdentifier: "LipsViewController") as? LipsViewController
    }
    
    class func pickColorViewController() -> PickColorViewController?{
        return mainStoryboard().instantiateViewController(withIdentifier: "PickColorViewController") as? PickColorViewController
    }
    
}
