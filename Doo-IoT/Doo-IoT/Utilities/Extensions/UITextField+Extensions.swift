//
//  UITextField+Extensions.swift
//  Doo-IoT
//
//  Created by Akash Nara on 28/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    func trimSpace() {
        self.text = self.text!.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    func lowercased() {
        self.text = self.text!.lowercased()
    }
    
    func getText() -> String {
        guard let currentText = text else { return "" }
        return currentText.trimSpace()
    }
    
    func getShouldChangedText(range:NSRange, replacementString:String) -> String {
        guard let currentText = text else { return "" }
        return currentText.trimSpaceAndNewline
    }
    
    func getSearchText(range:NSRange, replacementString:String) -> String {
        if let textFieldString = self.text, let swtRange = Range(range, in: textFieldString) {
            let fullString = textFieldString.replacingCharacters(in: swtRange, with: replacementString)
            return fullString
        }
        return ""
    }
}

// Speicific to this project
extension GenericTextField {
    func addThemeToTextarea(_ placeHolder: String, leading: CGFloat = 14.0, trailing: CGFloat = 20.0) {
        self.borderStyle = .none
        self.placeholder = placeHolder
        self.backgroundColor = UIColor.textFieldbackgroundColor
        self.textColor = UIColor.blueHeading
        self.tintColor = UIColor.blueHeading
        self.cornerRadius = 6.7
        self.font = UIFont.Poppins.medium(15)
        if leading != 0.0 {
            self.leadingGap = leading
        }
        if trailing != 0.0 {
            self.trailingGap = trailing
        }
    }
}
