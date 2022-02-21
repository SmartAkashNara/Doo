//
//  ExpandableUITextView.swift
//  ExpandableUITextView
//
//  Created by smartsense-kiran on 01/09/21.
//

import UIKit

class ExpandableUITextView: UITextView {
    
    // outlet var
    var placeHolderLabel: UILabel!
    var rightButtonIcon: UIButton!
    var rightButtonTapClosure: (()->())? = nil
    var textDidChange: (()->())? = nil
    var textviewHeightConstraint: NSLayoutConstraint!
    // helping properties
    private let maxHeight: CGFloat = 90
    private let minHeight: CGFloat = 45.3
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initSetUp()
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.initSetUp()
    }
    
    func initSetUp() {
         self.textContainerInset = UIEdgeInsets.init(top: 10, left: 12, bottom: 0, right: 14) // Content area... to type in textview.
        self.text = "" // default blank
        self.contentInset = UIEdgeInsets.init(top: 5, left: 0, bottom: 5, right: 0) // place holder position... to place subviews after keeping gap of 6 at top.
        self.layer.cornerRadius = 6.0
        self.clipsToBounds = true
        self.tag = 30  // for distance from keyboard.
        
        // Other tasks
        self.addHeightConstraintToTextView()
        self.addPlaceholderTextField()
        self.registerObservers()
        self.addToolBar()
    }
    
    func addToolBar() {
        let numberToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        numberToolbar.barStyle = .default
        numberToolbar.items = [
            // UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelNumberPad)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: cueAlert.Button.done, style: .plain, target: self, action: #selector(self.doneWithNumberPad))]
        numberToolbar.sizeToFit()
        self.inputAccessoryView = numberToolbar
    }
    
    @objc func doneWithNumberPad() {
        //Done with number pad
        self.resignFirstResponder()
    }
    
    func addHeightConstraintToTextView() {
        self.textviewHeightConstraint = NSLayoutConstraint.init(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.minHeight)
        self.addConstraint(self.textviewHeightConstraint)
    }
    
    func registerObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(textViewDidChangeWithNotification(_:)),
                        name: UITextView.textDidChangeNotification,
                        object: nil
                )
        NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(textViewDidBeginWithNotification(_:)),
                        name: UITextView.textDidBeginEditingNotification,
                        object: nil
                )
        NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(textViewDidEndWithNotification(_:)),
                        name: UITextView.textDidEndEditingNotification,
                        object: nil
                )
    }
    deinit {
        NotificationCenter.default.removeObserver(self) // will going to remove all observer...
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    func getText() -> String{
        self.text
    }
    func setText(_ content: String) {
        self.text = content
        self.setHeightOfTextViewAccordingToContent()
        if !content.isEmpty {
            self.textColor = UIColor.black // if content added, show text color as black.
        }
    }
    var active: Bool = false {
        didSet {
            if active {
                self.textColor = UIColor.blueSwitch
                self.tintColor = UIColor.blueSwitch
                self.backgroundColor = UIColor.blueSwitchAlpha10
            } else {
                if self.text.isEmpty {
                    self.textColor = UIColor.blueHeadingAlpha60
                }else{
                    self.textColor = UIColor.black
                }
                self.tintColor = UIColor.blueHeading
                self.backgroundColor = UIColor.textFieldbackgroundColor
            }
        }
    }
}

// MARK: Add placeholder text
extension ExpandableUITextView {
    func addPlaceholderTextField() {
        self.placeHolderLabel = UILabel.init(frame: .zero)
        self.placeHolderLabel.translatesAutoresizingMaskIntoConstraints = false
        self.placeHolderLabel.text = ""
        self.addSubview(self.placeHolderLabel!)
        self.addConstraint(NSLayoutConstraint.init(item: self.placeHolderLabel!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: -6))
        self.addConstraint(NSLayoutConstraint.init(item: self.placeHolderLabel!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 16))
        self.addConstraint(NSLayoutConstraint.init(item: self.placeHolderLabel!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 20))
    }
    func setPlaceholder(withText placeholderText: String,
                        usingFont font: UIFont = UIFont.Poppins.medium(11.3),
                        andColor color: UIColor = UIColor.lightGray.withAlphaComponent(0.9)) {
        self.placeHolderLabel.text = placeholderText
        self.placeHolderLabel.font = font
        self.placeHolderLabel.textColor = color
    }
}

// MARK: Add placeholder text
extension ExpandableUITextView {
    func addRightButtonIcon() {
        self.rightButtonIcon = UIButton.init(frame: .zero)
        self.addSubview(self.rightButtonIcon!)
        self.rightButtonIcon.translatesAutoresizingMaskIntoConstraints = false
        self.rightButtonIcon.addTop(isSuperView: self, constant: 0)
        self.rightButtonIcon.addBottom(isSuperView: self, constant: 0)
        self.rightButtonIcon.addRight(isSuperView: self, constant: 0)
        self.rightButtonIcon.addWidth(constant: 40)
        self.rightButtonIcon.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 8)
        self.rightButtonIcon.addTarget(self, action: #selector(self.rightIconTapped(sender:)), for: .touchUpInside)
    }
    @objc func rightIconTapped(sender: UIButton) {
        self.rightButtonTapClosure?()
    }
    func setRightIcon(_ rightIcon: UIImage, onTap: (()->())? = nil) {
        self.textContainerInset = UIEdgeInsets.init(top: 8, left: 14, bottom: 0, right: 40) // Content area... to type in
        self.addRightButtonIcon()
        self.rightButtonIcon.setImage(rightIcon, for: .normal)
        self.rightButtonTapClosure = onTap
    }
}

// MARK: Observers
extension ExpandableUITextView {
    @objc
    private func keyboardWillShow(_ sender: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    @objc
    private func keyboardWillHide(_ sender: Notification) {
        self.layoutIfNeeded()
    }
    @objc private func textViewDidBeginWithNotification(_ notification: Notification) {
        self.active = true
    }
    @objc private func textViewDidChangeWithNotification(_ notification: Notification) {
        self.setHeightOfTextViewAccordingToContent()
        self.textDidChange?()
    }
    @objc private func textViewDidEndWithNotification(_ notification: Notification) {
        self.active = false
    }
    func setHeightOfTextViewAccordingToContent() {
        // print("Text: \(String(describing: self.text))")
        var height = self.minHeight
        
        if self.contentSize.height <= self.minHeight {
            height = self.minHeight
        } else if self.contentSize.height >= self.maxHeight {
            height = self.maxHeight
        } else {
            height = self.contentSize.height
        }
        
        self.placeHolderLabel.isHidden = !self.text.isEmpty
        self.textviewHeightConstraint.constant = height
        self.layoutIfNeeded()
    }
}

