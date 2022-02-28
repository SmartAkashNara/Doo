//
//  CountrySearchTextField.swift
//  ComponentsAndProtocols
//
//  Created by smartSense on 16/02/19.
//  Copyright © 2019 smartSense. All rights reserved.
//

import UIKit

protocol CountrySearchTextFieldDelegate {
    func leftButtonClicked(button:UIButton)
}
extension CountrySearchTextFieldDelegate {
    func leftButtonClicked(button:UIButton){}
}

class CountrySearchTextField:GenericTextField{
    
    var leftButton:UIButton!
    var delegateCountrySearchTextField:CountrySearchTextFieldDelegate? {
        didSet{
            leftButton.isEnabled = true
        }
    }
    var leftIconButtonWidth:CGFloat = 25
    var leftIconButtonTrailing:CGFloat = 0
    var leftIconButtonLeading:CGFloat = 5

    var leftIcon:UIImage! {
        didSet {
            setLeftIcon(image: leftIcon)
        }
    }
    
    var setPlaceholder:String = ""{
        didSet{
            self.attributedPlaceholder = NSAttributedString(string: setPlaceholder,
                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.blueHeadingAlpha30])
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSetup()
    }

    override func initSetup() {
        super.initSetup()
        
        borderStyle = .none
        backgroundColor = UIColor.blackAlpha3
        tintColor = UIColor.blueHeading
        textColor = UIColor.blueHeading
        font = UIFont.Poppins.medium(14)
        clearButtonMode = .whileEditing
        layer.cornerRadius = 7
        returnKeyType = .search

        leftIcon = cueImage.Signup.imgSearchGray
//        leftButton.imageView?.contentMode = .center
        setPlaceholder = localizeFor("search_country_placeholder")
    }

    private func setLeftIcon(image:UIImage) {
        /// Configure Constraints
        leftButton = UIButton(frame: .zero)
        leftButton.tag = self.tag
        leftButton.isEnabled = false
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leftButton)
        leftButton.addLeft(isSuperView: self, constant: Float(leftIconButtonLeading))
        leftButton.addTop(isSuperView: self, constant: 0)
        leftButton.addBottom(isSuperView: self, constant: 0)
        leftButton.addWidth(constant: Double(leftIconButtonWidth))
        
        leadingGap = leftIconButtonLeading + leftIconButtonWidth + leftIconButtonTrailing
        
        /// Configure Attributes
        leftButton.setImage(image, for: .normal)
        leftButton.addAction(for: .touchUpInside) {
            self.delegateCountrySearchTextField?.leftButtonClicked(button: self.leftButton)
        }
    }
    
}
