//
//  ProfileInfoGenericTextField.swift
//  CertifID
//
//  Created by Kiran Jasvanee on 18/12/18.
//  Copyright © 2018 SmartSense. All rights reserved.
//

import UIKit

@objc protocol ProfileInfoGenericTextFieldDelegate {
    func navigationTapped()
}

class ProfileInfoGenericTextField: RightIconTextField {
    
    weak var profileInfoGenericDelegate: ProfileInfoGenericTextFieldDelegate? = nil
    
    var errorLabel: UILabel? = nil
    
    
    var isPaste:Bool = true
    var isCursor:Bool = true {
        didSet{
            if !isCursor { self.tintColor = UIColor.clear }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.inSetup()
    }
    
    
    func inSetup() {
        
        self.errorLabel = UILabel.init(frame: .zero)
        
        guard let errorLabel = self.errorLabel else{
            return
        }
        
        isAutocapitalizationType = true
        self.textColor = UIColor(named:"blueHeading")!
        self.font = UIFont.Poppings.Medium(14)
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "",
                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor(named:"blueHeading")!])
        
        
        
        //        self.addAction(for: .editingDidBegin) { [weak self] in
        //            UIView.animate(withDuration: 0.1, animations: { [weak self] in
        //                self?.dismissError()
        //                bottomLine.backgroundColor = UIColor.Custom.appColor
        //                titleLabel.textColor = UIColor.Custom.appColor
        //                self?.superview?.layoutIfNeeded()
        //            })
        //        }
        //
        //        self.addAction(for: .editingDidEnd) { [weak self] in
        //            self?.trimSpace()
        //            UIView.animate(withDuration: 0.1, animations: { [weak self] in
        //                bottomLine.backgroundColor = UIColor.Custom.searchUnderlineColor
        //                titleLabel.textColor = UIColor.Custom.searchBarPlaceHolderColor
        //                self?.superview?.layoutIfNeeded()
        //            })
        //        }
        
        // @objc set left padding to 0
        self.leadingGap = 10
        self.trailingGap = 0
        
        //
        self.widthConstraintOfRightIcon.constant = 28
        
        // add title label
        
        
//        let stackViewErrorWithBottomRightButton = UIStackView()
        addSubview(errorLabel)
        errorLabel.addBottom(isSuperView: self, constant: 10)
        errorLabel.addRight(isSuperView: self, constant: 0)
        errorLabel.addLeft(isSuperView: self, constant: 0)
        
//        stackViewErrorWithBottomRightButton.translatesAutoresizingMaskIntoConstraints = false
//        stackViewErrorWithBottomRightButton.addArrangedSubview(errorLabel)
//        stackViewErrorWithBottomRightButton.axis = .horizontal
//        stackViewErrorWithBottomRightButton.alignment = .top
//        stackViewErrorWithBottomRightButton.distribution = .fillProportionally
//        stackViewErrorWithBottomRightButton.spacing = 10
//        stackViewErrorWithBottomRightButton.addBottom(isSuperView: self, constant: 31)
//        stackViewErrorWithBottomRightButton.addRight(isSuperView: self, constant: 0)
//        stackViewErrorWithBottomRightButton.addLeft(isSuperView: self, constant: 0)
//
        errorLabel.font = UIFont.Poppings.Regular(10)
        errorLabel.textColor = UIColor.red
        errorLabel.numberOfLines = 2
        errorLabel.textAlignment = .left
    }
    
    // Delete case --------------------------------------------------------------
    @objc func navigationPurposeAction(sender: UIButton) {
        self.profileInfoGenericDelegate?.navigationTapped()
    }
    
    
    // Textfield --------------------------------------------------------------
    @objc func handleTextFieldBegin() {
        self.dismissError()
    }
    
    
    var setPlaceholder: String = "" {
        didSet {
            self.attributedPlaceholder = NSAttributedString(string: self.setPlaceholder,
                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor(named:"blueHeading")!])
        }
    }
    
    func setLeft0AndBottomSpaceLow() {
        self.leadingGap = 0
    }
    
    
    var navigationClosure: (()->())? = nil
    func setThisObjectForNavigationPurposeWith(navigation: @escaping ()->()) {
        self.navigationClosure = navigation
        
        for subview in self.subviews {
            subview.isUserInteractionEnabled = false
        }
        
        let tapgesture = UITapGestureRecognizer.init(target: self, action: #selector(self.navigationPurposeAction(gesture:)))
        self.addGestureRecognizer(tapgesture)
    }
    @objc func navigationPurposeAction(gesture: UITapGestureRecognizer) {
        self.dismissError()
        self.navigationClosure?()
    }
    
    
    override func setRightIconImage() {
        super.setRightIconImage()
        
        // you will get the indication when right icon will get set.
        self.trailingGap = 40
    }
    
    func showError(content: String) {
        self.errorLabel?.text = content
    }
    func dismissError() {
        self.errorLabel?.text = ""
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return isPaste
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

