//
//  EyePasswordTextField.swift
//  CertifID
//
//  Created by Kiran Jasvanee on 04/12/18.
//  Copyright © 2018 SmartSense. All rights reserved.
//

import UIKit


class EyePasswordTextField: GenericTextField {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setEyeOnRight()
        
        // associated with GenericTextField contains leading and trailing gap.
        self.trailingGap = 40
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setEyeOnRight()
        
        // associated with GenericTextField contains leading and trailing gap.
        self.trailingGap = 40
    }
    
    override var disabled: Bool {
        didSet {
            super.disabled = disabled
            eyeButton.alpha = disabled ? 0.7 : 1.0
        }
    }
    
    var eyeButton: UIButton!
    func setEyeOnRight() {
        self.eyeButton = UIButton.init(frame: .zero)
        self.eyeButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.eyeButton)
        
        // add constraints
        self.eyeButton.addRight(isSuperView: self, constant: -4)
        self.eyeButton.addCenterY(inSuperView: self)
        self.eyeButton.addHeight(constant: 44)
        self.eyeButton.addWidth(constant: 44)
        
        // default
        self.eyeButton.setImage(cueImage.Signup.eyeOff, for: .normal)
        self.eyeButton.tag = 0
        self.isSecureTextEntry = true
        
        // action listener
        self.eyeButton.addAction(for: .touchUpInside) {
            if self.eyeButton.tag == 0 {
                self.eyeButton.tag = 1
                self.isSecureTextEntry = false
                self.eyeButton.setImage(cueImage.Signup.eyeOn, for: .normal)
            }else{
                self.eyeButton.tag = 0
                self.isSecureTextEntry = true
                self.eyeButton.setImage(cueImage.Signup.eyeOff, for: .normal)
            }
        }
    }
}
