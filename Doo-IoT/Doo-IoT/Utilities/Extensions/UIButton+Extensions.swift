//
//  UIButton+Extensions.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 03/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

extension UIButton {
    func setThemeOnboardingNext() {
        backgroundColor = UIColor.signUpButtonBackground
        layer.cornerRadius = 6.7
        setImage(UIImage(named: "nextArrowWhite"), for: .normal)
    }

    func setThemePurple(_ title: String, fontSize: CGFloat) {
        setTitle(title, for: .normal)
        setTitleColor(UIColor.white, for: .normal)
        titleLabel?.font = UIFont.Poppins.medium(fontSize)
        backgroundColor = UIColor.signUpButtonBackground
        cornerRadius = 6.7
    }
    
    // Note: set button type Custom from storyboard
    func setThemeAppBlue(_ title: String) {
        setTitleColor(UIColor.skinText, for: .normal)
        titleLabel?.font = UIFont.Poppins.medium(12)
        setTitle(title, for: .normal)
        backgroundColor = UIColor.blueSwitch
        cornerRadius = 6.7
        layoutIfNeeded()
    }
    
    func setLightThemeAppBlue(_ title: String) {
        setTitleColor(UIColor.blueSwitch, for: .normal)
        titleLabel?.font = UIFont.Poppins.medium(12)
        setTitle(title, for: .normal)
        backgroundColor = UIColor.blueSwitchAlpha04
        cornerRadius = 6.7
        layoutIfNeeded()
    }



    // Note: set button type Custom from storyboard
    func setThemeAppBlueWithArrow(_ title: String) {
        semanticContentAttribute = .forceRightToLeft
        contentHorizontalAlignment = .left
        setTitleColor(UIColor.skinText, for: .normal)
        titleLabel?.font = UIFont.Poppins.medium(12)
        setTitle(title, for: .normal)
        backgroundColor = UIColor.blueSwitch
        setImage(UIImage(named: "rightArrowSkin"), for: .normal)
        cornerRadius = 6.7

        layoutIfNeeded()
        var titleLabelWidth: CGFloat = 0
        if let titleLabelStrong = titleLabel{
            titleLabelWidth = titleLabelStrong.frame.width
        }
        var imageViewWidth: CGFloat = 0
        if let imageViewStrong = imageView{
            imageViewWidth = imageViewStrong.frame.width
        }
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        imageEdgeInsets = UIEdgeInsets(top: 0, left: bounds.width - titleLabelWidth - imageViewWidth - 20, bottom: 0, right: 0)
    }

}
