//
//  DooTextfieldView1.swift
//  Doo-IoT
//
//  Created by Akash on 28/10/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation
import UIKit

class DooTextfieldView1: UIView {
    
    private var heightConstraintOfView: NSLayoutConstraint? = nil
    private var heightOfTextfield: CGFloat = 0.0
    
    var titleColor: UIColor? = nil

    var genericTextfield: GenericTextField? = nil
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initSetup()

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func initSetup() {
        self.getHeightConstraintOfTextfield()
        
        func addTextfield(_ textfield: GenericTextField) {
            self.addSubview(textfield)
            
            textfield.textColor = UIColor.blueSwitch
            tintColor = UIColor.blueSwitch
            backgroundColor = UIColor.blueSwitchAlpha10
            self.cornerRadius = 6.7

            
            textfield.addLeft(isSuperView: self, constant: 0)
            textfield.addRight(isSuperView: self, constant: 0)
            textfield.addHeight(constant: Double(30))
            textfield.addTarget(self, action: #selector(self.editingDidBegin(sender:)), for: .editingDidBegin)
        }
        
        self.genericTextfield = GenericTextField.init(frame: .zero)
        self.genericTextfield?.translatesAutoresizingMaskIntoConstraints = false
        addTextfield(self.genericTextfield!)

       
    }
    
    @objc func editingDidBegin(sender: UITextField) {
        
    }
    
    func getHeightConstraintOfTextfield() {
        for constraint in self.constraints {
            if constraint.firstAttribute == .height {
                self.heightConstraintOfView = constraint
                self.heightOfTextfield = constraint.constant
            }
        }
    }
    
    
    var setText: String = "" {
        didSet {
                self.genericTextfield?.text = setText
        }
    }

    var getText: String? {
        return self.genericTextfield?.text
    }
}

