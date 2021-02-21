//
//  ViewController.swift
//  ARBeauty
//
//  Created by Huong Lam on 02/15/2021.
//

import UIKit

class HomeViewController: UIViewController {
    
    var backgroundView = UIView()
  
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var nailsButton: UIButton!
    @IBOutlet weak var lipsButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!
    
    @IBOutlet weak var buttonStackView: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        backgroundView.frame = self.view.bounds
    }

    func setView(){
        navigationController?.navigationBar.isHidden = true
        nailsButton.setTitle("NAILS", for: .normal)
        lipsButton.setTitle("LIPS", for: .normal)
        galleryButton.setTitle("GALLERY", for: .normal)
        backgroundView = UIView(frame: CGRect.zero)
        backgroundView.layer.contents = UIImage(named: "background")
        self.view.insertSubview(backgroundView, at: 0)

       
    }
    
    @IBAction func lipsTapped(_ sender: Any) {
        let lipsVC = UIStoryboard.lipsViewController()
        navigationController?.pushViewController(lipsVC!, animated: true)
        
    }
    
}

