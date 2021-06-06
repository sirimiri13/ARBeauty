//
//  NailView.swift
//  ARBeauty
//
//  Created by Huong Lam on 05/31/2021.
//

import UIKit

class NailView: UIView {
    
    @IBOutlet weak var zoomOutButton: UIButton!
    @IBOutlet weak var zoomInButton: UIButton!
    @IBOutlet weak var nailImageView: UIImageView!
    @IBOutlet weak var outlineView: UIView!
    
    var contentView: UIView?
    var image: UIImage!
    var lastScale: CGFloat!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeView()
    }
    
    func initializeView(){
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        contentView = view
        outlineView.backgroundColor = UIColor.clear
        outlineView.addDashBorder()
        outlineView.isHidden = true
        zoomInButton.isHidden = true
        zoomOutButton.isHidden = true
        nailImageView.image = image
        
        
    }
    func loadViewFromNib() -> UIView? {
        let nib = Bundle.main.loadNibNamed("NailView", owner: self, options: nil)?.first as? UIView
        return nib
    }
    
     func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch {
            outlineView.isHidden = false
            zoomInButton.isHidden = false
            zoomOutButton.isHidden = false
            
        }
      }

  
    @IBAction func zoomOutTapped(_ sender: Any) {
        let scale = self.lastScale
        
        
    }
    @IBAction func zoomIntTapped(_ sender: Any) {
    }
}
    
