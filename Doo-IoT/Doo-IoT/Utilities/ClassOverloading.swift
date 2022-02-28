//
//  ClassOverloading.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 17/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class IphoneSEConstraint: NSLayoutConstraint{
    @IBInspectable var SEConstant: CGFloat {
        get { return self.constant }
        set { self.constant = cueDevice.isDeviceSEOrLower ? newValue : constant }
    }
}

class SEStackView: UIStackView{
    @IBInspectable var SESpace: CGFloat {
        get { return self.spacing }
        set { if cueDevice.isDeviceSEOrLower { self.spacing = newValue } }
    }
}

