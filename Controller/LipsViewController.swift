//
//  LipsViewController.swift
//  ARBeauty
//
//  Created by Huong Lam on 02/21/2021.
//

import UIKit

class LipsViewController: UIViewController {

    @IBOutlet weak var lipsTabbar: UITabBar!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initTabbar()
    }
    
    
    func initTabbar(){
        let colorItem = UITabBarItem(title: "Color", image: UIImage(named: "lips"), tag: 0)
        lipsTabbar.items?.append(colorItem)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
