//
//  NavigationBarFakeView.swift
//  ARBeauty
//
//  Created by Huong Lam on 04/05/2021.
//

import UIKit


class NavigationBarFakeView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    
    var contentView : UIView?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        initializeView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeView()
    }
    
    func initializeView(){
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        contentView = view
        titleLabel.font = UIFont(name: "Noteworthy-Bold", size: 18)
        titleLabel.textColor = .darkGray
        leftButton.tintColor = .darkGray
    }
    
    func loadViewFromNib() -> UIView? {
        let nib = Bundle.main.loadNibNamed("NavigationBarFakeView", owner: self, options: nil)?.first as? UIView
        return nib
    }
    
}
