//
//  ExpandableTextViewWIthErrorAtBottom.swift
//  ExpandableUITextView
//
//  Created by smartsense-kiran on 01/09/21.
//

import UIKit

class ExpandableTextViewWIthErrorAtBottom: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var stackViewToHoldExpandableViewAndErrorAtBottom: UIStackView? = nil
    var titleLabel: UILabel? = nil
    var expandableTextView: ExpandableUITextView? = nil
    var labelOfError: UILabel? = nil
    
    var locationTapped: (()->())? = nil
//    let imageRightIconEnabled = UIImage.init(named: "imgLocationBlue")!
    let imageRightIconEnabled = UIImage.init(named: "imgLocationBlue")!
    let imageRightIconDisabled = UIImage.init(named: "imgLocationBlue")!.withRenderingMode(.alwaysTemplate)
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if stackViewToHoldExpandableViewAndErrorAtBottom == nil {
            self.initSetUp()
        }else if expandableTextView == nil {
            self.initSetUp()
        }
    }
    
    func initSetUp() {
        // Stack View
        let stackView = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.fill
        stackView.alignment = UIStackView.Alignment.leading
        stackView.spacing   = 4.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        stackView.addSurroundingZero(isSuperView: self)
        self.stackViewToHoldExpandableViewAndErrorAtBottom = stackView
        
        // Error Label
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.font = UIFont.Poppins.medium(11.3)
        titleLabel.textColor = UIColor.blueHeadingAlpha60
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(titleLabel)
        titleLabel.numberOfLines = 1
        self.titleLabel = titleLabel
        
        // Expandable Text View
        let expandableTextView = ExpandableUITextView.init(frame: .zero)
        expandableTextView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(expandableTextView)
        expandableTextView.addLeft(isSuperView: self, constant: 0)
        expandableTextView.addRight(isSuperView: self, constant: 0)
        expandableTextView.setPlaceholder(withText: "Select Location", usingFont: UIFont.Poppins.medium(15))
        
        expandableTextView.setRightIcon(imageRightIconEnabled.withTintColor(.blueHeading)) {
            debugPrint("Right icon tapped!")
            self.locationTapped?()
        }
        expandableTextView.active = false
        expandableTextView.font = UIFont.Poppins.medium(15)
        expandableTextView.textDidChange = {
            self.dismissError()
        }
        self.expandableTextView = expandableTextView
        
        // Error Label
        let errorLabel = UILabel.init(frame: .zero)
        errorLabel.font = UIFont.Poppins.regular(11)
        errorLabel.textColor = UIColor.red
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(errorLabel)
        errorLabel.numberOfLines = 2
        self.labelOfError = errorLabel
    }
    
    func showTitle(withValue value: String) {
        self.titleLabel?.text = value
        self.titleLabel?.isHidden = false
    }
    func showError(withMessage message: String) {
        self.labelOfError?.text = message
        self.labelOfError?.isHidden = false
        self.expandableTextView?.borderWidth = 1
        self.expandableTextView?.borderColor = .red
    }
    
    func dismissError() {
        self.labelOfError?.isHidden = true
        self.expandableTextView?.borderWidth = 0
    }
    
    func showDisabledEnabled(isDisabled: Bool) {
        func workOnEnableDisable() {
            if isDisabled {
                self.isUserInteractionEnabled = false
                self.alpha = 0.8
                self.expandableTextView?.textColor = UIColor.blueHeadingAlpha40
                self.expandableTextView?.setRightIcon(imageRightIconDisabled.withTintColor(.blueHeadingAlpha40)) {
                    debugPrint("Right icon tapped!")
                }
            } else {
                self.isUserInteractionEnabled = true
                self.alpha = 1.0
                self.expandableTextView?.textColor = UIColor.blueHeading
                self.expandableTextView?.setRightIcon(imageRightIconEnabled) {
                    debugPrint("Right icon tapped!")
                    self.locationTapped?()
                }
            }
        }
        if stackViewToHoldExpandableViewAndErrorAtBottom == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                workOnEnableDisable()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                workOnEnableDisable()
            }
        }
    }

    func showDashedBorder () {
        func workOnShowBorder() {
            let color = UIColor(red: 43/255, green: 55/255, blue: 79/255, alpha: 0.2)
            self.expandableTextView?.addDashedBorder(color: color)
        }
        if stackViewToHoldExpandableViewAndErrorAtBottom == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                workOnShowBorder()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                workOnShowBorder()
            }
        }
    }
    
    func removeDashedBorder() {
        func workOnRemoveBorder() {
            self.expandableTextView?.layer.sublayers?.removeAll(where: { (layer) -> Bool in
                layer.accessibilityLabel == "addDashedBorder"
            })
        }
        if stackViewToHoldExpandableViewAndErrorAtBottom == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                workOnRemoveBorder()
            }
        } else {
            workOnRemoveBorder()
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension ExpandableTextViewWIthErrorAtBottom {
    func setPlaceholder(withText placeholderText: String,
                        usingFont font: UIFont = UIFont.Poppins.mediumItalic(11.3),
                        andColor color: UIColor = UIColor.lightGray) {
        self.expandableTextView?.setPlaceholder(withText: placeholderText, usingFont: font, andColor: color)
    }
    func getText() -> String{
        self.expandableTextView?.getText() ?? ""
    }
    func setText(_ content: String) {
        if !content.isEmpty {
            self.dismissError()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.expandableTextView?.setText(content)
        }
    }
}
