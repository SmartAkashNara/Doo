//
//  RightIconTextField.swift
//  CertifID
//
//  Created by Kiran Jasvanee on 10/12/18.
//  Copyright © 2018 SmartSense. All rights reserved.
//

import UIKit

@objc protocol RightIconTextFieldDelegate {
    func rightIconTapped(textfield: RightIconTextField)
}

@IBDesignable class RightIconTextField: GenericTextfield {

    weak var delegateOfRightIconTextField: RightIconTextFieldDelegate? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setRightIcon()
        
        // associated with GenericTextField contains leading and trailing gap.
        self.trailingGap = 40
    }
    
    private var rightIconButton: UIButton!
    var widthConstraintOfRightIcon: NSLayoutConstraint!
    private func setRightIcon() {
        self.rightIconButton = UIButton.init(frame: .zero)
        self.rightIconButton.translatesAutoresizingMaskIntoConstraints = false
        self.rightIconButton.isUserInteractionEnabled = false
        self.addSubview(self.rightIconButton)
        
        // add constraints
        self.rightIconButton.addRight(isSuperView: self, constant: -0)
        self.rightIconButton.addCenterY(inSuperView: self)
        self.rightIconButton.addHeight(constant: 44)
        widthConstraintOfRightIcon = self.rightIconButton.addWidth(constant: 44)
        
//        self.rightIconButton.addAction(for: .touchUpInside) { [weak self] in
//            guard let textField = self else{
//                return
//            }
//            self?.delegateOfRightIconTextField?.rightIconTapped(textfield: textField)
//        }
    }
    
    @IBInspectable public var rightIcon: UIImage = #imageLiteral(resourceName: "imgArrowDown") {
        didSet {
            self.setRightIconImage()
        }
    }
    
    func setRightIconImage() {
        self.rightIconButton.setImage(self.rightIcon, for: .normal)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
}





@objc public protocol BirthdateTextField {
    @objc optional func addDatePicker()
    @objc func cancelBirthdate(sender: UIBarButtonItem)
    @objc func doneBirthdate(sender: UIBarButtonItem)
}
public extension BirthdateTextField where Self: UITextField {
    
    func addDatePicker() {
        let datePicker: UIDatePicker = UIDatePicker.init(frame: .zero)
        datePicker.setDate(Date(), animated: true)
        datePicker.datePickerMode = .date;
        datePicker.backgroundColor =  UIColor.white
        datePicker.tintColor = UIColor.white
//        datePicker.timeZone = TimeZone.init(secondsFromGMT: 0) //[NSTimeZone timeZoneForSecondsFromGMT:0];
        
        self.inputView = datePicker
        // set18YearValidation(datePicker)
        self.setOneDayMinusValidation(datePicker)
        self.addToolBar(datePicker)
    }
    
    
    func setOneDayMinusValidation(_ datePicker: UIDatePicker){
        var dateComponents = DateComponents()
        dateComponents.day = -1
        let maxDate = Calendar.current.date(byAdding: dateComponents, to: Date())!
        datePicker.maximumDate = maxDate
        datePicker.setDate(maxDate, animated: true)
    }
    
    func set18YearValidation(_ datePicker: UIDatePicker) {
        let gregorian: Calendar = Calendar.init(identifier: .gregorian)
        let currentDate: Date = Date()
        var components: DateComponents = DateComponents()
        
        components.year = -0
        
        guard let maxDate: Date = gregorian.date(byAdding: components, to: currentDate) else {
            return
        }
        
        components.year = -150
        guard let minDate: Date = gregorian.date(byAdding: components, to: currentDate) else{
            return
        }
        
        datePicker.maximumDate = maxDate
        datePicker.setDate(maxDate, animated: true)
        datePicker.minimumDate = minDate
    }
    
    func setMinimumDate(date: Date) {
        if let datePicker = self.inputView as? UIDatePicker {
            datePicker.minimumDate = date
        }
    }
    
    func setMaximumDate(date: Date) {
        if let datePicker = self.inputView as? UIDatePicker {
            datePicker.maximumDate = date
        }
    }
    func minimumDate() -> Date? {
        if let datePicker = self.inputView as? UIDatePicker {
            return datePicker.minimumDate
        }
        return nil
    }
    
    func addToolBar(_ datePicker: UIDatePicker) {
        let numberToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        numberToolbar.barStyle = .default
        numberToolbar.items = [
            UIBarButtonItem(title: cueAlert.Button.cancel, style: .plain, target: self, action: #selector(cancelBirthdate)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: cueAlert.Button.done, style: .plain, target: self, action: #selector(doneBirthdate))]
        numberToolbar.sizeToFit()
        numberToolbar.barTintColor = UIColor(named: "blueHeading")
        numberToolbar.tintColor = UIColor.white
        
        self.inputAccessoryView = numberToolbar
    }
    
    func cancelBirthdate(sender: UIBarButtonItem) {
        //Cancel with number pad
        self.resignFirstResponder()
    }
    func doneBirthdate(sender: UIBarButtonItem) {
        //Done with number pad
        if let datePicker = self.inputView as? UIDatePicker {
//            _ = datePicker.date.getDateInString(withFormat: .birthdayApp)
            self.resignFirstResponder()
        }
    }
}






// Other textfield inherited from RightIconTextField -------------------
@objc protocol BuildProfileBirthdateSelectionTextFieldDelegate{
    func birthdatePickerDoneTapped(date: Date, textfield: RightIconTextField)
}
@objc class BuildProfileBirthdateSelectionTextField: RightIconTextField, BirthdateTextField {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addDatePicker()
    }
    
    func cancelBirthdate(sender: UIBarButtonItem) {
        self.resignFirstResponder()
    }
    
    weak var delegateOfBirthdateSelectionTextField: BuildProfileBirthdateSelectionTextFieldDelegate? = nil
    func doneBirthdate(sender: UIBarButtonItem) {
        //Done with number pad
        if let datePicker = self.inputView as? UIDatePicker {
            self.delegateOfBirthdateSelectionTextField?.birthdatePickerDoneTapped(date: datePicker.date, textfield: self)
        }
        self.resignFirstResponder()
    }

    
    override func caretRect(for position: UITextPosition) -> CGRect {
        return .zero
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }

}


