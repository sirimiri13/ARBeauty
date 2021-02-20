//
//  ViewController.swift
//  ARBeauty
//
//  Created by Huong Lam on 02/15/2021.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nailsButton: UIButton!
    @IBOutlet weak var lipsButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!
    
    @IBOutlet weak var buttonStackView: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
    }

    func setView(){
        nailsButton.setTitle("NAILS", for: .normal)
        lipsButton.setTitle("LIPS", for: .normal)
        galleryButton.setTitle("GALLERY", for: .normal)
        let backgroundImg = UIImageView()
        backgroundImg.image = UIImage(named: "background")
        self.view.addSubview(backgroundImg)
        backgroundImg.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImg.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImg.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImg.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundImg.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        backgroundImg.addSubview(nameLabel)
        backgroundImg.addSubview(buttonStackView)
       
    }
    
  
}

