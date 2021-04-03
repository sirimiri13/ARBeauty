//
//  PickerView.swift
//  ARBeauty
//
//  Created by Huong Lam on 04/03/2021.
//

import UIKit

class PickerView: UIView {
    var contentView : UIView?
        
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
        contentView!.layer.cornerRadius = self.frame.height * 0.5
        contentView!.layer.borderColor = UIColor.white.cgColor
        contentView!.layer.borderWidth = 1
      
       
    }
    func loadViewFromNib() -> UIView? {
           let nib = Bundle.main.loadNibNamed("PickerView", owner: self, options: nil)?.first as? UIView
           return nib
       }

}
