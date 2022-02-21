//
//  ApplianceDetailColorPickerView.swift
//  Doo-IoT
//
//  Created by Akash on 26/10/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//ApplianceDetailColorPickerView

import Foundation
class ApplianceDetailColorPickerView: UIView {
    
    // MARK: - IBOutlets
    @IBOutlet weak var viewApplianceDetailColorPickerMain: UIView!
    @IBOutlet weak var viewSwitchOnOff: PowerSwitchView!
    @IBOutlet weak var viewApplianceDetailFeature: UIView!
    @IBOutlet weak var scrollViewApplianceDetailColorPicker: UIScrollView!{
        didSet{
            scrollViewApplianceDetailColorPicker.bounces = false
            scrollViewApplianceDetailColorPicker.isPagingEnabled = false
        }
    }
    @IBOutlet weak var viewApplianceDetailColorPickerInsideScroll: UIView!
    
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
    
    // Constraints
    @IBOutlet weak var constraintHeightEqualToSuperview: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightOfViewApplianceDEtailFeature: NSLayoutConstraint!
    @IBOutlet weak var constraintProportionalHeightOfColorPicker: NSLayoutConstraint!
    @IBOutlet weak var stackViewBottomSaveAndCancelButton: NSLayoutConstraint!
    @IBOutlet weak var constrainBottomView: NSLayoutConstraint!
    
    private var fixColor = UIColor.red
    var selectColorClouser:((UIColor, String?)->())?
    var powerSwitchOnOFF:((Bool, Int)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.configWithApplianceObj()
        self.layoutSubviews()
        print("viewApplianceDetailColorPickerMain:\(self.viewApplianceDetailColorPickerMain.frame)")
        
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
        buttonCancel.setLightThemeAppBlue(localizeFor("Cancel"))
        
        setColorAllComponent(color: fixColor)
        colorPicker.delegateOfColorPicker = self
        buttonCancel.addTarget(self, action: #selector(cellButtonCancelClicked(sender:)), for: .touchUpInside)
        //        addKeyboardNotifs()
        
    }
    
    func reSizeXib(frame:CGRect) {
        self.frame = frame
        self.layoutSubviews()
    }
    
    func setSizeOfViewBasedOnContent(isAccordingSizeOfScreen: Bool) {
        
        /*
         If flag is send as true, then whole content will be fit inside screensize, accordingly color picker height will be set and content will not be scrollable.
         
         If flag is end as false, then whole content will not feet the screen size, color picker height will be set proportional to screen height and content will be scrollable.
         
         To make content fit with the screen size pass true to this method
         */
        
        
        if isAccordingSizeOfScreen {
            self.constraintHeightEqualToSuperview.isActive = true
            self.constraintHeightOfViewApplianceDEtailFeature.isActive = true
            self.constraintProportionalHeightOfColorPicker.isActive = false
        } else {
            self.constraintHeightEqualToSuperview.isActive = false
            self.constraintHeightOfViewApplianceDEtailFeature.isActive = false
            self.constraintProportionalHeightOfColorPicker.isActive = true
        }
    }
    
    // MARK: - Other Methods
    func configWithApplianceObj(applianceModel: ApplianceDataModel? = nil) {
        if let appliance = applianceModel {
            self.viewSwitchOnOff.configWithApplianceObj(appliance: appliance)
            fixColor = appliance.applianceColor
            setColorAllComponent(color: appliance.applianceColor)
            self.viewSwitchOnOff.switchPower.switchStatusChanged = { value in
                self.powerSwitchOnOFF?(self.viewSwitchOnOff.switchPower.isON, self.viewSwitchOnOff.switchPower.tag)
            }
        }else{
            setColorAllComponent(color: fixColor)
        }
    }
    
    @objc func cellButtonCancelClicked(sender:UIButton){
        setColorAllComponent(color: fixColor)
    }
    
    func setColorAllComponent(color:UIColor){
        rColortextField.setText = getColorRGB(color: color).r
        gColortextField.setText = getColorRGB(color: color).g
        bColortextField.setText = getColorRGB(color: color).b
        hexCodeColortextField.setText = color.hexStringFromColor()
        colorPicker.color = fixColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.colorPicker.setViewColor(self.fixColor)
        }
    }
    
    func getColorRGB(color:UIColor) -> (r:String,g:String,b:String) {
        guard let rgb = color.rgb() else {return ("0","0","0")}
        let red = rgb.red
        let green = rgb.green
        let blue = rgb.blue
        return ("\(red)","\(green)", "\(blue)")
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
        default:
            break
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension ApplianceDetailColorPickerView: SwiftHSVColorPickerDelegate{
    func colorPicked(_ color: UIColor) {
//        setColorAllComponent(color: color)
        selectColorClouser?(color, color.hexStringFromColor())
    }
    func colorPickedWithBrightness(_ color: UIColor) {
        selectColorClouser?(color, color.hexStringFromColor())
    }
}

extension ApplianceDetailColorPickerView: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = textField == hexCodeColortextField.genericTextfield ? 7 : 3
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: NSString =
        currentString.replacingCharacters(in: range, with: string) as NSString
        if (string.count == 0 && range.length == 1) {
            return true
        }
        return newString.length <= maxLength
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        switch textField {
        case hexCodeColortextField.genericTextfield:
            guard let hexCode = hexCodeColortextField.getText else {
                return
            }
            self.setColorAllComponent(color: UIColor.init(hex: hexCode))
        default:
            guard let  r = rColortextField.getText, !r.isEmpty else {
                return
            }
            
            guard let  g = gColortextField.getText, !g.isEmpty else {
                return
            }
            
            guard let b = bColortextField.getText, !b.isEmpty else {
                return
            }
            
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


// MARK: Keyboard notifications
extension ApplianceDetailColorPickerView {
    func addKeyboardNotifs() {
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else{
            return
        }
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: duration) {
            self.constrainBottomView.constant = keyboardSize.height - cueSize.bottomHeightOfSafeArea
            self.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: duration) {
            self.constrainBottomView.constant = 0
            self.layoutIfNeeded()
        }
    }
    
}
