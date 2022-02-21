//
//  GenericTextfield.swift
//  CertifID
//
//  Created by Kiran Jasvanee on 04/12/18.
//  Copyright © 2018 SmartSense. All rights reserved.
//

import UIKit

@IBDesignable class GenericTextfield: UITextField, ErrorControlHandler {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSetup()
    }
    
    var isAutocapitalizationType:Bool = true{
        didSet{
            if isAutocapitalizationType{
                self.autocapitalizationType = .sentences
            }else{
                self.autocapitalizationType = .none
            }
        }
    }
    
    func initSetup(){
        isAutocapitalizationType = true
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "",
                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "blueHeading")!])
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleTextFieldEnd), name: UITextField.textDidEndEditingNotification, object: nil)
        
    }
    
    @objc func handleTextFieldEnd() {
        self.trimSpace()
    }
    
    @IBInspectable public var leadingGap: CGFloat = 17.0
    @IBInspectable public var trailingGap: CGFloat = 17.0
    
    func leadingPadding(_ value: Int){
        self.leadingGap = CGFloat(value)
    }
    func rightPadding(_ value: Int) {
        self.trailingGap = CGFloat(value)
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    // TODO: find aleternet of this
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        let padding = UIEdgeInsets(top: 0, left: leadingGap, bottom: 0, right: trailingGap)
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let padding = UIEdgeInsets(top: 0, left: leadingGap, bottom: 0, right: trailingGap)
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        let padding = UIEdgeInsets(top: 0, left: leadingGap, bottom: 0, right: trailingGap)
        return bounds.inset(by: padding)
    }
    
    // Error
    var isShowError: Bool = false {
        didSet {
            self.showError()
        }
    }
    func showError() {
        if isShowError {
            self.borderColor = .red
            self.borderWidth = 1.0
        }else{
            self.borderWidth = 0.0
        }
    }
    
    var isShowDoneToolbar: Bool = false {
        didSet {
            self.addToolBar()
        }
    }
    var isShowCancelButton = false
    
    func addToolBar() {
        let numberToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        numberToolbar.barStyle = .default
        numberToolbar.items = [
            //                        UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelNumberPad)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: cueAlert.Button.done, style: .plain, target: self, action: #selector(self.doneWithNumberPad))]
        if isShowCancelButton{
            numberToolbar.items?.insert(UIBarButtonItem(title: cueAlert.Button.cancel, style: .plain, target: self, action: #selector(self.cancelNumberPad)), at: 0)
        }
        numberToolbar.sizeToFit()
        self.inputAccessoryView = numberToolbar
    }
    
    @objc func cancelNumberPad() {
        //Cancel with number pad
        self.resignFirstResponder()
    }
    
    @objc func doneWithNumberPad() {
        //Done with number pad
        self.resignFirstResponder()
    }
}



