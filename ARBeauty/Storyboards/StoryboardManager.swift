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
    
    class func trackingViewController() -> TrackingViewController?{
        return mainStoryboard().instantiateViewController(withIdentifier: "TrackingViewController") as? TrackingViewController
    }
    
   
    class func photoViewController() -> PhotoViewController{
        return (mainStoryboard().instantiateViewController(withIdentifier: "PhotoViewController") as? PhotoViewController)!
    }
    
    class func scanViewController() -> ScanViewController{
        return (mainStoryboard().instantiateViewController(withIdentifier: "ScanViewController") as? ScanViewController)!
    }
    
    class func designNailsViewController() -> DesignNailsViewController{
        return (mainStoryboard().instantiateViewController(withIdentifier: "DesignNailsViewController") as? DesignNailsViewController)!
    }
}
