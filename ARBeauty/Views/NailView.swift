//
//  NailView.swift
//  ARBeauty
//
//  Created by Huong Lam on 05/31/2021.
//

import UIKit

class NailView: UIView {
    @IBOutlet weak var zoomButton: UIButton!
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
        nailImageView.image = image
        
        
    }
    func loadViewFromNib() -> UIView? {
        let nib = Bundle.main.loadNibNamed("NailView", owner: self, options: nil)?.first as? UIView
        return nib
    }
    
    @IBAction func scalePiece(_ gestureRecognizer: UIPinchGestureRecognizer?) {
        if gestureRecognizer?.state == .began {
            // Reset the last scale, necessary if there are multiple objects with different scales
            lastScale = gestureRecognizer?.scale
        }

        if gestureRecognizer?.state == .began || gestureRecognizer?.state == .changed {
            var newScale = 1 -  (lastScale - gestureRecognizer!.scale)
            changeScale(newScale: newScale)
            lastScale = gestureRecognizer?.scale
        }
        
}
    
    func changeScale(newScale: CGFloat){
        let transform = self.transform.scaledBy(x: newScale, y: newScale)
        self.transform = transform
        let scale = self.transform.a
        let buttonScale = 1/scale
        zoomButton.transform = CGAffineTransform.identity.scaledBy(x: buttonScale, y: buttonScale)
    }
}
