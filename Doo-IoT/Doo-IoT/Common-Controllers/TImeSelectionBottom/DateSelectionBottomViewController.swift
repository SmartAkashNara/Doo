//
//  DateSelectionBottomViewController.swift
//  Doo-IoT
//
//  Created by Akash on 16/08/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation
class DateSelectionBottomViewController: UIViewController {
    
    
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var viewFirstTimeSelection: UIView!
    @IBOutlet weak var viewSecondTimeSelection: UIView!
    @IBOutlet weak var labelDateTitleSelection: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var constraintBottomTableView: NSLayoutConstraint!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var mainView: UIView!

    
    var timeSelected: ((Date, Date?) -> ())? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setDefault()
    }
    
    func setDefault() {
        
        self.mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.mainView.layer.cornerRadius = 10.0

        // remove view when blank area gonna be tapped.
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.dismissViewTapGesture(tapGesture:)))
        backgroundView.addGestureRecognizer(tapGesture)

        labelDateTitleSelection.font = UIFont.Poppins.medium(11.3)
        labelDateTitleSelection.textColor = UIColor.blueHeadingAlpha60
        
        buttonSave.setThemeAppBlue(localizeFor("save_button"))
        buttonSave.cornerRadius = 16.7
        buttonCancel.setLightThemeAppBlue(localizeFor("cancel_button"))
        buttonCancel.cornerRadius = 16.7
        
        datePicker.setValue(UIColor.blueHeading, forKey: "textColor")
//
//
//        //picker background
//        secondTimePicker.subviews[0].subviews[0].backgroundColor = UIColor.clear //the picker's own background view
//        firstTimePicker.subviews[0].subviews[0].backgroundColor = UIColor.clear //the picker's own background view
//
//        //dividers
//        secondTimePicker.subviews[0].subviews[1].backgroundColor = UIColor.clear
//        firstTimePicker.subviews[0].subviews[1].backgroundColor = UIColor.clear
        
        checkEnumCaseBaseOnLoadPicker()
    }
    
    @objc func dismissViewTapGesture(tapGesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        UIView.animate(withDuration: 0.3) {
            self.constraintBottomTableView.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func checkEnumCaseBaseOnLoadPicker(){
        datePicker.minimumDate = Date()
        datePicker.datePickerMode = .date
        if #available(iOS 14, *) {
            datePicker.preferredDatePickerStyle = .inline
            datePicker.tintColor = .blueHeading
        }
        labelDateTitleSelection.text = localizeFor("schedule_date")
    }
        
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension DateSelectionBottomViewController{
    
    @IBAction  func  buttonCancelClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction  func  buttonSaveClicked(_ sender: UIButton) {
        timeSelected?(datePicker.date, nil)
        self.dismiss(animated: true, completion: nil)
    }
}
