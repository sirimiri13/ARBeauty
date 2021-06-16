//
//  ScanViewController.swift
//  ARBeauty
//
//  Created by Huong Lam on 05/26/2021.
//

import UIKit
import Foundation
import AVFoundation
import CoreGraphics
import PhotosUI

class DesignNailsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate, PickColorProtocol{
  
    
    @IBOutlet weak var handView: UIView!
    @IBOutlet weak var optionCollectionView: UICollectionView!
    @IBOutlet weak var handImageView: UIImageView!
    @IBOutlet weak var maskNailsView: UIView!
    @IBOutlet weak var thumbNailsImageView: UIImageView!
    @IBOutlet weak var littleNailsImageView: UIImageView!
    @IBOutlet weak var indexNailsImageView: UIImageView!
    @IBOutlet weak var middleNailsImageView: UIImageView!
    @IBOutlet weak var ringNailsImageView: UIImageView!
    
    @IBOutlet weak var scaleSlider: UISlider!
    @IBOutlet weak var rotateSlider: UISlider!
    @IBOutlet weak var showHideEditBoxImageView: UIImageView!
    
    @IBOutlet weak var fakeTabbarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var editBoxHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var shapeButton: UIButton!
    @IBOutlet weak var styleButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    
    var delegate : StartSessionProtocol!
    
    var isShowEditBox = false
    var isChooseColor: Bool = true
    var isChooseShape: Bool = false
    var isChooseStyle: Bool = false
    var isRightHand : Bool = false
    var colors: [UIColor] = []
    let defaultColors: [UIColor] = [UIColor.fromHex(value: "FF0000"),
                                    UIColor.fromHex(value: "006699"),
                                    UIColor.fromHex(value: "00FF00"),
                                    UIColor.fromHex(value: "FF6600"),
                                    UIColor.fromHex(value: "330033"),
                                    UIColor.fromHex(value: "99CCCC"),
                                    UIColor.fromHex(value: "FFCC33")]
    
    var selectedIndex: Int = 1
    var selectedColor = UIColor()
    
    
    let shapeImageName : [String] = ["Shape=short",
                                     "Shape=almond",
                                     "Shape=arrowhead",
                                     "Shape=ballerina",
                                     "Shape=lipstick",
                                     "Shape=oval",
                                     "Shape=rounded",
                                     "Shape=stiletto"]
    
    
    let styleImageName: [String] = ["style_0",
                                    "style_1",
                                    "style_2",
                                    "style_3",
                                    "style_4",
                                    "style_5",
                                    "style_6",
                                    "style_7",]
    
    var selectedShape: String!
    var selectedStyle: String!
    
    var photoCaptured: UIImage!
    
    var isRotated: Bool = false
    
    var littleNail = Nails(isSelect: false, isTap: false, degree: 355 * CGFloat.pi/180, rotateValue: 0.125, scale: CGAffineTransform(scaleX: 1, y: 1), scaleValue: 1)
    var ringNail = Nails(isSelect: false,isTap: false, degree: 0.0 , rotateValue: 0.125, scale: CGAffineTransform(scaleX: 1, y: 1), scaleValue: 1)
    var middleNail = Nails(isSelect: false, isTap: false, degree: 0.0, rotateValue: 0.125, scale: CGAffineTransform(scaleX: 1, y: 1), scaleValue: 1)
    var indexNail = Nails(isSelect: false,isTap: false, degree: 5 * CGFloat.pi/180, rotateValue: 0.125, scale: CGAffineTransform(scaleX: 1, y: 1), scaleValue: 1)
    var thumbNail = Nails(isSelect: false,isTap: false, degree:  180 * CGFloat.pi/180, rotateValue: 0.125, scale: CGAffineTransform(scaleX: 1, y: 1), scaleValue: 1)
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.makeToast("Tap any nails to edit", duration: 2.0, position: .center)
        if #available(iOS 11.0, *) {
            if let window = UIApplication.shared.windows.first {
                if window.safeAreaInsets.bottom > 0 {
                    fakeTabbarBottomConstraint.constant = -53;
                }
            }
        }
        
        if (isRightHand) {
            self.maskNailsView.transform = CGAffineTransform(scaleX: -1, y: 1);
        }
        handImageView.image = photoCaptured
        selectedShape = shapeImageName[0]
        selectedColor = defaultColors[0]
      
        
        self.optionCollectionView.register(UINib.init(nibName: "ColorCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ColorCollectionViewCell")
        self.optionCollectionView.register(UINib.init(nibName: "ShapeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ShapeCollectionViewCell")
        self.optionCollectionView.register(UINib.init(nibName: "StyleCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "StyleCollectionViewCell")
        optionCollectionView.delegate = self
        optionCollectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        optionCollectionView.backgroundColor = UIColor.clear
        optionCollectionView.collectionViewLayout = layout
        optionCollectionView.showsHorizontalScrollIndicator = false
        optionCollectionView.backgroundColor = .clear
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.minimumLineSpacing = 10
        
        setupColors()
        setColorNails(color: colors[0].withAlphaComponent(0.7))
        
        thumbNailsImageView.transform = CGAffineTransform(rotationAngle: 35 * CGFloat.pi/180);
        indexNailsImageView.transform = CGAffineTransform(rotationAngle: 5 * CGFloat.pi/180);
        littleNailsImageView.transform = CGAffineTransform(rotationAngle: 355 * CGFloat.pi/180);
        
        editBoxHeightConstraint.constant = 0
        showHideEditBoxImageView.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi)
        setGesture()
        
    }
  
    func setGesture() {
        let showHideColorsIconTap = UITapGestureRecognizer(target: self, action: #selector(showHideEditBoxTapped))
        showHideEditBoxImageView.addGestureRecognizer(showHideColorsIconTap)
        let littleTap = UITapGestureRecognizer(target: self, action: #selector(littleNailTapped))
        littleNailsImageView.isUserInteractionEnabled = true
        littleNailsImageView.addGestureRecognizer(littleTap)
        
        let littleDrag = UIPanGestureRecognizer(target: self, action: #selector(littleNaillDrag(_:)))
        littleNailsImageView.addGestureRecognizer(littleDrag)
        
        let ringTap = UITapGestureRecognizer(target: self, action: #selector(ringNailTapped))
        ringNailsImageView.isUserInteractionEnabled = true
        ringNailsImageView.addGestureRecognizer(ringTap)
        let ringDrag = UIPanGestureRecognizer(target: self, action: #selector(ringNailDrag(_:)))
        ringNailsImageView.addGestureRecognizer(ringDrag)
        
        
        let middleTap = UITapGestureRecognizer(target: self, action: #selector(middleNailTapped))
        middleNailsImageView.isUserInteractionEnabled = true
        middleNailsImageView.addGestureRecognizer(middleTap)
        let middleDrag = UIPanGestureRecognizer(target: self, action: #selector(middleNailDrag(_:)))
        middleNailsImageView.addGestureRecognizer(middleDrag)
        
        
        let indexTap = UITapGestureRecognizer(target: self, action: #selector(indexNailTapped))
        indexNailsImageView.isUserInteractionEnabled = true
        indexNailsImageView.addGestureRecognizer(indexTap)
        let indexDrag = UIPanGestureRecognizer(target: self, action: #selector(indexNailDrag(_:)))
        indexNailsImageView.addGestureRecognizer(indexDrag)
        
        let thumbTap = UITapGestureRecognizer(target: self, action: #selector(thumbNailTapped))
        thumbNailsImageView.isUserInteractionEnabled = true
        thumbNailsImageView.addGestureRecognizer(thumbTap)
        let thumbDrag = UIPanGestureRecognizer(target: self, action: #selector(thumbNailDrag(_:)))
        thumbNailsImageView.addGestureRecognizer(thumbDrag)
        
        
        let handImageTap = UITapGestureRecognizer(target: self, action: #selector(handImageViewTapped))
        handImageView.isUserInteractionEnabled = true
        handImageView.addGestureRecognizer(handImageTap)
    }

    func setOptionTitleColor(){
        if isChooseColor{
            styleButton.setTitleColor(UIColor.darkGray, for: .normal)
            colorButton.setTitleColor(UIColor.flamingoPink(), for: .normal)
            shapeButton.setTitleColor(UIColor.darkGray, for: .normal)
            saveButton.setTitleColor(UIColor.darkGray, for: .normal)
        }
        else {
            if isChooseShape{
                styleButton.setTitleColor(UIColor.darkGray, for: .normal)
                colorButton.setTitleColor(UIColor.darkGray, for: .normal)
                shapeButton.setTitleColor(UIColor.flamingoPink(), for: .normal)
                saveButton.setTitleColor(UIColor.darkGray, for: .normal)
            }
            else {
                if isChooseStyle {
                    styleButton.setTitleColor(UIColor.flamingoPink(), for: .normal)
                    colorButton.setTitleColor(UIColor.darkGray, for: .normal)
                    shapeButton.setTitleColor(UIColor.darkGray, for: .normal)
                    saveButton.setTitleColor(UIColor.darkGray, for: .normal)
                }
                else {
                    styleButton.setTitleColor(UIColor.darkGray, for: .normal)
                    colorButton.setTitleColor(UIColor.darkGray, for: .normal)
                    shapeButton.setTitleColor(UIColor.darkGray, for: .normal)
                    saveButton.setTitleColor(UIColor.flamingoPink(), for: .normal)
                }
            }
        }
    }
// MARK: - Handle nail drag events
    @objc func littleNailTapped() {
        if (!littleNail.isSelect){
            setSelectNails(isLittle: true, isRing: false, isMiddle: false, isIndex: false, isThumb: false)
            handleNailSelect(nailImageView: littleNailsImageView, borderWidth: 1.5, isShowBox: false)
            handleNailUnselect(nailImageView: ringNailsImageView)
            handleNailUnselect(nailImageView: middleNailsImageView)
            handleNailUnselect(nailImageView: indexNailsImageView)
            handleNailUnselect(nailImageView: thumbNailsImageView)
            handleSlider(enable: true)
            setSliderValue(scaleValue: littleNail.scaleValue, rotateValue: littleNail.rotateValue)
        }
        else {
            setSelectNails(isLittle: false, isRing: false, isMiddle: false, isIndex: false, isThumb: false)
            handleNailSelect(nailImageView: littleNailsImageView, borderWidth: 0, isShowBox: true)
            handleNailUnselect(nailImageView: ringNailsImageView)
            handleNailUnselect(nailImageView: middleNailsImageView)
            handleNailUnselect(nailImageView: indexNailsImageView)
            handleNailUnselect(nailImageView: thumbNailsImageView)
            handleSlider(enable: false)
        }
        showHideEditBoxTapped()
    }
  
    
    @objc func ringNailTapped() {
        if (!ringNail.isSelect){
            setSelectNails(isLittle: false, isRing: true, isMiddle: false, isIndex: false, isThumb: false)
            handleNailSelect(nailImageView: ringNailsImageView, borderWidth: 1.5, isShowBox: false)
            handleNailUnselect(nailImageView: littleNailsImageView)
            handleNailUnselect(nailImageView: middleNailsImageView)
            handleNailUnselect(nailImageView: indexNailsImageView)
            handleNailUnselect(nailImageView: thumbNailsImageView)
            handleSlider(enable: true)
            setSliderValue(scaleValue: ringNail.scaleValue, rotateValue: ringNail.rotateValue)

        }
        else {
            setSelectNails(isLittle: false, isRing: false, isMiddle: false, isIndex: false, isThumb: false)
            handleNailSelect(nailImageView: ringNailsImageView, borderWidth: 0, isShowBox: true)
            handleNailUnselect(nailImageView: littleNailsImageView)
            handleNailUnselect(nailImageView: middleNailsImageView)
            handleNailUnselect(nailImageView: indexNailsImageView)
            handleNailUnselect(nailImageView: thumbNailsImageView)
            handleSlider(enable: false)

        }
        showHideEditBoxTapped()

    }
  
    
    @objc func middleNailTapped() {
        if (!middleNail.isSelect){
            setSelectNails(isLittle: false, isRing: false, isMiddle: true, isIndex: false, isThumb: false)
            handleNailSelect(nailImageView: middleNailsImageView, borderWidth: 1.5, isShowBox: false)
            handleNailUnselect(nailImageView: littleNailsImageView)
            handleNailUnselect(nailImageView: ringNailsImageView)
            handleNailUnselect(nailImageView: indexNailsImageView)
            handleNailUnselect(nailImageView: thumbNailsImageView)
            handleSlider(enable: true)
            setSliderValue(scaleValue: middleNail.scaleValue, rotateValue: middleNail.rotateValue)


        }
        else {
            setSelectNails(isLittle: false, isRing: false, isMiddle: false, isIndex: false, isThumb: false)
            handleNailSelect(nailImageView: middleNailsImageView, borderWidth: 0, isShowBox: true)
            handleNailUnselect(nailImageView: littleNailsImageView)
            handleNailUnselect(nailImageView: ringNailsImageView)
            handleNailUnselect(nailImageView: indexNailsImageView)
            handleNailUnselect(nailImageView: thumbNailsImageView)
            handleSlider(enable: false)

        }
        showHideEditBoxTapped()

    }
    
    
    
    @objc func indexNailTapped() {
        if (!indexNail.isSelect){
            setSelectNails(isLittle: false, isRing: false, isMiddle: false, isIndex: true, isThumb: false)
            handleNailSelect(nailImageView: indexNailsImageView, borderWidth: 1.5, isShowBox: false)
            handleNailUnselect(nailImageView: littleNailsImageView)
            handleNailUnselect(nailImageView: ringNailsImageView)
            handleNailUnselect(nailImageView: middleNailsImageView)
            handleNailUnselect(nailImageView: thumbNailsImageView)
            handleSlider(enable: true)
            setSliderValue(scaleValue: indexNail.scaleValue, rotateValue: indexNail.rotateValue)
        }
        else {
            setSelectNails(isLittle: false, isRing: false, isMiddle: false, isIndex: false, isThumb: false)
            handleNailSelect(nailImageView: indexNailsImageView, borderWidth: 0, isShowBox: true)
            handleNailUnselect(nailImageView: littleNailsImageView)
            handleNailUnselect(nailImageView: ringNailsImageView)
            handleNailUnselect(nailImageView: middleNailsImageView)
            handleNailUnselect(nailImageView: thumbNailsImageView)
            handleSlider(enable: false)

        }
        showHideEditBoxTapped()

    }
    
    
    @objc func thumbNailTapped() {
        if (!thumbNail.isSelect){
            setSelectNails(isLittle: false, isRing: false, isMiddle: false, isIndex: false, isThumb: true)
            handleNailSelect(nailImageView: thumbNailsImageView, borderWidth: 1.5, isShowBox: false)
            handleNailUnselect(nailImageView: littleNailsImageView)
            handleNailUnselect(nailImageView: ringNailsImageView)
            handleNailUnselect(nailImageView: middleNailsImageView)
            handleNailUnselect(nailImageView: indexNailsImageView)
            handleSlider(enable: true)
            setSliderValue(scaleValue: thumbNail.scaleValue, rotateValue: thumbNail.rotateValue)
        }
        else {
            setSelectNails(isLittle: false, isRing: false, isMiddle: false, isIndex: false, isThumb: false)
            handleNailSelect(nailImageView: thumbNailsImageView, borderWidth: 0, isShowBox: true)
            handleNailUnselect(nailImageView: littleNailsImageView)
            handleNailUnselect(nailImageView: ringNailsImageView)
            handleNailUnselect(nailImageView: middleNailsImageView)
            handleNailUnselect(nailImageView: indexNailsImageView)
            handleSlider(enable: false)

        }
        showHideEditBoxTapped()

    }
    
    
    
    @objc func handImageViewTapped() {
        setSelectNails(isLittle: false, isRing: false, isMiddle: false, isIndex: false, isThumb: false)
    }
    
    func setSelectNails(isLittle: Bool,isRing: Bool,isMiddle: Bool, isIndex: Bool,isThumb: Bool){
        littleNail.isSelect = isLittle
        ringNail.isSelect = isRing
        middleNail.isSelect = isMiddle
        indexNail.isSelect = isIndex
        thumbNail.isSelect = isThumb
    }
    
    
    func handleNailSelect(nailImageView: UIImageView,borderWidth: CGFloat,isShowBox: Bool){
        nailImageView.layer.borderWidth = borderWidth
        nailImageView.layer.borderColor = UIColor.blueCustom().cgColor
        isShowEditBox = isShowBox
    }
    func handleNailUnselect(nailImageView: UIImageView){
        nailImageView.layer.borderWidth = 0
    }
    
    func setSliderValue(scaleValue: Float, rotateValue: Float){
        scaleSlider.value = scaleValue
        rotateSlider.value = rotateValue
    }
    
    @objc func littleNaillDrag(_ sender:UIPanGestureRecognizer) {
        handleNailSelect(nailImageView: littleNailsImageView, borderWidth: 1.5, isShowBox: false)
        handleNailUnselect(nailImageView: ringNailsImageView)
        handleNailUnselect(nailImageView: middleNailsImageView)
        handleNailUnselect(nailImageView: indexNailsImageView)
        handleNailUnselect(nailImageView: thumbNailsImageView)

        let translation = sender.translation(in: self.view)
        if (isRightHand) {
            littleNailsImageView.center = CGPoint(x: littleNailsImageView.center.x - translation.x, y: littleNailsImageView.center.y + translation.y)

        }
        else {
            littleNailsImageView.center = CGPoint(x: littleNailsImageView.center.x + translation.x, y: littleNailsImageView.center.y + translation.y)
        }
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    @objc func ringNailDrag(_ sender:UIPanGestureRecognizer) {
        handleNailSelect(nailImageView: ringNailsImageView, borderWidth: 1.5, isShowBox: false)
        handleNailUnselect(nailImageView: littleNailsImageView)
        handleNailUnselect(nailImageView: middleNailsImageView)
        handleNailUnselect(nailImageView: indexNailsImageView)
        handleNailUnselect(nailImageView: thumbNailsImageView)


        let translation = sender.translation(in: self.view)
        if (isRightHand) {
            ringNailsImageView.center = CGPoint(x: ringNailsImageView.center.x - translation.x, y: ringNailsImageView.center.y + translation.y)

        }
        else {
            ringNailsImageView.center = CGPoint(x: ringNailsImageView.center.x + translation.x, y: ringNailsImageView.center.y + translation.y)
        }
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    
    @objc func middleNailDrag(_ sender:UIPanGestureRecognizer) {
        handleNailSelect(nailImageView: middleNailsImageView, borderWidth: 1.5, isShowBox: false)
        handleNailUnselect(nailImageView: littleNailsImageView)
        handleNailUnselect(nailImageView: ringNailsImageView)
        handleNailUnselect(nailImageView: indexNailsImageView)
        handleNailUnselect(nailImageView: thumbNailsImageView)
        let translation = sender.translation(in: self.view)
        if (isRightHand) {
            middleNailsImageView.center = CGPoint(x: middleNailsImageView.center.x - translation.x, y: middleNailsImageView.center.y + translation.y)

        }
        else {
            middleNailsImageView.center = CGPoint(x: middleNailsImageView.center.x + translation.x, y: middleNailsImageView.center.y + translation.y)
        }
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    @objc func indexNailDrag(_ sender:UIPanGestureRecognizer) {
        handleNailSelect(nailImageView: indexNailsImageView, borderWidth: 1.5, isShowBox: false)
        handleNailUnselect(nailImageView: littleNailsImageView)
        handleNailUnselect(nailImageView: ringNailsImageView)
        handleNailUnselect(nailImageView: middleNailsImageView)
        handleNailUnselect(nailImageView: thumbNailsImageView)
                
        let translation = sender.translation(in: self.view)
        if (isRightHand) {
            indexNailsImageView.center = CGPoint(x: indexNailsImageView.center.x - translation.x, y: indexNailsImageView.center.y + translation.y)

        }
        else {
            indexNailsImageView.center = CGPoint(x: indexNailsImageView.center.x + translation.x, y: indexNailsImageView.center.y + translation.y)
        }
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    @objc func thumbNailDrag(_ sender:UIPanGestureRecognizer) {
        handleNailSelect(nailImageView: thumbNailsImageView, borderWidth: 1.5, isShowBox: false)
        handleNailUnselect(nailImageView: littleNailsImageView)
        handleNailUnselect(nailImageView: ringNailsImageView)
        handleNailUnselect(nailImageView: middleNailsImageView)
        handleNailUnselect(nailImageView: indexNailsImageView)

        let translation = sender.translation(in: self.view)
        if (isRightHand) {
            thumbNailsImageView.center = CGPoint(x: thumbNailsImageView.center.x - translation.x, y: thumbNailsImageView.center.y + translation.y)

        }
        else {
            thumbNailsImageView.center = CGPoint(x: thumbNailsImageView.center.x + translation.x, y: thumbNailsImageView.center.y + translation.y)
        }
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    func handleSlider(enable: Bool){
        if (enable){
            scaleSlider.isUserInteractionEnabled = true
            rotateSlider.isUserInteractionEnabled = true
            scaleSlider.minimumTrackTintColor = UIColor.green
            rotateSlider.minimumTrackTintColor = UIColor.green

        }
        else {
            scaleSlider.isUserInteractionEnabled = false
            rotateSlider.isUserInteractionEnabled = false
            scaleSlider.minimumTrackTintColor = UIColor.gray
            rotateSlider.minimumTrackTintColor = UIColor.gray
        }
    }
   
// MARK: - Slider value change
    @IBAction func scaleSliderChangeValue(_ sender: Any) {
        let scaleTransform = CGAffineTransform(scaleX: CGFloat(scaleSlider.value), y: CGFloat(scaleSlider.value))
        if (littleNail.isSelect) {
            littleNail.scaleValue = scaleSlider.value
            littleNail.scale = scaleTransform
            littleNailsImageView.transform = CGAffineTransform(rotationAngle: littleNail.degree).concatenating(scaleTransform)
        }
        else{
            if (ringNail.isSelect) {
                ringNail.scaleValue = scaleSlider.value
                ringNail.scale = scaleTransform
                ringNailsImageView.transform = CGAffineTransform(rotationAngle: ringNail.degree).concatenating(scaleTransform)
            }
            else {
                if (middleNail.isSelect) {
                    middleNail.scaleValue = scaleSlider.value
                    middleNail.scale = scaleTransform
                    middleNailsImageView.transform = CGAffineTransform(rotationAngle: middleNail.degree).concatenating(scaleTransform)
                }
                else {
                    if (indexNail.isSelect) {
                        indexNail.scaleValue = scaleSlider.value
                        indexNail.scale = scaleTransform
                        indexNailsImageView.transform = CGAffineTransform(rotationAngle: indexNail.degree).concatenating(scaleTransform)
                    }
                    else {
                        if (thumbNail.isSelect){
                            thumbNail.scaleValue = scaleSlider.value
                            thumbNail.scale = scaleTransform
                            thumbNailsImageView.transform = CGAffineTransform(rotationAngle: thumbNail.degree).concatenating(scaleTransform)
                        }
                        
                    }
                }
            }
        }
    }
    
    @IBAction func rotateSliderChangeValue(_ sender: Any) {
        let angle = CGFloat(rotateSlider.value * 2 * Float(CGFloat.pi) / rotateSlider.maximumValue)
        if (littleNail.isSelect) {
            littleNail.degree = angle
            littleNail.rotateValue = rotateSlider.value
            littleNailsImageView.transform = CGAffineTransform(rotationAngle: littleNail.degree).concatenating(littleNail.scale)
        }
        else {
            if (ringNail.isSelect) {
                ringNail.degree = angle
                ringNail.rotateValue = rotateSlider.value
                ringNailsImageView.transform =  CGAffineTransform(rotationAngle: ringNail.degree).concatenating(ringNail.scale)
            }
            else {
                if (middleNail.isSelect) {
                    middleNail.degree = angle
                    middleNail.rotateValue = rotateSlider.value
                    middleNailsImageView.transform = CGAffineTransform(rotationAngle: middleNail.degree).concatenating(middleNail.scale)
                }
                else {
                    if (indexNail.isSelect) {
                        indexNail.degree = angle
                        indexNail.rotateValue = rotateSlider.value
                        indexNailsImageView.transform =  CGAffineTransform(rotationAngle: indexNail.degree).concatenating(indexNail.scale)
                    }
                    else {
                        if (thumbNail.isSelect){
                            thumbNail.degree = angle
                            thumbNail.rotateValue = rotateSlider.value
                            thumbNailsImageView.transform =  CGAffineTransform(rotationAngle: thumbNail.degree).concatenating(thumbNail.scale)
                        }
                    }
                }
            }
        }
        
    }
    
    @objc func showHideEditBoxTapped() {
        editBoxHeightConstraint.constant = isShowEditBox ? 0 : 144
        UIView.animate(withDuration: 0.2) {
            self.showHideEditBoxImageView.transform = self.isShowEditBox ? CGAffineTransform.init(rotationAngle: CGFloat.pi) : CGAffineTransform.init(rotationAngle: 0.000001)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.isShowEditBox = !self.isShowEditBox
        }

    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.delegate.startSession()
        self.dismiss(animated: true, completion: nil)
      
    }
    
    @IBAction func shareTapped(_ sender: Any) {
        let image = UIImage(view: handView)
        let imageShare = [image]
        let activityViewController = UIActivityViewController(activityItems: imageShare as [Any] , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
        
    }


    @IBAction func editTapped(_ sender: UIButton){
        if (!isShowEditBox) {
            showHideEditBoxTapped()
        }
        if sender.tag == 0 {
            selectedIndex = 1
            setImageNails(image: UIImage(named: "Shape=short")!)
            setColorNails(color: colors[0].withAlphaComponent(0.7))
            setOptionEdit(isColor: true, isShape: false, isStyle: false)
        }
        else {
            if sender.tag == 1{
                selectedIndex = 0
                setOptionEdit(isColor: false, isShape: true, isStyle: false)

            }
            else {
                if sender.tag == 2{
                    selectedIndex = 0
                    setOptionEdit(isColor: false, isShape: false, isStyle: true)
                }
                else {
                    
                    littleNailsImageView.layer.borderWidth = 0
                    ringNailsImageView.layer.borderWidth = 0
                    middleNailsImageView.layer.borderWidth = 0
                    indexNailsImageView.layer.borderWidth = 0
                    thumbNailsImageView.layer.borderWidth = 0
                    let image = UIImage(view: handView)
                    CustomPhotoAlbum.sharedInstance.saveImage(image: image)
                }
            }
        }
        optionCollectionView.reloadData()

    }
    
    
    func setOptionEdit(isColor: Bool, isShape:Bool, isStyle: Bool){
        isChooseColor = isColor
        isChooseShape = isShape
        isChooseStyle = isStyle
        setOptionTitleColor()
    }
    func setupColors() {
        colors.removeAll()
        let userColors:[String] = Utils.getUserColors()
        for color in userColors {
            colors.append(UIColor.fromHex(value: color))
        }
        colors += defaultColors
        selectedColor = UIColor.fromHex(value: colors[0].toHex(), alpha: 0.7)
        setColorNails(color: selectedColor)
        optionCollectionView.reloadData()
    }
    
// MARK: - collectionview protocoles
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if colorButton.isSelected{
            return  colors.count + 1
        }
        else {
            if shapeButton.isSelected{
                return shapeImageName.count
            }
            else {
                return styleImageName.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isChooseColor {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCollectionViewCell", for: indexPath) as! ColorCollectionViewCell
            if (indexPath.row == 0) {
                cell.setCell(color: UIColor.clear, isSelected: false, showAddButton: true)
            }
            else {
                if (selectedIndex == indexPath.row) {
                    cell.setCell(color: colors[indexPath.row - 1], isSelected: true, showAddButton: false)
                }
                else {
                    cell.setCell(color: colors[indexPath.row - 1], isSelected: false, showAddButton: false)
                }
            }
            return cell
        }
        else{
            if isChooseShape{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShapeCollectionViewCell", for: indexPath) as! ShapeCollectionViewCell
                cell.shapeImageView.image = UIImage(named: shapeImageName[indexPath.row])
                if (selectedIndex == indexPath.row) {
                    cell.setCell(isSelected: true)
                }
                else {
                    cell.setCell(isSelected: false)
                }
                return cell
            }
            else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StyleCollectionViewCell", for: indexPath) as! StyleCollectionViewCell
                cell.styleImageView.image = UIImage(named: styleImageName[indexPath.row])
    
                    if (selectedIndex == indexPath.row) {
                        cell.setCell(isSelected: true)
                    }
                    else {
                        cell.setCell(isSelected: false)
                    }
                return cell
            }
            
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isChooseColor{
            if (indexPath.row == 0) {
                self.addColorTapped()
            }
            else {
                selectedIndex = indexPath.row
                selectedColor = UIColor.fromHex(value: colors[indexPath.row - 1].toHex(), alpha: 0.7)
                setColorNails(color: selectedColor)
                optionCollectionView.reloadData()
            }
        }
        else {
            if isChooseShape{
                setImageNails(image: UIImage(named: shapeImageName[indexPath.row])!)
                selectedIndex = indexPath.row
                selectedShape = shapeImageName[indexPath.row]
                optionCollectionView.reloadData()
            }
            else {
                setImageNails(image: UIImage(named: styleImageName[indexPath.row])!)
                selectedIndex = indexPath.row
                optionCollectionView.reloadData()
            }
        }
    }
    
    func setImageNails(image: UIImage) {
        middleNailsImageView.image =  image
        thumbNailsImageView.image = image
        littleNailsImageView.image = image
        indexNailsImageView.image = image
        ringNailsImageView.image = image
    }
    
    func setColorNails(color: UIColor) {
        middleNailsImageView.tintColor =  color
        thumbNailsImageView.tintColor = color
        littleNailsImageView.tintColor = color
        indexNailsImageView.tintColor = color
        ringNailsImageView.tintColor = color
    }
    
    func addColorTapped() {
        let alertSheet = UIAlertController(title: "Select a color from an image", message: "", preferredStyle: .actionSheet)
        let takePhotoAction = UIAlertAction(title: "Take a photo", style: .default) { (UIAlertAction) in
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .camera;
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
        let choosePhotoFromLibraryAction = UIAlertAction(title: "From Library", style: .default) { (UIAlertAction) in
            var configuration = PHPickerConfiguration()
            configuration.filter = .images
            
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            
            self.present(picker, animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertSheet.addAction(takePhotoAction)
        alertSheet.addAction(choosePhotoFromLibraryAction)
        alertSheet.addAction(cancelAction)
        self.present(alertSheet, animated: true, completion: nil)
    }
    
    
    func didPickColor() {
        selectedIndex = 1
        setupColors()
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let pickedImage = info[.originalImage] as? UIImage
        let pickColorVC = PickerColorViewController()
        pickColorVC.modalPresentationStyle = .fullScreen
        pickColorVC.pickedImage = pickedImage
        pickColorVC.delegate = self
        self.dismiss(animated: true)
        present(pickColorVC, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        let itemProvider = results.first?.itemProvider
        
        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    guard let self = self, let image = image as? UIImage else { return }
                    let pickColorVC = PickerColorViewController()
                    pickColorVC.modalPresentationStyle = .fullScreen
                    pickColorVC.pickedImage = image
                    pickColorVC.delegate = self
                    self.present(pickColorVC, animated: true, completion: nil)
                }
            }
        }
    }
    
}

