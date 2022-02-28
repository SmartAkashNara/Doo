//
//  GroupDetailColorPickerTVCell.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 27/05/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class GroupDetailColorPickerTVCell: UITableViewCell {
    
    static let identifier = "GroupDetailColorPickerTVCell"
    
    @IBOutlet weak var labelPowerTitle: UILabel!
    @IBOutlet weak var switchPowerOnOFF: UISwitch!
    @IBOutlet weak var sepratorView: UIView!
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

    
    var didTap:((UIColor)->())?
    private var fixColor = UIColor.blueHeading
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
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
        
        
        selectionStyle = .none
        sepratorView.backgroundColor = UIColor.blueHeadingAlpha10
        
        buttonSave.setThemeAppBlue(localizeFor("Save"))
        buttonCancel.setLightThemeAppBlue(localizeFor("Cancel"))
        
        labelPowerTitle.font = UIFont.Poppins.medium(11.3)
        labelPowerTitle.textColor = UIColor.black
        labelPowerTitle.numberOfLines = 2
        labelPowerTitle.text = localizeFor("power")
        
        configureColorPicker()
        setColorAllComponent(color: fixColor)
        
        buttonCancel.addTarget(self, action: #selector(cellButtonCancelClicked(sender:)), for: .touchUpInside)
        
        switchPowerOnOFF.isOn = false
        switchPowerOnOFF.dooDefaultSetup()
        switchPowerOnOFF.changeSwitchThumbColorBasedOnState()
    }
    
    @objc func cellButtonCancelClicked(sender:UIButton){
        setColorAllComponent(color: fixColor)
    }

    
    func setColorAllComponent(color:UIColor){
        rColortextField.setText = getColorRGB(color: color).r
        gColortextField.setText = getColorRGB(color: color).g
        bColortextField.setText = getColorRGB(color: color).b
        hexCodeColortextField.setText = hexStringFromColor(color: color)
        colorPicker.color = color
        colorPicker.setViewColor(color)
    }
    
    func getColorRGB(color:UIColor) -> (r:String,g:String,b:String) {
        guard let components = color.cgColor.components, components.count >= 3 else {
            return ("0","0","0")
        }
        
        let red = "\(Int(round(components[0]*100)))"
        let green = "\(Int(round(components[1]*100)))"
        let blue = "\(Int(round(components[2]*100)))"
        
        return (red,green,blue)
    }
    
    
    func hexStringFromColor(color: UIColor) -> String {
        let components = color.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0

        let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        print(hexString)
        return hexString
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
    
    func configureColorPicker(){
        colorPicker.delegateOfColorPicker = self
        colorPicker.color = fixColor
        colorPicker.setViewColor(fixColor)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension GroupDetailColorPickerTVCell {
    func cellConfig(statusOnOff: Bool, color:UIColor = UIColor.red) {
        switchPowerOnOFF.setOn(statusOnOff, animated: true)
        switchPowerOnOFF.changeSwitchThumbColorBasedOnState()
        fixColor = color
        setColorAllComponent(color: color)
//        hexCodeColortextField.setText = hexStringFromColor(color: fixColor)
        // pickerController?.color = color
//        colorPicker.selectedColor = fixColor
    }
}


extension GroupDetailColorPickerTVCell: SwiftHSVColorPickerDelegate{
    func colorPicked(_ color: UIColor) {
        fixColor = color
        setColorAllComponent(color: color)
    }
    func colorPickedWithBrightness(_ color: UIColor) {
        fixColor = color
        setColorAllComponent(color: color)
    }
}

extension GroupDetailColorPickerTVCell: UITextFieldDelegate{
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
