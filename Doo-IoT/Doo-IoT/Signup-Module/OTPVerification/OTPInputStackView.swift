//
//  OTPInputStackView.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 30/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation
import UIKit

@objc protocol AutoOTPStackViewDelegate {
    func didReceivedOTP(_ otpValue: String)
    func didModifyingOTP()
}


class AutoOTPStackView: UIStackView {
    
    var activeTextField: AutoOTPTextfield? = nil {
        didSet {
            setFocusToTextfield()
        }
    }
    
    var mockTextfiledForAutoOTP: MockOTPTextfield = MockOTPTextfield.init(frame: .zero)
    weak var delegateOfAutoOTPStackView: AutoOTPStackViewDelegate? = nil
    
    // auto OTP helper properties
    var isAutoPossibilities: Bool = false
    var autoOTPReceived: String = "" {
        didSet {
            if !autoOTPReceived.isEmpty && (self.autoOTPReceived.count == self.arrangedSubviews.count){
                for view in self.arrangedSubviews {
                    if let textfield = view as? AutoOTPTextfield {
                        textfield.text = String(self.autoOTPReceived[textfield.tag])
                    }
                }
                self.delegateOfAutoOTPStackView?.didReceivedOTP(autoOTPReceived)
                self.setFocusKeyboardOff()
            }
        }
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        self.mockTextFieldSetup()
        self.initSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.mockTextFieldSetup()
        self.initSetup()
    }
    
    // Textfield which shouldn't be visible but all the texts will go here only.
    func mockTextFieldSetup() {
        self.addSubview(self.mockTextfiledForAutoOTP)
        self.mockTextfiledForAutoOTP.keyboardType = .numberPad
        self.mockTextfiledForAutoOTP.delegate = self
        self.mockTextfiledForAutoOTP.delegateOfOTPBox = self
        self.mockTextfiledForAutoOTP.becomeFirstResponder()
    }
    
    // actual textfields
    func initSetup() {
        var index = 0
        for view in self.arrangedSubviews {
            if let textfieldView = view as? AutoOTPTextfield {
                if index == 0 {
                    self.activeTextField = textfieldView
                }
                textfieldView.delegate = self
                textfieldView.tag = index
                // Change here to set Mont.... font.
                textfieldView.font = UIFont.Poppins.medium(14.0)
                textfieldView.textColor = UIColor.black
                textfieldView.delegate = self
                textfieldView.keyboardType = .numberPad
                textfieldView.inputView = UIView.init(frame: .zero)
            }
            index += 1
        }
    }
    
    // Custom bar to show mock focus to actual textfields.
    func setFocusToTextfield() {
        self.activeTextField?.isActive = true
    }
    
    func setFocusKeyboardOff() {
        self.mockTextfiledForAutoOTP.resignFirstResponder()
        self.activeTextField?.isActive = false
        self.activeTextField = nil
    }
    func isKeyboardFocusOff() -> Bool {
        return (self.activeTextField != nil) ? false : true
    }
}

// MARK: Next handler
extension AutoOTPStackView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let focusTextfield = textField as? AutoOTPTextfield {
            self.setActiveTextfield(focusTextfield)
            return false
        }
        return true
    }
    
    // With default keyboard
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //print("string value: \(string)")
        // This might an OTP
        if string == ""{
            self.isAutoPossibilities = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                self.autoOTPReceived = self.mockTextfiledForAutoOTP.text ?? ""
                self.isAutoPossibilities = false
                self.mockTextfiledForAutoOTP.text = "" // It has to be done blank afte you applying an OTP. Once OTP has been added inside your textfield, upon next OTP, keyboard won't show up next arrived OTP.
            }
        }
        guard !self.isAutoPossibilities else{
            return true
        }
        // Manual entry
        if let activeOTPTextfield = self.activeTextField {
            activeOTPTextfield.text = string
            if let nextTextfield = self.setToNext(textField: activeOTPTextfield) {
                nextTextfield.text = "" // if next textfield already having any value, it will be vanished.
                setActiveTextfield(nextTextfield)
            }else{
                // this block will run when there is no next textfield
                self.mockTextfiledForAutoOTP.resignFirstResponder()
                self.activeTextField?.isActive = false
                self.verifyAndSendOTPToImplementor()
            }
        }
        return false
    }
    func setActiveTextfield(_ textfield: AutoOTPTextfield?) {
        self.activeTextField?.isActive = false
        self.activeTextField = textfield
        self.activeTextField?.isActive = true
        self.activeTextField?.text = ""
        self.mockTextfiledForAutoOTP.becomeFirstResponder()
        self.delegateOfAutoOTPStackView?.didModifyingOTP()
    }
    func verifyAndSendOTPToImplementor() {
        var otpValueAppended = ""
        // get otp value from all textfields and if OTP having the same count compare to no of boxes available in this stackview, send otp value to implementator
        for view in self.arrangedSubviews {
            if let textfield = view as? AutoOTPTextfield {
                otpValueAppended += textfield.text ?? ""
            }
        }
        if otpValueAppended.count == self.arrangedSubviews.count {
            self.delegateOfAutoOTPStackView?.didReceivedOTP(otpValueAppended)
        }else{
            
        }
    }
    
    @discardableResult
    func setToNext(textField: AutoOTPTextfield) -> AutoOTPTextfield?{
        let index = textField.tag
        if self.arrangedSubviews.indices.contains(index+1) {
            if let textfieldView = self.arrangedSubviews[index+1] as? AutoOTPTextfield {
                // if next textfield already having any otp value. don't focus to next textfield.
                if let textInsideTextfield = textfieldView.text, textInsideTextfield.isEmpty {
                    return textfieldView
                }
            }
        }
        return nil
    }
    func setToPrevious() {
        if let activeOTPTextfield = self.activeTextField {
            let index = activeOTPTextfield.tag
            if self.arrangedSubviews.indices.contains(index-1) {
                if let textfieldView = self.arrangedSubviews[index-1] as? AutoOTPTextfield {
                    self.setActiveTextfield(textfieldView)
                }
            }
        }
    }
}


extension AutoOTPStackView: MockOTPTextfieldDelegate {
    func deleteBackwardsCalled() {
        self.setToPrevious()
    }
}
// Mock OTP textfield
@objc protocol MockOTPTextfieldDelegate {
    func deleteBackwardsCalled()
}

class MockOTPTextfield: UITextField {
    
    weak var delegateOfOTPBox: MockOTPTextfieldDelegate? = nil
    override func deleteBackward() {
        super.deleteBackward()
        self.delegateOfOTPBox?.deleteBackwardsCalled()
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
}



// Auto OTP Textfield of all textfield contains inside Stackview
// It contains bar, to show blinking in textfields.
class AutoOTPTextfield: UITextField {
    
    var barView: UIView = UIView.init(frame: .zero)
    var timer: Timer? = nil
    var isActive: Bool = false {
        didSet {
            if self.isActive {
                self.barView.isHidden = false
                self.timer?.invalidate()
                self.timer = nil
                self.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (timer) in
                    //print("timer running up for index: \(self.tag)")
                    self.barView.isHidden = !self.barView.isHidden
                })
            }else{
                self.barView.isHidden = true
                self.timer?.invalidate()
                self.timer = nil
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initSetup()
    }
    
    func initSetup() {
        self.barView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.barView)
        self.barView.isHidden = true
        self.barView.alpha = 0.6
        self.barView.backgroundColor = UIColor.blue//UIColor.init(red: 0/255, green: 135/255, blue: 246/255, alpha: 1.0)
        self.barView.addConstraint(NSLayoutConstraint.init(item: self.barView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 2))
        self.barView.addConstraint(NSLayoutConstraint.init(item: self.barView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 17.2))
        self.addConstraint(NSLayoutConstraint.init(item: self.barView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint.init(item: self.barView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: -1))
    }
    
    
}
