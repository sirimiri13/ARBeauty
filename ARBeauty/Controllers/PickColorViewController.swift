//
//  TestPickColorViewController.swift
//  ARBeauty
//
//  Created by Huong Lam on 02/20/2021.
//

import UIKit

protocol PickColorProtocol {
    func didPickColor()
}

class PickColorViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var useButton: UIButton!
    
    var delegate: PickColorProtocol?
    
    let pickerView = PickerView(frame: CGRect(x: 0, y: 0, width: 50, height: 90))
    var touchPoint: CGPoint = CGPoint(x: 0, y: 0)
    var selectedColor: String = ""
    var pickedImage: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        touchPoint = imageView.center
        pickerView.center.x = touchPoint.x
        pickerView.center.y = touchPoint.y - 20
        view.addSubview(pickerView)
        
        let color: UIColor = imageView.getPixelColor(atPosition:touchPoint)
        selectedColor = color.toRGBAString()
        pickerView.setColor(color: color)
        
        useButton.addBlurEffect()
        useButton.setTitle("USE", for: .normal)
        useButton.setTitleColor(UIColor.darkGray, for: .normal)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            touchPoint = touch.location(in: imageView)
            let color : UIColor = imageView.getPixelColor(atPosition: CGPoint(x: touchPoint.x, y: touchPoint.y))
            pickerView.center.x = touchPoint.x
            pickerView.center.y = touchPoint.y - 20
            pickerView.setColor(color: color)
            selectedColor = color.toRGBAString()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            touchPoint = touch.location(in: imageView)
            let color : UIColor = imageView.getPixelColor(atPosition: CGPoint(x: touchPoint.x, y: touchPoint.y))
            pickerView.center.x = touchPoint.x
            pickerView.center.y = touchPoint.y - 20
            pickerView.setColor(color: color)
            selectedColor = color.toRGBAString()
        }
    }
    

    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func useButtonTapped(_ sender: Any) {
        var colorPicked = Utils.getUserColors()
        let color = selectedColor.prefix(6)
        print("color \(color)")
        colorPicked.insert(String(color), at: 0)
        if (colorPicked.count > 5) {
            colorPicked.removeLast()
        }
        Utils.setUserColors(value: colorPicked)
        self.delegate?.didPickColor()
        self.dismiss(animated: true, completion: nil)
    }
    
}

