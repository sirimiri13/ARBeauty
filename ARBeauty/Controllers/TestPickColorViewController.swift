//
//  TestPickColorViewController.swift
//  ARBeauty
//
//  Created by Huong Lam on 02/20/2021.
//

import UIKit

class TestPickColorViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var colorView: UIImageView!
    
    @IBOutlet weak var picker: UIView!
    
    var location = CGPoint(x: 0.0, y: 0.0)
    var deltaY = CGFloat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.addSubview(self.colorView)
        imageView.bringSubviewToFront(self.colorView)
        
        colorView.center = imageView.center
        let color: UIColor = (imageView.image?.getPixelColor(pos: CGPoint(x: imageView.center.x, y: imageView.center.y)))!
        colorView.image = UIImage(named: "color-picker")?.withTintColor(color)
        // colorView.image = colorView.image?.drawOutlie(color: UIColor.black)
        
    }
    
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            location = touch.location(in: imageView)
            deltaY = colorView.frame.height * 0.5
            let color: UIColor = (imageView.image?.getPixelColor(pos: CGPoint(x: location.x, y: location.y)))!
            colorView.center = CGPoint(x: location.x ,y: location.y - deltaY)
            colorView.image = UIImage(named: "color-picker")?.withTintColor(color)
            //  colorView.image = colorView.image?.drawOutlie(color: UIColor.black)        }
        }
    }
        
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            if let touch = touches.first{
                location = touch.location(in: imageView)
                let color: UIColor = (imageView.image?.getPixelColor(pos: CGPoint(x: location.x, y: location.y)))!
                deltaY = colorView.frame.height * 0.5
                colorView.center = CGPoint(x: location.x, y: location.y - deltaY)
                colorView.image = UIImage(named: "color-picker")?.withTintColor(color)
                //   colorView.image = colorView.image?.drawOutlie(color: UIColor.black)        }
            }
        }
    }
