//
//  LipsViewController.swift
//  ARBeauty
//
//  Created by Huong Lam on 02/21/2021.
//

import UIKit

class LipsViewController: UIViewController {
    @IBOutlet weak var colorView: UIView!
    
    @IBOutlet weak var cameraView: UIButton!
    @IBOutlet weak var imageView: UIView!
    //   @IBOutlet weak var lipsTabbar: UITabBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
    }
    
    func setView(){
        cameraView.layer.cornerRadius = cameraView.bounds.height/2
        colorView.addBorder(toEdges: .top, color: UIColor.lightGray, thickness: 0.2)
        imageView.addBorder(toEdges: .top, color: UIColor.lightGray, thickness: 0.2)
        
    }

}
