//
//  TestPickColorViewController.swift
//  ARBeauty
//
//  Created by Huong Lam on 02/20/2021.
//

import UIKit

class PickColorViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var colorView: UIImageView!
    
    let pickerView = PickerView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
    let deltaY = CGFloat()
    
    
    var location = CGPoint(x: 0.0, y: 0.0)
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let color: UIColor = imageView.getPixelColor(atPosition:CGPoint(x: imageView.center.x, y: imageView.center.y))
        pickerView.contentView?.backgroundColor = color
        pickerView.center = view.center
        view.addSubview(pickerView)

    }



    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            location = touch.location(in: imageView)
            print(location)
           
            let color : UIColor = imageView.getPixelColor(atPosition: CGPoint(x: location.x, y: location.y))
           
            pickerView.center = CGPoint(x: location.x  , y: location.y)
            print(pickerView.center)
            pickerView.contentView?.backgroundColor = color
        }
    }


        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            if let touch = touches.first{
                location = touch.location(in: imageView)
                let color : UIColor = imageView.getPixelColor(atPosition: CGPoint(x: location.x, y: location.y))
                pickerView.center = CGPoint(x: location.x , y: location.y )
                pickerView.contentView?.backgroundColor = color

            }
        }
    
   
}
