//
//  PickerColorViewController.swift
//  ARBeauty
//
//  Created by Nhan on 4/21/21.
//

import UIKit


protocol PickColorProtocol {
    func didPickColor()
}

class PickerColorViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var useButton: UIButton!
    
    var delegate: PickColorProtocol?
    
    var touchPoint = CGPoint(x: 0.0, y: 0.0)
    var selectedColor: String = ""
    var pickedImage: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set image from image picker
        imageView.image = pickedImage
        
        setupUI()
    }
    
    func setupUI() {
        view.layoutIfNeeded()
        
        pickerView.backgroundColor = UIColor.clear
        topView.layer.cornerRadius = topView.frame.size.height/2
        topView.layer.borderColor = UIColor.white.cgColor
        topView.layer.borderWidth = 1
        
        bottomView.layer.cornerRadius = bottomView.frame.size.height/2
        bottomView.layer.borderColor = UIColor.white.cgColor
        bottomView.layer.borderWidth = 1
        
        touchPoint =  CGPoint(x: imageView.frame.size.width/2, y: imageView.frame.size.height/2)
        
        let transform = CGAffineTransform(translationX: touchPoint.x - 25, y: touchPoint.y - 75 - 56)
        pickerView.transform = transform

        let color = imageView.getPixelColor(atPosition: imageView.center)
        setPickerViewColor(color: color)
        selectedColor = color.toHex()
        
        useButton.addBlurEffect()
        useButton.setTitle("USE", for: .normal)
        useButton.setTitleColor(UIColor.darkGray, for: .normal)
    }
    
    func setPickerViewColor(color: UIColor) {
        topView.backgroundColor = color
        bottomView.backgroundColor = color
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            touchPoint = touch.location(in: imageView)
            var color = UIColor()
            if (touchPoint.y >= 0 && touchPoint.y < imageView.frame.size.height - 1) {
                let transform = CGAffineTransform(translationX: touchPoint.x - 25, y: touchPoint.y - 75)
                pickerView.transform = transform
                color = imageView.getPixelColor(atPosition: touchPoint)
            }
            else if (touchPoint.y < 0) {
                let transform = CGAffineTransform(translationX: touchPoint.x - 25, y: -75)
                pickerView.transform = transform
                color = imageView.getPixelColor(atPosition: CGPoint(x: touchPoint.x, y: 0))
            }
            else {
                let transform = CGAffineTransform(translationX: touchPoint.x - 25, y: imageView.frame.size.height - 75)
                pickerView.transform = transform
                color = imageView.getPixelColor(atPosition: CGPoint(x: touchPoint.x, y: imageView.frame.size.height - 1))
            }
            
            setPickerViewColor(color: color)
            selectedColor = color.toHex()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            touchPoint = touch.location(in: imageView)
            if (touchPoint.y >= 0 && touchPoint.y < imageView.frame.size.height - 1) {
                let transform = CGAffineTransform(translationX: touchPoint.x - 25, y: touchPoint.y - 75)
                pickerView.transform = transform
                let color : UIColor = imageView.getPixelColor(atPosition: touchPoint)
                setPickerViewColor(color: color)
                selectedColor = color.toHex()
            }
        }
    }
    

    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func useButtonTapped(_ sender: Any) {
        Utils.addUserColors(value: String(selectedColor.prefix(6)))
        self.delegate?.didPickColor()
        self.dismiss(animated: true, completion: nil)
    }
    
}

