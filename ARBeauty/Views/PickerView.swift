//
//  PickerView.swift
//  ARBeauty
//
//  Created by Huong Lam on 04/03/2021.
//

import UIKit

class PickerView: UIView {
    var contentView : UIView?
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
        override init(frame: CGRect) {
            super.init(frame: frame)
            initializeView()

        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
        

    
    
    func initializeView(){

        guard let view = loadViewFromNib() else { return }
                view.frame = self.bounds
                self.addSubview(view)
                contentView = view
        contentView?.backgroundColor = UIColor.clear
        topView.layer.cornerRadius = topView.frame.height * 0.5
        topView.layer.borderColor = UIColor.white.cgColor
        topView.layer.borderWidth = 1
        
        bottomView.layer.cornerRadius = bottomView.frame.height * 0.5
        bottomView.layer.borderColor = UIColor.white.cgColor
        bottomView.layer.borderWidth = 1
    }
    
    func setColor(color: UIColor){
        topView.backgroundColor = color
        bottomView.backgroundColor = color
    }
    
    
    func loadViewFromNib() -> UIView? {
           let nib = Bundle.main.loadNibNamed("PickerView", owner: self, options: nil)?.first as? UIView
           return nib
       }

}
