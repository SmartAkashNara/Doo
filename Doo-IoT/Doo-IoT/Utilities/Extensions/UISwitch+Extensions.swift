//
//  UISwitch+Extensions.swift
//  Doo-IoT
//
//  Created by Shraddha on 24/08/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation


extension UISwitch {
    
    func changeSwitchThumbColorBasedOnState() {
//        if self.isOn {
//            self.thumbTintColor = UIColor.blueSwitch
//        } else {
//            self.thumbTintColor = UIColor.blueHeadingAlpha20
//        }
    }
    
    func dooDefaultSetup() {
        self.onTintColor = UIColor.blueSwitch
        self.thumbTintColor = UIColor.white
        self.backgroundColor = UIColor.blueSwitchAlpha10
        self.layer.cornerRadius = 16
    }
}
