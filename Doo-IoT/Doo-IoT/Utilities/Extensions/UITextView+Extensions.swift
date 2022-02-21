//
//  UITextView+Extensions.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 28/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

extension UITextView {
    func trimSpace() {
        self.text = self.text!.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    func lowercased() {
        self.text = self.text!.lowercased()
    }
}

