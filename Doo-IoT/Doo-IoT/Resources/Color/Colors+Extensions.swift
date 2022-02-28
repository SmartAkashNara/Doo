//
//  Colors.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 19/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit
import SwiftUI

extension UIColor {
    static var blueFavDevice: UIColor { return UIColor.asset("blueFavDevice") }
    
    // light: 43 55 79
    static var blueHeading: UIColor { return UIColor.asset("blueHeading") }
    static var blueHeadingAlpha04: UIColor { return UIColor.asset("blueHeadingAlpha06") }
    static var blueHeadingAlpha06: UIColor { return UIColor.asset("blueHeadingAlpha06") }
    static var blueHeadingAlpha10: UIColor { return UIColor.asset("blueHeadingAlpha10") }
    static var blueHeadingAlpha20: UIColor { return UIColor.asset("blueHeadingAlpha20") }
    static var blueHeadingAlpha30: UIColor { return UIColor.asset("blueHeadingAlpha30") }
    static var blueHeadingAlpha40: UIColor { return UIColor.asset("blueHeadingAlpha40") }
    static var blueHeadingAlpha50: UIColor { return UIColor.asset("blueHeadingAlpha50") }
    static var blueHeadingAlpha60: UIColor { return UIColor.asset("blueHeadingAlpha60") }
    static var blueHeadingAlpha70: UIColor { return UIColor.asset("blueHeadingAlpha70") }
    
    // light: 0 78 129
    static var blueSwitch: UIColor { return UIColor.asset("blueSwitch") }
    static var blueSwitchAlpha04: UIColor { return UIColor.asset("blueSwitchAlpha04") }
    static var blueSwitchAlpha10: UIColor { return UIColor.asset("blueSwitchAlpha10") }
    static var blueSwitchAlpha20: UIColor { return UIColor.asset("blueSwitchAlpha20") }
    static var blueSwitchAlpha50: UIColor { return UIColor.asset("blueSwitchAlpha50") }
    static var greenOnline: UIColor { return UIColor.asset("greenOnline") }
    static var greenInvited: UIColor { return UIColor.asset("greenInvited") }
    static var grayMore: UIColor { return UIColor.asset("grayMore") }
    static var grayOffDevice: UIColor { return UIColor.asset("grayOffDevice") }
    static var graySceneCard: UIColor { return UIColor.asset("graySceneCard") }
    static var purpleButtonText: UIColor { return UIColor.asset("purpleButtonText") }
    static var redOffline: UIColor { return UIColor.asset("redOffline") }
    static var signUpButtonBackground: UIColor { return UIColor.asset("signUpButtonBackground") }
    static var grayCountryHeader: UIColor { return UIColor.asset("grayCountryHeader") }
    static var blackAlpha3: UIColor { return UIColor.asset("blackAlpha3") }
    static var signUpButtonTitle: UIColor { return UIColor.asset("signUpButtonTitle") }
    static var blueSwitchAlpha12: UIColor { return UIColor.asset("blueSwitchAlpha12") }

    // light: 241 94 85
    static var textFieldErrorColor: UIColor { return UIColor.asset("TextFieldErrorColor") }
    
    // light: 255 23 68
    static var redButtonColor: UIColor { return UIColor.asset("redButton") }
    static var textfieldTitleColor: UIColor { return UIColor.asset("titleColor") }
    static var skinText: UIColor { return UIColor.asset("skinText") }
    static var textFieldbackgroundColor: UIColor { return UIColor.asset("textFieldbackgroundColor") }
    static var orangeScanIndicator: UIColor { return UIColor.asset("orangeScanIndicator") }
    static var sliderUnSelected: UIColor { return UIColor.asset("sliderUnSelected") }
    static var graySubTile: UIColor { return UIColor.asset("GraySubTile") }
    
    // light: 212 215 220
    static var borderColorOffline: UIColor { return UIColor.asset("borderColorOffline") }

    // Edusense Green
    static var app_green: UIColor { return UIColor.asset("app_green") }

    // Pending...
    static var greenInvitedAlpha08: UIColor { return UIColor.asset("greenInvitedAlpha08") }
    static var blueSwitchAlpha08: UIColor { return UIColor.asset("blueSwitchAlpha08") }
    static var orangeScanIndicatorAlpha08: UIColor { return UIColor.asset("orangeScanIndicatorAlpha08") }
    static var daysInActiveBackground: UIColor { return UIColor.asset("daysInActiveBackground") }

    static var applianceOnColor: UIColor { return UIColor.asset("applianceOnColor") }
    
    static var switchOnTintColor: UIColor {
        return UIColor.asset("switchOnTintColor")
    }
    
    static var switchOffTintColor: UIColor {
        return UIColor.asset("switchOffTintColor")
    }
    static var offThumbTintColor: UIColor {
        return UIColor.asset("offThumbTintColor")
    }
    
    // light: 230 230 230
    static var lightSiriBackgroundColor: UIColor { return UIColor.asset("lightSiriBackgroundColor") }
    
    // gray: 218 219 220
    static var grayCancelButtonAlexa: UIColor { return UIColor.asset("grayCancelButtonAlexa") }

    
    
    static func asset(_ name: String) -> UIColor {
        if let color = UIColor(named: name){
            return color
        } else {
            return UIColor.white
        }
    }
}

extension Color {
    static var grayTabbarBackground: Color {
        return Color("grayTabbarBackground")
    }
    static var tabbarTitle: Color {
        return Color("tabbarTitle")
    }
    
}
