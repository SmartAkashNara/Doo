//
//  ApplienceRGBColorPickerTVCell.swift
//  DooIotExtensionUI
//
//  Created by Akash on 30/12/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation

import UIKit

class ApplienceRGBColorPickerTVCell: UITableViewCell {
    
    static let identifier = "ApplienceRGBColorPickerTVCell"
    
    @IBOutlet weak var sepratorView: UIView!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet var colorPicker:SwiftHSVColorPicker!

    
    var didTap:((UIColor)->())?
    private var fixColor = UIColor.blueHeading
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        
        buttonSave.setThemeAppBlue("Save")
        buttonCancel.setThemeAppBlue("Cancel")
        
        configureColorPicker()
        setColorAllComponent(color: fixColor)
        
        buttonCancel.addTarget(self, action: #selector(cellButtonCancelClicked(sender:)), for: .touchUpInside)
        self.contentView.backgroundColor = .clear
    }
    
    @objc func cellButtonCancelClicked(sender:UIButton){
        setColorAllComponent(color: fixColor)
    }

    
    func setColorAllComponent(color:UIColor){
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
    
    func configureColorPicker(){
        colorPicker.delegateOfColorPicker = self
        colorPicker.color = fixColor
        colorPicker.setViewColor(fixColor)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension ApplienceRGBColorPickerTVCell {
    func cellConfig(_ color:UIColor = UIColor.red) {
        fixColor = color
        setColorAllComponent(color: color)
    }
}

extension ApplienceRGBColorPickerTVCell: SwiftHSVColorPickerDelegate{
    func colorPicked(_ color: UIColor) {
        fixColor = color
        setColorAllComponent(color: color)
    }
    func colorPickedWithBrightness(_ color: UIColor) {
        fixColor = color
        setColorAllComponent(color: color)
    }
}
