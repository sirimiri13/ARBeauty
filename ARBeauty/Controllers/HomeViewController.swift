//
//  ViewController.swift
//  ARBeauty
//
//  Created by Huong Lam on 02/15/2021.
//

import UIKit

class HomeViewController: UIViewController {
  
    @IBOutlet weak var menuBoxView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        // menu box view
        menuBoxView.layer.cornerRadius = 30
        menuBoxView.layer.shadowRadius = 30
        menuBoxView.layer.shadowColor = UIColor.lightGray.cgColor
        menuBoxView.layer.shadowOffset = CGSize(width: 0, height: 2)
        menuBoxView.layer.shadowOpacity = 1
    }
    
    
    @IBAction func nailsButtonTapped(_ sender: Any) {
        let nailsVC = UIStoryboard.nailsViewController()
        nailsVC?.modalPresentationStyle = .fullScreen
        self.present(nailsVC!, animated: true, completion: nil)
    }
    
    @IBAction func lipsButtonTapped(_ sender: Any) {
        let lipsVC = UIStoryboard.lipsViewController()
        lipsVC?.modalPresentationStyle = .fullScreen
        self.present(lipsVC!, animated: true, completion: nil)
        
    }
    
}

