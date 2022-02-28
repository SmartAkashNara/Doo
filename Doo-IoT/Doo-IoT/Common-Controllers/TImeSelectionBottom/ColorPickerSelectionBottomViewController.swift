//
//  ColorPickerSelectionBottomViewController.swift
//  Doo-IoT
//
//  Created by Akash on 28/10/21.
//  Copyright © 2021 SmartSense. All rights reserved.
// 

import Foundation
import UIKit

class ColorPickerSelectionBottomViewController: UIViewController {
    
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet var colorPicker:SwiftHSVColorPicker!
    
    @IBOutlet var rColortextField:DooTextfieldView1!
    @IBOutlet var gColortextField:DooTextfieldView1!
    @IBOutlet var bColortextField:DooTextfieldView1!
    
    @IBOutlet var labelRColorTitle:UILabel!
    @IBOutlet var labelGColorTitle:UILabel!
    @IBOutlet var labelBColorTitle:UILabel!
    @IBOutlet var labelHexCodeTitle:UILabel!
    
    @IBOutlet var hexCodeColortextField:DooTextfieldView1!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var constraintBottomTableView: NSLayoutConstraint!
    
    var didTap:((UIColor)->())?
    private var fixColor = UIColor.red
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setDefault()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        UIView.animate(withDuration: 0.3) {
            self.constraintBottomTableView.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func setDefault() {
        buttonSave.setThemeAppBlue(localizeFor("save_button"))
        buttonCancel.setLightThemeAppBlue(localizeFor("cancel_button"))
        
        labelRColorTitle.text = "R: "
        labelGColorTitle.text = "G: "
        labelBColorTitle.text = "B: "
        labelHexCodeTitle.text = "Hex: "
        
        labelRColorTitle.textColor = UIColor.blueHeadingAlpha60
        labelGColorTitle.textColor = UIColor.blueHeadingAlpha60
        labelBColorTitle.textColor = UIColor.blueHeadingAlpha60
        labelHexCodeTitle.textColor = UIColor.blueHeadingAlpha60
        
        labelRColorTitle.font = UIFont.Poppins.medium(10)
        labelGColorTitle.font = UIFont.Poppins.medium(10)
        labelBColorTitle.font = UIFont.Poppins.medium(10)
        labelHexCodeTitle.font = UIFont.Poppins.medium(10)
        
        rColortextField.genericTextfield?.addToolBar()
        rColortextField.genericTextfield?.addThemeToTextarea("0")
        rColortextField.genericTextfield?.returnKeyType = .done
        rColortextField.genericTextfield?.delegate = self
        rColortextField.genericTextfield?.leadingGap = 10
        rColortextField.genericTextfield?.trailingGap = 10
        rColortextField.genericTextfield?.keyboardType = .numberPad
        rColortextField.genericTextfield?.font = UIFont.Poppins.medium(10)
        
        gColortextField.genericTextfield?.addThemeToTextarea("0")
        gColortextField.genericTextfield?.returnKeyType = .done
        gColortextField.genericTextfield?.delegate = self
        gColortextField.genericTextfield?.keyboardType = .numberPad
        gColortextField.genericTextfield?.leadingGap = 10
        gColortextField.genericTextfield?.trailingGap = 10
        gColortextField.genericTextfield?.font = UIFont.Poppins.medium(10)
        gColortextField.genericTextfield?.addToolBar()
        
        bColortextField.genericTextfield?.addThemeToTextarea("0")
        bColortextField.genericTextfield?.returnKeyType = .done
        bColortextField.genericTextfield?.delegate = self
        bColortextField.genericTextfield?.keyboardType = .numberPad
        bColortextField.genericTextfield?.leadingGap = 10
        bColortextField.genericTextfield?.trailingGap = 10
        bColortextField.genericTextfield?.font = UIFont.Poppins.medium(10)
        bColortextField.genericTextfield?.addToolBar()
        
        hexCodeColortextField.genericTextfield?.addThemeToTextarea("#000000")
        hexCodeColortextField.genericTextfield?.returnKeyType = .done
        hexCodeColortextField.genericTextfield?.delegate = self
        hexCodeColortextField.genericTextfield?.leadingGap = 10
        hexCodeColortextField.genericTextfield?.trailingGap = 10
        hexCodeColortextField.genericTextfield?.font = UIFont.Poppins.medium(10)
        
        hexCodeColortextField.genericTextfield?.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        buttonSave.setThemeAppBlue(localizeFor("Save"))
        buttonSave.cornerRadius = 16.7
        
        buttonCancel.setLightThemeAppBlue(localizeFor("Cancel"))
        buttonCancel.cornerRadius = 16.7
        
        configureColorPicker()
        setColorAllComponent(color: fixColor)
        
        self.mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.mainView.layer.cornerRadius = 10.0
        
        // remove view when blank area gonna be tapped.
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.dismissViewTapGesture(tapGesture:)))
        backgroundView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setColorAllComponent(color: fixColor)
    }
    
    @objc func dismissViewTapGesture(tapGesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setColorAllComponent(color:UIColor){
        
        let r = color.rgb()?.red ?? 0
        let g = color.rgb()?.green ?? 0
        let b = color.rgb()?.blue ?? 0
        
        rColortextField.setText = "\(r)"
        gColortextField.setText = "\(g)"
        bColortextField.setText = "\(b)"
        hexCodeColortextField.setText = color.hexStringFromColor()
    }
    
    func setColorToPickers(color:UIColor) {
        fixColor = color
    }
    
    @objc func textFieldDidChange(textField:UITextField){
        switch textField {
        case hexCodeColortextField.genericTextfield:
            var textHex = (hexCodeColortextField.genericTextfield?.getText())
            textHex!.removeAll(where: {$0 == "#"})
            
            if let hexCode = textHex, hexCode.count == 6{
                colorPicker.color = UIColor.init(hex: hexCode)
                colorPicker.setViewColor(UIColor.init(hex: hexCode))
            }
        default: break
        }
    }
    
    func configureColorPicker(){
        colorPicker.delegateOfColorPicker = self
        colorPicker.color = fixColor
        colorPicker.setViewColor(fixColor)
    }
}

extension ColorPickerSelectionBottomViewController{
    @IBAction  func  buttonCancelClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonSaveClicked(_ sender: UIButton) {
        self.didTap?(fixColor)
        self.dismiss(animated: true, completion: nil)
    }
}
extension ColorPickerSelectionBottomViewController: SwiftHSVColorPickerDelegate{
    func colorPicked(_ color: UIColor) {
//        setColorAllComponent(color: color)
        fixColor = color
    }
    
    func colorPickedWithBrightness(_ color: UIColor) {
        fixColor = color
    }
}

extension ColorPickerSelectionBottomViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = textField == hexCodeColortextField.genericTextfield ? 7 : 3
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        if (string.count == 0 && range.length == 1) { return true }
        return newString.length <= maxLength
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        switch textField {
        case hexCodeColortextField.genericTextfield:
            guard let hexCode = hexCodeColortextField.getText else { return }
            self.setColorAllComponent(color: UIColor.init(hex: hexCode))
        default:
            guard let r = rColortextField.getText, !r.isEmpty else { return }
            guard let g = gColortextField.getText, !g.isEmpty else { return }
            guard let b = bColortextField.getText, !b.isEmpty else { return}
            let color = getUIColorFromRGBThreeIntegers(red: Int(r) ?? 0, green: Int(g) ?? 0, blue: Int(b) ?? 0)
            self.setColorAllComponent(color: color)
        }
    }
    
    func getUIColorFromRGBThreeIntegers(red: Int, green: Int, blue: Int) -> UIColor {
        return UIColor(red: CGFloat(Float(red) / 255.0),
                       green: CGFloat(Float(green) / 255.0),
                       blue: CGFloat(Float(blue) / 255.0),
                       alpha: CGFloat(1.0))
    }
}

