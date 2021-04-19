//
//  TestPickColorViewController.swift
//  ARBeauty
//
//  Created by Huong Lam on 02/20/2021.
//

import UIKit

protocol PickColorProtocol {
    func finishPickColor()
}

class PickColorViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
   
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var navigationBar: NavigationBarFakeView!
    @IBOutlet weak var useButton: UIButton!
    
    var delegate: PickColorProtocol?
   
    
    let pickerView = PickerView(frame: CGRect(x: 0, y: 0, width: 50, height: 80))
    var imagePicked = UIImage()
    var location = CGPoint(x: 0.0, y: 0.0)
    var currentColor : String = ""
   
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.titleLabel.text = "CHOOSE COLOR"
        navigationBar.leftButton.setImage(UIImage(systemName: "arrow.left")?.withTintColor(UIColor.darkGray), for: .normal)
        navigationBar.leftButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
       
        imageView.image = imagePicked
        pickerView.center = view.center
        view.addSubview(pickerView)
        let color: UIColor = imageView.getPixelColor(atPosition:CGPoint(x: imageView.center.x, y: imageView.center.y + 40))
        currentColor = color.toRGBAString()
        
        pickerView.setColor(color: color)

        useButton.addBlurEffect()
        useButton.setTitle("USE", for: .normal)
        useButton.setTitleColor(UIColor.darkGray, for: .normal)
        
    }


    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            location = touch.location(in: imageView)
            let color : UIColor = imageView.getPixelColor(atPosition: CGPoint(x: location.x, y: location.y))
            pickerView.center = CGPoint(x: location.x  , y: location.y  + 40)
            pickerView.setColor(color: color)
            currentColor = color.toRGBAString()
        }
    }


        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            if let touch = touches.first{
                location = touch.location(in: imageView)
                let color : UIColor = imageView.getPixelColor(atPosition: CGPoint(x: location.x, y: location.y))
                pickerView.center = CGPoint(x: location.x , y: location.y  + 40)
                pickerView.setColor(color: color)
                currentColor = color.toRGBAString()
                
            }
        }
    
    @objc func backButtonTapped(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func useButtonTapped(_ sender: Any) {
        var colorPicked = UserDefaults.standard.getColorPicked()
        colorPicked.append(currentColor)
        print(colorPicked.count)
        UserDefaults.standard.deleteColorPicked()
        UserDefaults.standard.setColorPicked(value: colorPicked)
        self.delegate?.finishPickColor()
        self.dismiss(animated: true, completion: nil)
    }
    
}

