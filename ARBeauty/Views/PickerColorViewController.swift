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
        view.setNeedsLayout()
        
        pickerView.backgroundColor = UIColor.clear
        topView.layer.cornerRadius = topView.frame.height/2
        topView.layer.borderColor = UIColor.white.cgColor
        topView.layer.borderWidth = 1
        
        bottomView.layer.cornerRadius = bottomView.frame.height/2
        bottomView.layer.borderColor = UIColor.white.cgColor
        bottomView.layer.borderWidth = 1
        
        touchPoint = CGPoint(x: imageView.frame.size.width/2, y: imageView.frame.size.height/2)
        
        let transform = CGAffineTransform(translationX: touchPoint.x - 25, y: touchPoint.y - 75)
        pickerView.transform = transform
        
        let color: UIColor = imageView.getPixelColor(atPosition:touchPoint)
        setPickerViewColor(color: color)
        selectedColor = color.toRGBAString()
        
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
            let transform = CGAffineTransform(translationX: touchPoint.x - 25, y: touchPoint.y - 75)
            pickerView.transform = transform
            
            let color : UIColor = imageView.getPixelColor(atPosition: touchPoint)
            setPickerViewColor(color: color)
            selectedColor = color.toRGBAString()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            touchPoint = touch.location(in: imageView)
            
            let transform = CGAffineTransform(translationX: touchPoint.x - 25, y: touchPoint.y - 75)
            pickerView.transform = transform
            
            let color : UIColor = imageView.getPixelColor(atPosition: touchPoint)
            setPickerViewColor(color: color)
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

