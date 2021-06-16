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

class DesignNailsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate, PickColorProtocol {
    
    @IBOutlet weak var handImageView: UIImageView!
    @IBOutlet weak var handContainerView: UIView!
    @IBOutlet weak var handView: UIView!
    @IBOutlet weak var maskNailsView: UIView!
    @IBOutlet weak var thumbNailImageView: UIImageView!
    @IBOutlet weak var littleNailImageView: UIImageView!
    @IBOutlet weak var indexNailImageView: UIImageView!
    @IBOutlet weak var middleNailImageView: UIImageView!
    @IBOutlet weak var ringNailImageView: UIImageView!
    
    @IBOutlet weak var sizeSlider: UISlider!
    @IBOutlet weak var rotateSlider: UISlider!
    @IBOutlet weak var showHideEditBoxImageView: UIImageView!
    @IBOutlet weak var optionCollectionView: UICollectionView!
    
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
    
    var littleNail = DesignNail(isSelect: false, isTap: false, degree: 355 * CGFloat.pi/180, rotateValue: 0.125, scale: CGAffineTransform(scaleX: 1, y: 1), scaleValue: 1)
    var ringNail = DesignNail(isSelect: false,isTap: false, degree: 0.0 , rotateValue: 0.125, scale: CGAffineTransform(scaleX: 1, y: 1), scaleValue: 1)
    var middleNail = DesignNail(isSelect: false, isTap: false, degree: 0.0, rotateValue: 0.125, scale: CGAffineTransform(scaleX: 1, y: 1), scaleValue: 1)
    var indexNail = DesignNail(isSelect: false,isTap: false, degree: 5 * CGFloat.pi/180, rotateValue: 0.125, scale: CGAffineTransform(scaleX: 1, y: 1), scaleValue: 1)
    var thumbNail = DesignNail(isSelect: false,isTap: false, degree:  180 * CGFloat.pi/180, rotateValue: 0.125, scale: CGAffineTransform(scaleX: 1, y: 1), scaleValue: 1)
    
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
        
        thumbNailImageView.transform = CGAffineTransform(rotationAngle: 35 * CGFloat.pi/180);
        indexNailImageView.transform = CGAffineTransform(rotationAngle: 5 * CGFloat.pi/180);
        littleNailImageView.transform = CGAffineTransform(rotationAngle: 355 * CGFloat.pi/180);
        
        editBoxHeightConstraint.constant = 0
        showHideEditBoxImageView.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi)
        setGesture()
        
        handleSlider(enable: false)
    }
    
    func setGesture() {
        let showHideColorsIconTap = UITapGestureRecognizer(target: self, action: #selector(showHideEditBoxTapped))
        showHideEditBoxImageView.addGestureRecognizer(showHideColorsIconTap)
        let littleTap = UITapGestureRecognizer(target: self, action: #selector(littleNailTapped))
        littleNailImageView.isUserInteractionEnabled = true
        littleNailImageView.addGestureRecognizer(littleTap)
        
        let littleDrag = UIPanGestureRecognizer(target: self, action: #selector(littleNaillDrag(_:)))
        littleNailImageView.addGestureRecognizer(littleDrag)
        
        let ringTap = UITapGestureRecognizer(target: self, action: #selector(ringNailTapped))
        ringNailImageView.isUserInteractionEnabled = true
        ringNailImageView.addGestureRecognizer(ringTap)
        let ringDrag = UIPanGestureRecognizer(target: self, action: #selector(ringNailDrag(_:)))
        ringNailImageView.addGestureRecognizer(ringDrag)
        
        
        let middleTap = UITapGestureRecognizer(target: self, action: #selector(middleNailTapped))
        middleNailImageView.isUserInteractionEnabled = true
        middleNailImageView.addGestureRecognizer(middleTap)
        let middleDrag = UIPanGestureRecognizer(target: self, action: #selector(middleNailDrag(_:)))
        middleNailImageView.addGestureRecognizer(middleDrag)
        
        
        let indexTap = UITapGestureRecognizer(target: self, action: #selector(indexNailTapped))
        indexNailImageView.isUserInteractionEnabled = true
        indexNailImageView.addGestureRecognizer(indexTap)
        let indexDrag = UIPanGestureRecognizer(target: self, action: #selector(indexNailDrag(_:)))
        indexNailImageView.addGestureRecognizer(indexDrag)
        
        let thumbTap = UITapGestureRecognizer(target: self, action: #selector(thumbNailTapped))
        thumbNailImageView.isUserInteractionEnabled = true
        thumbNailImageView.addGestureRecognizer(thumbTap)
        let thumbDrag = UIPanGestureRecognizer(target: self, action: #selector(thumbNailDrag(_:)))
        thumbNailImageView.addGestureRecognizer(thumbDrag)
        
        let handContainerTap = UITapGestureRecognizer(target: self, action: #selector(handContainerTapped))
        handContainerView.isUserInteractionEnabled = true
        handContainerView.addGestureRecognizer(handContainerTap)
    }
    
    func setOptionTitleColor() {
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
        if (!littleNail.isSelect) {
            setSelectNails(isLittle: true, isRing: false, isMiddle: false, isIndex: false, isThumb: false)
            handleNailSelect(nailImageView: littleNailImageView, borderWidth: 1, isShowBox: false)
            handleNailUnselect(nailImageView: ringNailImageView)
            handleNailUnselect(nailImageView: middleNailImageView)
            handleNailUnselect(nailImageView: indexNailImageView)
            handleNailUnselect(nailImageView: thumbNailImageView)
            handleSlider(enable: true)
            setSliderValue(scaleValue: littleNail.scaleValue, rotateValue: littleNail.rotateValue)
        }
        else {
            setSelectNails(isLittle: false, isRing: false, isMiddle: false, isIndex: false, isThumb: false)
            handleNailSelect(nailImageView: littleNailImageView, borderWidth: 0, isShowBox: true)
            handleNailUnselect(nailImageView: ringNailImageView)
            handleNailUnselect(nailImageView: middleNailImageView)
            handleNailUnselect(nailImageView: indexNailImageView)
            handleNailUnselect(nailImageView: thumbNailImageView)
            handleSlider(enable: false)
        }
        showHideEditBoxTapped()
    }
    
    @objc func ringNailTapped() {
        if (!ringNail.isSelect) {
            setSelectNails(isLittle: false, isRing: true, isMiddle: false, isIndex: false, isThumb: false)
            handleNailSelect(nailImageView: ringNailImageView, borderWidth: 1, isShowBox: false)
            handleNailUnselect(nailImageView: littleNailImageView)
            handleNailUnselect(nailImageView: middleNailImageView)
            handleNailUnselect(nailImageView: indexNailImageView)
            handleNailUnselect(nailImageView: thumbNailImageView)
            handleSlider(enable: true)
            setSliderValue(scaleValue: ringNail.scaleValue, rotateValue: ringNail.rotateValue)
        }
        else {
            setSelectNails(isLittle: false, isRing: false, isMiddle: false, isIndex: false, isThumb: false)
            handleNailSelect(nailImageView: ringNailImageView, borderWidth: 0, isShowBox: true)
            handleNailUnselect(nailImageView: littleNailImageView)
            handleNailUnselect(nailImageView: middleNailImageView)
            handleNailUnselect(nailImageView: indexNailImageView)
            handleNailUnselect(nailImageView: thumbNailImageView)
            handleSlider(enable: false)
            
        }
        showHideEditBoxTapped()
    }
    
    @objc func middleNailTapped() {
        if (!middleNail.isSelect) {
            setSelectNails(isLittle: false, isRing: false, isMiddle: true, isIndex: false, isThumb: false)
            handleNailSelect(nailImageView: middleNailImageView, borderWidth: 1, isShowBox: false)
            handleNailUnselect(nailImageView: littleNailImageView)
            handleNailUnselect(nailImageView: ringNailImageView)
            handleNailUnselect(nailImageView: indexNailImageView)
            handleNailUnselect(nailImageView: thumbNailImageView)
            handleSlider(enable: true)
            setSliderValue(scaleValue: middleNail.scaleValue, rotateValue: middleNail.rotateValue)
        }
        else {
            setSelectNails(isLittle: false, isRing: false, isMiddle: false, isIndex: false, isThumb: false)
            handleNailSelect(nailImageView: middleNailImageView, borderWidth: 0, isShowBox: true)
            handleNailUnselect(nailImageView: littleNailImageView)
            handleNailUnselect(nailImageView: ringNailImageView)
            handleNailUnselect(nailImageView: indexNailImageView)
            handleNailUnselect(nailImageView: thumbNailImageView)
            handleSlider(enable: false)
            
        }
        showHideEditBoxTapped()
    }
    
    @objc func indexNailTapped() {
        if (!indexNail.isSelect) {
            setSelectNails(isLittle: false, isRing: false, isMiddle: false, isIndex: true, isThumb: false)
            handleNailSelect(nailImageView: indexNailImageView, borderWidth: 1, isShowBox: false)
            handleNailUnselect(nailImageView: littleNailImageView)
            handleNailUnselect(nailImageView: ringNailImageView)
            handleNailUnselect(nailImageView: middleNailImageView)
            handleNailUnselect(nailImageView: thumbNailImageView)
            handleSlider(enable: true)
            setSliderValue(scaleValue: indexNail.scaleValue, rotateValue: indexNail.rotateValue)
        }
        else {
            setSelectNails(isLittle: false, isRing: false, isMiddle: false, isIndex: false, isThumb: false)
            handleNailSelect(nailImageView: indexNailImageView, borderWidth: 0, isShowBox: true)
            handleNailUnselect(nailImageView: littleNailImageView)
            handleNailUnselect(nailImageView: ringNailImageView)
            handleNailUnselect(nailImageView: middleNailImageView)
            handleNailUnselect(nailImageView: thumbNailImageView)
            handleSlider(enable: false)
            
        }
        showHideEditBoxTapped()
    }
    
    @objc func thumbNailTapped() {
        if (!thumbNail.isSelect) {
            setSelectNails(isLittle: false, isRing: false, isMiddle: false, isIndex: false, isThumb: true)
            handleNailSelect(nailImageView: thumbNailImageView, borderWidth: 1, isShowBox: false)
            handleNailUnselect(nailImageView: littleNailImageView)
            handleNailUnselect(nailImageView: ringNailImageView)
            handleNailUnselect(nailImageView: middleNailImageView)
            handleNailUnselect(nailImageView: indexNailImageView)
            handleSlider(enable: true)
            setSliderValue(scaleValue: thumbNail.scaleValue, rotateValue: thumbNail.rotateValue)
        }
        else {
            setSelectNails(isLittle: false, isRing: false, isMiddle: false, isIndex: false, isThumb: false)
            handleNailSelect(nailImageView: thumbNailImageView, borderWidth: 0, isShowBox: true)
            handleNailUnselect(nailImageView: littleNailImageView)
            handleNailUnselect(nailImageView: ringNailImageView)
            handleNailUnselect(nailImageView: middleNailImageView)
            handleNailUnselect(nailImageView: indexNailImageView)
            handleSlider(enable: false)
            
        }
        showHideEditBoxTapped()
    }
    
    @objc func handContainerTapped() {
        setSelectNails(isLittle: false, isRing: false, isMiddle: false, isIndex: false, isThumb: false)
        if isShowEditBox {
            showHideEditBoxTapped()
        }
    }
    
    func setSelectNails(isLittle: Bool, isRing: Bool, isMiddle: Bool, isIndex: Bool, isThumb: Bool) {
        littleNail.isSelect = isLittle
        handleNailUnselect(nailImageView: littleNailImageView)
        ringNail.isSelect = isRing
        handleNailUnselect(nailImageView: ringNailImageView)
        middleNail.isSelect = isMiddle
        handleNailUnselect(nailImageView: middleNailImageView)
        indexNail.isSelect = isIndex
        handleNailUnselect(nailImageView: indexNailImageView)
        thumbNail.isSelect = isThumb
        handleNailUnselect(nailImageView: thumbNailImageView)
    }
    
    
    func handleNailSelect(nailImageView: UIImageView, borderWidth: CGFloat, isShowBox: Bool) {
        nailImageView.layer.borderWidth = borderWidth
        nailImageView.layer.borderColor = UIColor.blueCustom().cgColor
        isShowEditBox = isShowBox
    }
    func handleNailUnselect(nailImageView: UIImageView) {
        nailImageView.layer.borderWidth = 0
    }
    
    func setSliderValue(scaleValue: Float, rotateValue: Float) {
        sizeSlider.value = scaleValue
        rotateSlider.value = rotateValue
    }
    
    @objc func littleNaillDrag(_ sender:UIPanGestureRecognizer) {
        handleNailSelect(nailImageView: littleNailImageView, borderWidth: 1, isShowBox: false)
        handleNailUnselect(nailImageView: ringNailImageView)
        handleNailUnselect(nailImageView: middleNailImageView)
        handleNailUnselect(nailImageView: indexNailImageView)
        handleNailUnselect(nailImageView: thumbNailImageView)
        
        let translation = sender.translation(in: self.view)
        if (isRightHand) {
            littleNailImageView.center = CGPoint(x: littleNailImageView.center.x - translation.x, y: littleNailImageView.center.y + translation.y)
            
        }
        else {
            littleNailImageView.center = CGPoint(x: littleNailImageView.center.x + translation.x, y: littleNailImageView.center.y + translation.y)
        }
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    @objc func ringNailDrag(_ sender:UIPanGestureRecognizer) {
        handleNailSelect(nailImageView: ringNailImageView, borderWidth: 1, isShowBox: false)
        handleNailUnselect(nailImageView: littleNailImageView)
        handleNailUnselect(nailImageView: middleNailImageView)
        handleNailUnselect(nailImageView: indexNailImageView)
        handleNailUnselect(nailImageView: thumbNailImageView)
        
        
        let translation = sender.translation(in: self.view)
        if (isRightHand) {
            ringNailImageView.center = CGPoint(x: ringNailImageView.center.x - translation.x, y: ringNailImageView.center.y + translation.y)
            
        }
        else {
            ringNailImageView.center = CGPoint(x: ringNailImageView.center.x + translation.x, y: ringNailImageView.center.y + translation.y)
        }
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    
    @objc func middleNailDrag(_ sender:UIPanGestureRecognizer) {
        handleNailSelect(nailImageView: middleNailImageView, borderWidth: 1, isShowBox: false)
        handleNailUnselect(nailImageView: littleNailImageView)
        handleNailUnselect(nailImageView: ringNailImageView)
        handleNailUnselect(nailImageView: indexNailImageView)
        handleNailUnselect(nailImageView: thumbNailImageView)
        let translation = sender.translation(in: self.view)
        if (isRightHand) {
            middleNailImageView.center = CGPoint(x: middleNailImageView.center.x - translation.x, y: middleNailImageView.center.y + translation.y)
            
        }
        else {
            middleNailImageView.center = CGPoint(x: middleNailImageView.center.x + translation.x, y: middleNailImageView.center.y + translation.y)
        }
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    @objc func indexNailDrag(_ sender:UIPanGestureRecognizer) {
        handleNailSelect(nailImageView: indexNailImageView, borderWidth: 1, isShowBox: false)
        handleNailUnselect(nailImageView: littleNailImageView)
        handleNailUnselect(nailImageView: ringNailImageView)
        handleNailUnselect(nailImageView: middleNailImageView)
        handleNailUnselect(nailImageView: thumbNailImageView)
        
        let translation = sender.translation(in: self.view)
        if (isRightHand) {
            indexNailImageView.center = CGPoint(x: indexNailImageView.center.x - translation.x, y: indexNailImageView.center.y + translation.y)
            
        }
        else {
            indexNailImageView.center = CGPoint(x: indexNailImageView.center.x + translation.x, y: indexNailImageView.center.y + translation.y)
        }
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    @objc func thumbNailDrag(_ sender:UIPanGestureRecognizer) {
        handleNailSelect(nailImageView: thumbNailImageView, borderWidth: 1, isShowBox: false)
        handleNailUnselect(nailImageView: littleNailImageView)
        handleNailUnselect(nailImageView: ringNailImageView)
        handleNailUnselect(nailImageView: middleNailImageView)
        handleNailUnselect(nailImageView: indexNailImageView)
        
        let translation = sender.translation(in: self.view)
        if (isRightHand) {
            thumbNailImageView.center = CGPoint(x: thumbNailImageView.center.x - translation.x, y: thumbNailImageView.center.y + translation.y)
            
        }
        else {
            thumbNailImageView.center = CGPoint(x: thumbNailImageView.center.x + translation.x, y: thumbNailImageView.center.y + translation.y)
        }
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    func handleSlider(enable: Bool) {
        if (enable) {
            sizeSlider.isUserInteractionEnabled = true
            rotateSlider.isUserInteractionEnabled = true
        }
        else {
            sizeSlider.isUserInteractionEnabled = false
            rotateSlider.isUserInteractionEnabled = false
        }
    }
    
    // MARK: - Slider value change
    @IBAction func sizeSliderChangeValue(_ sender: Any) {
        let scaleTransform = CGAffineTransform(scaleX: CGFloat(sizeSlider.value), y: CGFloat(sizeSlider.value))
        if (littleNail.isSelect) {
            littleNail.scaleValue = sizeSlider.value
            littleNail.scale = scaleTransform
            littleNailImageView.transform = CGAffineTransform(rotationAngle: littleNail.degree).concatenating(scaleTransform)
        }
        else{
            if (ringNail.isSelect) {
                ringNail.scaleValue = sizeSlider.value
                ringNail.scale = scaleTransform
                ringNailImageView.transform = CGAffineTransform(rotationAngle: ringNail.degree).concatenating(scaleTransform)
            }
            else {
                if (middleNail.isSelect) {
                    middleNail.scaleValue = sizeSlider.value
                    middleNail.scale = scaleTransform
                    middleNailImageView.transform = CGAffineTransform(rotationAngle: middleNail.degree).concatenating(scaleTransform)
                }
                else {
                    if (indexNail.isSelect) {
                        indexNail.scaleValue = sizeSlider.value
                        indexNail.scale = scaleTransform
                        indexNailImageView.transform = CGAffineTransform(rotationAngle: indexNail.degree).concatenating(scaleTransform)
                    }
                    else {
                        if (thumbNail.isSelect) {
                            thumbNail.scaleValue = sizeSlider.value
                            thumbNail.scale = scaleTransform
                            thumbNailImageView.transform = CGAffineTransform(rotationAngle: thumbNail.degree).concatenating(scaleTransform)
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
            littleNailImageView.transform = CGAffineTransform(rotationAngle: littleNail.degree).concatenating(littleNail.scale)
        }
        else {
            if (ringNail.isSelect) {
                ringNail.degree = angle
                ringNail.rotateValue = rotateSlider.value
                ringNailImageView.transform =  CGAffineTransform(rotationAngle: ringNail.degree).concatenating(ringNail.scale)
            }
            else {
                if (middleNail.isSelect) {
                    middleNail.degree = angle
                    middleNail.rotateValue = rotateSlider.value
                    middleNailImageView.transform = CGAffineTransform(rotationAngle: middleNail.degree).concatenating(middleNail.scale)
                }
                else {
                    if (indexNail.isSelect) {
                        indexNail.degree = angle
                        indexNail.rotateValue = rotateSlider.value
                        indexNailImageView.transform =  CGAffineTransform(rotationAngle: indexNail.degree).concatenating(indexNail.scale)
                    }
                    else {
                        if (thumbNail.isSelect) {
                            thumbNail.degree = angle
                            thumbNail.rotateValue = rotateSlider.value
                            thumbNailImageView.transform =  CGAffineTransform(rotationAngle: thumbNail.degree).concatenating(thumbNail.scale)
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
    
    
    @IBAction func editTapped(_ sender: UIButton) {
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
                    littleNailImageView.layer.borderWidth = 0
                    ringNailImageView.layer.borderWidth = 0
                    middleNailImageView.layer.borderWidth = 0
                    indexNailImageView.layer.borderWidth = 0
                    thumbNailImageView.layer.borderWidth = 0
                    let image = UIImage(view: handView)
                    CustomPhotoAlbum.sharedInstance.saveImage(image: image)
                }
            }
        }
        littleNail.isSelect = false
        ringNail.isSelect = false
        middleNail.isSelect = false
        indexNail.isSelect = false
        thumbNail.isSelect = false
        handleNailUnselect(nailImageView: littleNailImageView)
        handleNailUnselect(nailImageView: ringNailImageView)
        handleNailUnselect(nailImageView: middleNailImageView)
        handleNailUnselect(nailImageView: indexNailImageView)
        handleNailUnselect(nailImageView: thumbNailImageView)
        handleSlider(enable: false)
        optionCollectionView.reloadData()
        
    }
    
    func setOptionEdit(isColor: Bool, isShape:Bool, isStyle: Bool) {
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
        else {
            if isChooseShape {
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
        middleNailImageView.image =  image
        thumbNailImageView.image = image
        littleNailImageView.image = image
        indexNailImageView.image = image
        ringNailImageView.image = image
    }
    
    func setColorNails(color: UIColor) {
        middleNailImageView.tintColor =  color
        thumbNailImageView.tintColor = color
        littleNailImageView.tintColor = color
        indexNailImageView.tintColor = color
        ringNailImageView.tintColor = color
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

