//
//  ScheduleTypeSelectionBottomViewController.swift
//  Doo-IoT
//
//  Created by Akash Nara on 26/01/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit

class ScheduleDaysModel {
    var day = Weekdays.Mon
    var dayValue = 0
    var isSelected = false
    init(name: Weekdays, dayValue: Int, isSelectedValue:Bool = false) {
        self.day = name
        self.dayValue = dayValue
        self.isSelected = isSelectedValue
    }
}

class ScheduleTypeSelectionBottomViewController: UIViewController {
    
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var labeNavigationDetailTitle: UILabel!
    @IBOutlet weak var labelNavigaitonDetailSubTitle: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonOnce: UIButton!
    @IBOutlet weak var buttonDaily: UIButton!
    @IBOutlet weak var labelCustomTitle: UILabel!
    @IBOutlet var buttonCollectionArray: [UIButton]!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var constraintBottomTableView: NSLayoutConstraint!
    
    var arrayDays = [ScheduleDaysModel]()
    var callBackComplition: ((_ isOnceSelectedOption: Bool,_ isDailySelectedOption: Bool, [ScheduleDaysModel]?) -> ())? = nil
    var strScheduleDays = ""
    
    // Edit mode
    // var
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setDefault()
        // mind change, keep it shown (false)
        self.separatorView.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        UIView.animate(withDuration: 0.3) {
            self.constraintBottomTableView.constant = 0
            self.view.layoutIfNeeded()
        }
    }

    func preparedDaysArrayAndLoad(){
        
        arrayDays.removeAll()
        arrayDays.append(ScheduleDaysModel.init(name: .Mon, dayValue: 1))
        arrayDays.append(ScheduleDaysModel.init(name: .Tue, dayValue: 2))
        arrayDays.append(ScheduleDaysModel.init(name: .Wed, dayValue: 3))
        arrayDays.append(ScheduleDaysModel.init(name: .Thu, dayValue: 4))
        arrayDays.append(ScheduleDaysModel.init(name: .Fri, dayValue: 5))
        arrayDays.append(ScheduleDaysModel.init(name: .Sat, dayValue: 6))
        arrayDays.append(ScheduleDaysModel.init(name: .Sun, dayValue: 7))
        
        if self.strScheduleDays != "" {
            let arrSelectedDays = self.strScheduleDays.split(separator: ",")
            for dayValue in arrSelectedDays {
                self.arrayDays.forEach { (obj) in
                    debugPrint("obj dayValue: \(obj.dayValue)")
                    if obj.dayValue == Int(dayValue) {
                        obj.isSelected = true
                    }
                }
            }
        }
        
        for (index, obj) in arrayDays.enumerated(){
            
            buttonCollectionArray[index].setTitle(obj.day.getD(), for: .normal)
            buttonCollectionArray[index].titleLabel?.font = UIFont.Poppins.medium(13)
            
            buttonCollectionArray[index].makeRoundByCorners() //= buttonCollectionArray[index].frame.height/2
            
            buttonCollectionArray[index].setTitleColor(UIColor.textfieldTitleColor , for: .normal)
            buttonCollectionArray[index].setTitleColor(UIColor.blueSwitch, for: .selected)
            
            buttonCollectionArray[index].backgroundColor = obj.isSelected ? UIColor.blueSwitchAlpha10 : UIColor.daysInActiveBackground
            
            buttonCollectionArray[index].isSelected = obj.isSelected
        }
    }
    
    func setDefault() {
        
        preparedDaysArrayAndLoad()
        
        buttonSave.setThemeAppBlue(localizeFor("save_button"))
        buttonSave.cornerRadius = 16.7
        
        buttonCancel.setLightThemeAppBlue(localizeFor("cancel_button"))
        buttonCancel.cornerRadius = 16.7
        
        buttonDaily.setTitle(localizeFor("daily").capitalized, for: .normal)
        buttonOnce.setTitle(localizeFor("once").capitalized, for: .normal)
        buttonOnce.setTitleColor(UIColor.blueHeading, for: .normal)
        buttonDaily.setTitleColor(UIColor.blueHeading, for: .normal)
        buttonDaily.titleLabel?.font = UIFont.Poppins.medium(13)
        buttonDaily.titleLabel?.font = UIFont.Poppins.medium(13)
        
        labelCustomTitle.font = UIFont.Poppins.medium(11)
        labelCustomTitle.textColor = UIColor.blueHeadingAlpha60
        labelCustomTitle.text = localizeFor("custom").capitalized
        
        labeNavigationDetailTitle.font = UIFont.Poppins.semiBold(18)
        labeNavigationDetailTitle.textColor = UIColor.blueHeading
        self.labeNavigationDetailTitle.text = localizeFor("schedule_type")
        
        labelNavigaitonDetailSubTitle.font = UIFont.Poppins.regular(11.3)
        labelNavigaitonDetailSubTitle.textColor = UIColor.blueHeading
        self.labelNavigaitonDetailSubTitle.text = "Select scheduler frequency and time."
        
        self.mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.mainView.layer.cornerRadius = 10.0
        
        // remove view when blank area gonna be tapped.
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.dismissViewTapGesture(tapGesture:)))
        backgroundView.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissViewTapGesture(tapGesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ScheduleTypeSelectionBottomViewController{
    @IBAction  func  buttonCancelClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonSaveClicked(_ sender: UIButton) {
        callBackComplition?(false, false, arrayDays)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttoDailyClicked(_ sender: UIButton) {
        unSelectAllDaysButton()
        callBackComplition?(false, true, nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttoOnceClicked(_ sender: UIButton) {
        unSelectAllDaysButton()
        callBackComplition?(true, false, nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttoDaysCollectionClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        arrayDays[sender.tag].isSelected = sender.isSelected
        sender.backgroundColor = sender.isSelected ? UIColor.blueSwitchAlpha10 : UIColor.daysInActiveBackground
    }
    
    func unSelectAllDaysButton(){
        for (index,button) in buttonCollectionArray.enumerated(){
            button.isSelected = false
            button.backgroundColor = UIColor.daysInActiveBackground
            arrayDays[index].isSelected = false
        }
    }
}
