//
//  TimeSelectionBottomViewController.swift
//  Doo-IoT
//
//  Created by Akash Nara on 25/01/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit

class TimeSelectionBottomViewController: UIViewController {
    
    enum EnumTimePickerType {
        case bindingRule, schedule(isTime:Bool, isScheduleFutureDate:Bool)
    }
    
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var viewFirstTimeSelection: UIView!
    @IBOutlet weak var viewSecondTimeSelection: UIView!
    @IBOutlet weak var labelFirstTimeSelection: UILabel!
    @IBOutlet weak var labelSecondTimeSelection: UILabel!
    @IBOutlet weak var firstTimePicker: UIDatePicker!
    @IBOutlet weak var secondTimePicker: UIDatePicker!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var leadingSecondPickerViewContainer: NSLayoutConstraint!
    @IBOutlet weak var constraintBottomTableView: NSLayoutConstraint!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var mainView: UIView!

    
    private  var firstTimeSelected: ((Date, Date) -> ())? = nil
    private var secondTimeSelected: ((Date, Date) -> ())? = nil
    
    var timeSelected: ((Date, Date?) -> ())? = nil
    var objEnumTimePickerType: EnumTimePickerType = .bindingRule
    
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

        labelFirstTimeSelection.font = UIFont.Poppins.medium(11.3)
        labelFirstTimeSelection.textColor = UIColor.blueHeadingAlpha60
        
        labelSecondTimeSelection.font = UIFont.Poppins.medium(11.3)
        labelSecondTimeSelection.textColor = UIColor.blueHeadingAlpha60
        
        buttonSave.setThemeAppBlue(localizeFor("save_button"))
        buttonSave.cornerRadius = 16.7
        buttonCancel.setLightThemeAppBlue(localizeFor("cancel_button"))
        buttonCancel.cornerRadius = 16.7
        
        firstTimePicker.setValue(UIColor.blueHeading, forKey: "textColor")
        secondTimePicker.setValue(UIColor.blueHeading, forKey: "textColor")
        
        
        //picker background
        secondTimePicker.subviews[0].subviews[0].backgroundColor = UIColor.clear //the picker's own background view
        firstTimePicker.subviews[0].subviews[0].backgroundColor = UIColor.clear //the picker's own background view
        
        //dividers
        secondTimePicker.subviews[0].subviews[1].backgroundColor = UIColor.clear
        firstTimePicker.subviews[0].subviews[1].backgroundColor = UIColor.clear
        
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
        switch objEnumTimePickerType {
        case .bindingRule:
            labelFirstTimeSelection.text = localizeFor("start_Time")
            labelSecondTimeSelection.text = localizeFor("end_Time")
            viewSecondTimeSelection.alpha = 1
        case .schedule(let isTime, let isScheduleFutureDate):
            
            labelFirstTimeSelection.text = isTime ? localizeFor("schedule_time") : localizeFor("schedule_date")
            viewSecondTimeSelection.alpha = 0
            firstTimePicker.datePickerMode = isTime ? .time : .date
            
            if isTime{
                firstTimePicker.minimumDate = isScheduleFutureDate ?  nil : Date()
                firstTimePicker.maximumDate = nil
            }else{
                firstTimePicker.minimumDate = Date()
            }
        }
    }
        
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension TimeSelectionBottomViewController{
    @IBAction  func  firstTimeDateHandle(_ sender: UIDatePicker) {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: sender.date)
        if let day = components.day, let month = components.month, let year = components.year {
            print("\(day) \(month) \(year)")
            firstTimeSelected?(sender.date, secondTimePicker.date)
        }
    }
    
    @IBAction  func  secondTimeDateHandle(_ sender: UIDatePicker) {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: sender.date)
        if let day = components.day, let month = components.month, let year = components.year {
            print("\(day) \(month) \(year)")
            secondTimeSelected?(firstTimePicker.date, sender.date)
        }
    }
    
    @IBAction  func  buttonCancelClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction  func  buttonSaveClicked(_ sender: UIButton) {
        switch objEnumTimePickerType {
        case .bindingRule:
            timeSelected?(firstTimePicker.date, secondTimePicker.date)
        case .schedule:
            timeSelected?(firstTimePicker.date, nil)
        }
        self.dismiss(animated: true, completion: nil)
    }
}
