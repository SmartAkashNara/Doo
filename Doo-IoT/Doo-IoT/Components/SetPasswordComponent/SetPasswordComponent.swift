//
//  SetPasswordComponent.swift
//  CertifID
//
//  Created by Kiran Jasvanee on 05/12/18.
//  Copyright © 2018 SmartSense. All rights reserved.
//

import UIKit

@objc protocol PaginationBarDataSource {
    @objc func numberOfBars() -> Int
    @objc func spaceOfSides() -> Int
}

@objc protocol PaginationBarDelegate {
    @objc func didSwipedToIndex(index: Int)
}

@objc protocol SetPasswordComponentDelegate {
    func didPasswordValidated()
    func didPasswordInValidated()
}

class SetPasswordComponent: UIView {
    
    // set password
    let ON_TICK: UIImage = #imageLiteral(resourceName: "tick")
    let OFF_TICK: UIImage = #imageLiteral(resourceName: "tickGray")

    static let viewHeightWithoutList: CGFloat = 70
    static let viewHeight: CGFloat = 220

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
        self.initSetUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
        self.initSetUp()
    }
    
    // Performs the initial setup.
    private func setupView() {
        let view = viewFromNibForClass()
        view.frame = bounds
        
        // Auto-layout stuff.
        view.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight
        ]
        
        // Show the view.
        addSubview(view)
    }
    
    // Loads a XIB file into a view and returns this view.
    private func viewFromNibForClass() -> UIView {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        /* Usage for swift < 3.x
         let bundle = NSBundle(forClass: self.dynamicType)
         let nib = UINib(nibName: String(self.dynamicType), bundle: bundle)
         let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
         */
        
        return view
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    
    weak var delegate: SetPasswordComponentDelegate? = nil
    var heightConstraintOfSelf: NSLayoutConstraint? = nil
    
    func initSetUp()  {
        
        // get height constraint of self.
        for constraint in self.constraints {
            if constraint.firstAttribute == .height {
                self.heightConstraintOfSelf = constraint
            }
        }
        
        self.clipsToBounds = true
        self.setDefaultContent()
        loadComponentDefaultState()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard(_ gesture: UITapGestureRecognizer) {
        self.endEditing(true)
    }
    
    func setDefaultContent() {
        self.labelIncludeFirstUppercase.text = localizeFor("include_1_upper_case_letter")
        self.labelIncludeFirstLowercase.text = localizeFor("include_1_lowercase_letter")
        self.labelIncludeOneNumeric.text = localizeFor("include_1_numeric_letter")
        self.labelIncludeOneSpecialCharacters.text = localizeFor("1_special_character")
        self.label8CharactersOrMore.text = localizeFor("8_characters_or_more")
    }
    
    func loadComponentDefaultState(){
        self.checkMarkIncludeFirstUppercase.image = OFF_TICK
        self.labelIncludeFirstUppercase.textColor = UIColor.blueHeadingAlpha40

        self.checkMarkIncludeFirstLowercase.image = OFF_TICK
        self.labelIncludeFirstLowercase.textColor = UIColor.blueHeadingAlpha40

        self.checkMarkIncludeOneNumeric.image = OFF_TICK
        self.labelIncludeOneNumeric.textColor = UIColor.blueHeadingAlpha40

        self.checkMarkOneSpecialCharacters.image = OFF_TICK
        self.labelIncludeOneSpecialCharacters.textColor = UIColor.blueHeadingAlpha40

        self.checkMark8CharactersOrMore.image = OFF_TICK
        self.label8CharactersOrMore.textColor = UIColor.blueHeadingAlpha40
    }

    private var isPasswordValidHolder = false
    var isPasswordValid = false {
        didSet {
            guard self.isPasswordValidHolder != self.isPasswordValid else { return }
            self.isPasswordValidHolder = self.isPasswordValid
        }
    }
    
    // set password and colors
    @IBOutlet weak var checkMark8CharactersOrMore: UIImageView!
    @IBOutlet weak var label8CharactersOrMore: UILabel!
    private var is8CharactersOrLessHolder = false
    var is8CharactersOrLess = false {
        didSet {
            guard self.is8CharactersOrLessHolder != self.is8CharactersOrLess else { return }
            if self.is8CharactersOrLess {
                self.checkMark8CharactersOrMore.image = ON_TICK
                self.label8CharactersOrMore.textColor = UIColor.greenOnline
            }else{
                self.checkMark8CharactersOrMore.image = OFF_TICK
                self.label8CharactersOrMore.textColor = UIColor.blueHeadingAlpha40
            }
            self.is8CharactersOrLessHolder = self.is8CharactersOrLess
            checkIsPasswordValid()
        }
    }
    
    @IBOutlet weak var checkMarkIncludeFirstUppercase: UIImageView!
    @IBOutlet weak var labelIncludeFirstUppercase: UILabel!
    private var isIncludedOneUppercaseHolder = false
    var isIncludedOneUppercase = false {
        didSet {
            guard self.isIncludedOneUppercaseHolder != self.isIncludedOneUppercase else { return }
            if self.isIncludedOneUppercase {
                self.checkMarkIncludeFirstUppercase.image = ON_TICK
                self.labelIncludeFirstUppercase.textColor = UIColor.greenOnline
            }else{
                self.checkMarkIncludeFirstUppercase.image = OFF_TICK
                self.labelIncludeFirstUppercase.textColor = UIColor.blueHeadingAlpha40
            }
            self.isIncludedOneUppercaseHolder = self.isIncludedOneUppercase
            checkIsPasswordValid()
        }
    }
    
    @IBOutlet weak var checkMarkIncludeFirstLowercase: UIImageView!
    @IBOutlet weak var labelIncludeFirstLowercase: UILabel!
    private var isIncludeOneLowercaseHolder = false
    var isIncludeOneLowercase = false {
        didSet {
            guard self.isIncludeOneLowercaseHolder != self.isIncludeOneLowercase else { return }
            if self.isIncludeOneLowercase {
                self.checkMarkIncludeFirstLowercase.image = ON_TICK
                self.labelIncludeFirstLowercase.textColor = UIColor.greenOnline
            }else{
                self.checkMarkIncludeFirstLowercase.image = OFF_TICK
                self.labelIncludeFirstLowercase.textColor = UIColor.blueHeadingAlpha40
            }
            self.isIncludeOneLowercaseHolder = self.isIncludeOneLowercase
            checkIsPasswordValid()
        }
    }
    
    @IBOutlet weak var checkMarkOneSpecialCharacters: UIImageView!
    @IBOutlet weak var labelIncludeOneSpecialCharacters: UILabel!
    private var isIncludeOneSpecialCharactersHolder = false
    var isIncludeOneSpecialCharacters = false {
        didSet {
            guard self.isIncludeOneSpecialCharactersHolder != self.isIncludeOneSpecialCharacters else { return }
            if self.isIncludeOneSpecialCharacters {
                self.checkMarkOneSpecialCharacters.image = ON_TICK
                self.labelIncludeOneSpecialCharacters.textColor = UIColor.greenOnline
            }else{
                self.checkMarkOneSpecialCharacters.image = OFF_TICK
                self.labelIncludeOneSpecialCharacters.textColor = UIColor.blueHeadingAlpha40
            }
            self.isIncludeOneSpecialCharactersHolder = self.isIncludeOneSpecialCharacters
            checkIsPasswordValid()
        }
    }
    
    @IBOutlet weak var checkMarkIncludeOneNumeric: UIImageView!
    @IBOutlet weak var labelIncludeOneNumeric: UILabel!
    private var isIncludeOneNumericHolder = false
    var isIncludeOneNumeric = false {
        didSet {
            guard self.isIncludeOneNumericHolder != self.isIncludeOneNumeric else { return }
            if self.isIncludeOneNumeric {
                self.checkMarkIncludeOneNumeric.image = ON_TICK
                self.labelIncludeOneNumeric.textColor = UIColor.greenOnline
            }else{
                self.checkMarkIncludeOneNumeric.image = OFF_TICK
                self.labelIncludeOneNumeric.textColor = UIColor.blueHeadingAlpha40
            }
            self.isIncludeOneNumericHolder = self.isIncludeOneNumeric
            checkIsPasswordValid()
        }
    }
    
    func checkIsPasswordValid() {
         isPasswordValid = isIncludeOneLowercase || isIncludeOneLowercase || isIncludeOneNumeric || isIncludeOneSpecialCharacters || is8CharactersOrLess
    }
    
    func validateComponent(text:String) {
        isIncludedOneUppercase = InputValidator.isContainsCapitalLetter(text)
        isIncludeOneLowercase = InputValidator.isContainsSmallLetter(text)
        isIncludeOneNumeric = InputValidator.isContainsNumber(text)
        isIncludeOneSpecialCharacters = InputValidator.isContainsSpecialChar(text)
        is8CharactersOrLess = InputValidator.checkLength(text, lengthTill: 8)
    }
    
    // Textfield information passwing from viewcontroller to this component
    func textFieldShouldBeginEditing(_ textField: UITextField) {
        if let textFieldString = textField.text {
            self.validateComponent(text: textFieldString)
        }
    }
    func textfieldEditingChanged(_ string: String) {
        self.validateComponent(text: string)
    }
    func validateTextfieldPasswordAndFocus(_ textField: UITextField) -> Bool {
        if let validateString = textField.text {
            self.validateComponent(text: validateString)
            if InputValidator.isPassword(validateString) {
                return true
            }else{
                return false
            }
        }
        return false
    }
}

extension SetPasswordComponent: PaginationBarDataSource {
    func numberOfBars() -> Int {
        return 5
    }
    func spaceOfSides() -> Int {
        return 0
    }
}



