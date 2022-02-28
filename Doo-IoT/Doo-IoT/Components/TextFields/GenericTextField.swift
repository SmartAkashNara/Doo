//
//  GenericTextfield.swift
//  CertifID
//
//  Created by Kiran Jasvanee on 04/12/18.
//  Copyright © 2018 SmartSense. All rights reserved.
//

import UIKit

class DooTextfieldView: UIView {
    
    private var heightConstraintOfView: NSLayoutConstraint? = nil
    private var heightOfTextfield: CGFloat = 0.0
    
    enum TextfieldType {
        case generic, rightIcon, password
    }
    var titleValue: String = ""
    var titleColor: UIColor? = nil
    var textfieldType: TextfieldType = .generic {
        didSet {
            self.initSetup()
        }
    }
    
    private var titleLabel: UILabel? = nil
    var genericTextfield: GenericTextField? = nil
    var rightIconTextfield: RightIconTextField? = nil
    var passwordTextfield: EyePasswordTextField? = nil
    private var errorLabel: UILabel = UILabel.init(frame: .zero)
    var validateTextForError: ((String?) -> (String?))? = nil
    
    var disabled: Bool = false {
        didSet {
            titleLabel?.alpha = disabled ? 0.7 : 1.0
            if genericTextfield != nil {
                genericTextfield?.disabled = disabled
            } else if rightIconTextfield != nil {
                rightIconTextfield?.disabled = disabled
            } else if passwordTextfield != nil {
                passwordTextfield?.disabled = disabled
            }
        }
    }
    
    func disabledIfNonEmpty() {
        if let getTextStrong = getText, !getTextStrong.isEmpty {
            disabled = true
        }
    }

    var activeBehaviour: Bool = false {
        didSet {
            if activeBehaviour {
                if genericTextfield != nil {
                    genericTextfield?.addAction(for: .editingDidBegin) {
                        self.active = true
                        self.genericTextfield?.active = true
                    }
                    genericTextfield?.addAction(for: .editingDidEnd) {
                        self.active = false
                        self.genericTextfield?.active = false
                    }
                } else if rightIconTextfield != nil {
                    rightIconTextfield?.addAction(for: .editingDidBegin) {
                        self.active = true
                        self.rightIconTextfield?.active = true
                    }
                    rightIconTextfield?.addAction(for: .editingDidEnd) {
                        self.active = false
                        self.rightIconTextfield?.active = false
                    }
                } else if passwordTextfield != nil {
                    passwordTextfield?.addAction(for: .editingDidBegin) {
                        self.active = true
                        self.passwordTextfield?.active = true
                    }
                    passwordTextfield?.addAction(for: .editingDidEnd) {
                        self.active = false
                        self.passwordTextfield?.active = false
                    }
                }
            }
        }
    }
    
    var active: Bool = false {
        didSet {
            if active {
                titleLabel?.textColor = UIColor.blueSwitch
            } else {
                titleLabel?.textColor = UIColor.blueHeadingAlpha60
            }
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func initSetup() {
        self.getHeightConstraintOfTextfield()
        
        var activeTextfield: GenericTextField!
        func addTextfield(_ textfield: GenericTextField) {
            activeTextfield = textfield
            self.addSubview(textfield)
            
            if !self.titleValue.isEmpty{
                self.titleLabel = UILabel.init(frame: .zero)
                self.titleLabel?.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview(self.titleLabel!)
                self.titleLabel?.text = self.titleValue
                self.titleLabel?.textColor = (self.titleColor != nil) ? self.titleColor : UIColor.textfieldTitleColor
                self.titleLabel?.font = UIFont.Poppins.medium(11.3)
                self.titleLabel?.addTop(isSuperView: self, constant: 0)
                self.titleLabel?.addLeft(isSuperView: self, constant: 0)
                self.titleLabel?.addRight(isSuperView: self, constant: 0)
                // self.titleLabel?.backgroundColor = .yellow
                textfield.addTop(isRelateTo: self.titleLabel!, isSuperView: self, constant: 6)
            }else{
                textfield.addTop(isSuperView: self, constant: 0)
            }
            
            textfield.addLeft(isSuperView: self, constant: 0)
            textfield.addRight(isSuperView: self, constant: 0)
            textfield.addHeight(constant: Double(44))
            textfield.addTarget(self, action: #selector(self.editingDidBegin(sender:)), for: .editingDidBegin)
        }
       
        switch self.textfieldType {
        case .rightIcon:
            self.rightIconTextfield = RightIconTextField.init(frame: .zero)
            self.rightIconTextfield?.translatesAutoresizingMaskIntoConstraints = false
            addTextfield(self.rightIconTextfield!)
        case .password:
            self.passwordTextfield = EyePasswordTextField.init(frame: .zero)
            self.passwordTextfield?.translatesAutoresizingMaskIntoConstraints = false
            addTextfield(self.passwordTextfield!)
        default:
            self.genericTextfield = GenericTextField.init(frame: .zero)
            self.genericTextfield?.translatesAutoresizingMaskIntoConstraints = false
            self.genericTextfield?.font = UIFont.Poppins.medium(11.3)
            addTextfield(self.genericTextfield!)
        }
        
        self.errorLabel.font = UIFont.Poppins.regular(11)
        self.errorLabel.textColor = UIColor.textFieldErrorColor
        self.errorLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.errorLabel)
        self.errorLabel.addTop(isRelateTo: activeTextfield, isSuperView: self, constant: 4)
        self.errorLabel.addLeft(isSuperView: self, constant: 0)
        self.errorLabel.addRight(isSuperView: self, constant: 0)
        self.errorLabel.numberOfLines = 2
    }
    
    @objc func editingDidBegin(sender: UITextField) {
        self.dismissError()
    }
    
    func getHeightConstraintOfTextfield() {
        for constraint in self.constraints {
            if constraint.firstAttribute == .height {
                self.heightConstraintOfView = constraint
                self.heightOfTextfield = constraint.constant
            }
        }
    }
    
    func getActiveTextfield() -> GenericTextField?{
        if let activeTextfield = self.genericTextfield {
            return activeTextfield
        }else if let activeTextfield = self.rightIconTextfield {
            return activeTextfield
        }else if let activeTextfield = self.passwordTextfield {
            return activeTextfield
        }
        return nil
    }
    
    
    var setText: String = "" {
        didSet {
            switch self.textfieldType {
            case .rightIcon:
                self.rightIconTextfield?.text = setText
            case .password:
                self.passwordTextfield?.text = setText
            default:
                self.genericTextfield?.text = setText
            }
            self.dismissError()
        }
    }

    var getText: String? {
        switch self.textfieldType {
        case .rightIcon:
            return self.rightIconTextfield?.text
        case .password:
            return self.passwordTextfield?.text
        default:
            return self.genericTextfield?.text
        }
    }
    
    var setKeyboardType: UIKeyboardType = . default {
        didSet {
            switch self.textfieldType {
            case .rightIcon:
                self.rightIconTextfield?.keyboardType = setKeyboardType
            case .password:
                self.passwordTextfield?.keyboardType = setKeyboardType
            default:
                self.genericTextfield?.keyboardType = setKeyboardType
            }
            self.dismissError()
        }
    }
    
    var setReturnKeyType: UIReturnKeyType = .done{
        didSet {
            switch self.textfieldType {
            case .rightIcon:
                self.rightIconTextfield?.returnKeyType = setReturnKeyType
            case .password:
                self.passwordTextfield?.returnKeyType = setReturnKeyType
            default:
                self.genericTextfield?.returnKeyType = setReturnKeyType
            }
            self.dismissError()
        }
    }
}

// MARK: Error related work
extension DooTextfieldView {
    
    func isValidated() -> Bool {
        guard let currentTextfield = self.getActiveTextfield() else{
            return false
        }
        if let errorString = self.validateTextForError?(self.getActiveTextfield()?.text ?? "") {
            if !errorString.isEmpty {
                self.showError(errorString) // Show error now.
                currentTextfield.isShowError = true
                return false
            }else{
                currentTextfield.isShowError = false
                return true
            }
        }
        return true
    }
    
    func showError(_ errorMessage: String = localizeFor("something_went_wrong")) {
        
        let height = errorMessage.height(withConstrainedWidth: self.errorLabel.bounds.size.width, font: self.errorLabel.font)
        self.errorLabel.text = errorMessage
        self.heightConstraintOfView?.constant = (self.heightOfTextfield + height)
        self.getActiveTextfield()?.isShowError = true
    }
    func dismissError() {
        self.errorLabel.text = ""
        self.heightConstraintOfView?.constant = self.heightOfTextfield
        self.getActiveTextfield()?.isShowError = false
    }
}

@IBDesignable class GenericTextField: UITextField, ErrorControlHandler {

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

    var disabled: Bool = false {
        didSet {
            if disabled {
                self.isUserInteractionEnabled = false
                self.alpha = 0.8
                self.textColor = UIColor.blueHeadingAlpha40
                self.addDashedBorder(color: UIColor(red: 43/255, green: 55/255, blue: 79/255, alpha: 0.2))
            } else {
                self.isUserInteractionEnabled = true
                self.alpha = 1.0
                self.textColor = UIColor.blueHeading
                layer.sublayers?.removeAll(where: { (layer) -> Bool in
                    layer.accessibilityLabel == "addDashedBorder"
                })
            }
        }
    }

    var activeBehaviour: Bool = false {
        didSet {
            if activeBehaviour {
                self.addAction(for: .editingDidBegin) {
                    self.active = true
                }
                self.addAction(for: .editingDidEnd) {
                    self.active = false
                }
            }
        }
    }
    
    var active: Bool = false {
        didSet {
            if active {
                textColor = UIColor.blueSwitch
                tintColor = UIColor.blueSwitch
                backgroundColor = UIColor.blueSwitchAlpha10
            } else {
                textColor = UIColor.blueHeading
                tintColor = UIColor.blueHeading
                backgroundColor = UIColor.blueHeadingAlpha06
            }
        }
    }
    
    func initSetup(){
        isAutocapitalizationType = true
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "",
                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleTextFieldEnd), name: UITextField.textDidEndEditingNotification, object: nil)
        self.font = UIFont.Poppins.medium(11.3)
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
            // UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelNumberPad)),
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



