//
//  DooBottomPopUpShortcutOptionsForLogout_ViewController.swift
//  Doo-IoT
//
//  Created by Shraddha on 04/01/22.
//  Copyright © 2022 SmartSense. All rights reserved.
//

import UIKit

class DooBottomPopUpShortcutOptionsForLogout_ViewController: UIViewController {

    struct ActionButton {
        var title: String
        var titleColor: UIColor
        var backgroundColor: UIColor
        var action: (()->())
    }
    
    struct ActionButtonForRemovingShortcut {
        var action: (()->())
    }
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var viewShortcutOption: UIView!
    @IBOutlet weak var buttonRemoveShortcutSelection
    :ButtonOfInfinityTree!
    @IBOutlet weak var labelRemoveShortcutDescription: UILabel!
    @IBOutlet weak var bottomConstraintOfMainView: NSLayoutConstraint!
    @IBOutlet weak var heightConstraintOfMainView: NSLayoutConstraint!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var stackViewContent: UIStackView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var buttonLeft: UIButton!
    @IBOutlet weak var buttonRight: UIButton!
    
    private var alertTitle: String = ""
    private var alertDescription: String = ""
    private var alertShortcutRemoveDescription: String = ""
    private var leftButton: ActionButton? = nil
    private var rightButton: ActionButton? = nil
//    private var removeShortcutCheckmarkButton: ActionButtonForRemovingShortcut? = nil
    
    var checked: Bool = false {
            didSet {
                buttonRemoveShortcutSelection.setImage(UIImage(named: checked ? "marked_1" : "unmarked_1"), for: .normal)
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setDefault()
        self.setAlert()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        UIView.animate(withDuration: 0.1) {
            self.bottomConstraintOfMainView.constant = 0
            self.view.layoutIfNeeded()
        }
    }

    func setAlert(alertTitle: String, alertShortcutRemoveDescription:String,
                  leftButton: ActionButton? = nil, rightButton: ActionButton? = nil) {
        self.alertTitle = alertTitle
//        self.alertDescription = alertDescription
        self.alertShortcutRemoveDescription = alertShortcutRemoveDescription
        self.leftButton = leftButton
        self.rightButton = rightButton
//        self.checked = isChecked
//        self.removeShortcutCheckmarkButton = removeShortcutCheckmarkButton
    }
    
    private func setDefault() {
        self.checked = false
        self.labelTitle.font = UIFont.Poppins.semiBold(13.3)
        self.labelTitle.textColor = UIColor.blueHeading
        
//        self.labelDescription.font = UIFont.Poppins.medium(13.3)
//        self.labelDescription.textColor = UIColor.blueHeading
        
        self.labelRemoveShortcutDescription.font = UIFont.Poppins.medium(13.3)
        self.labelRemoveShortcutDescription.textColor = UIColor.blueHeading
        
        self.buttonLeft.titleLabel?.font = UIFont.Poppins.semiBold(13.3)
        self.buttonLeft.cornerRadius = 16.7
        self.buttonLeft.clipsToBounds = true
        
        self.buttonRight.titleLabel?.font = UIFont.Poppins.semiBold(13.3)
        self.buttonRight.cornerRadius = 16.7
        self.buttonRight.clipsToBounds = true
        
        self.mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.mainView.layer.cornerRadius = 10.0
        
        // remove view when blank area gonna be tapped.
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.dismissViewTapGesture(tapGesture:)))
        backgroundView.addGestureRecognizer(tapGesture)
    }
    
    private func setAlert() {
        self.labelTitle.text = alertTitle
//        if alertDescription.count > 0 {
//            self.labelDescription.isHidden = false
//            self.labelDescription.text = alertDescription
//        } else {
//            self.labelDescription.isHidden = true
//        }
        
        if alertShortcutRemoveDescription.count > 0 {
            self.viewShortcutOption.isHidden = false
            self.buttonRemoveShortcutSelection.isHidden = true
//            self.labelRemoveShortcutDescription.isHidden = false
//            self.removeShortcutCheckmarkButton.
            self.labelRemoveShortcutDescription.text = alertShortcutRemoveDescription
//            self.labelRemoveShortcutDescription.numberOfLines = 4
//            self.labelRemoveShortcutDescription.lineBreakMode = .byTruncatingTail
//            self.buttonRemoveShortcutSelection.addTarget(self, action: #selector(self.removeShortcutCheckmarkActionListener(sender:)), for: .touchUpInside)
        } else {
            self.viewShortcutOption.isHidden = true
        }
        
        if let leftActionAvailable = leftButton {
            self.buttonLeft.setTitle(leftActionAvailable.title, for: .normal)
            self.buttonLeft.setTitleColor(leftActionAvailable.titleColor, for: .normal)
            self.buttonLeft.backgroundColor = leftActionAvailable.backgroundColor
            self.buttonLeft.isHidden = false
            self.buttonLeft.addTarget(self, action: #selector(self.leftButtonActionListener(sender:)), for: .touchUpInside)
        }else{
            self.buttonLeft.isHidden = true
        }
        
        if let rightActionAvailable = rightButton {
            self.buttonRight.setTitle(rightActionAvailable.title, for: .normal)
            self.buttonRight.setTitleColor(rightActionAvailable.titleColor, for: .normal)
            self.buttonRight.backgroundColor = rightActionAvailable.backgroundColor
            self.buttonRight.isHidden = false
            self.buttonRight.addTarget(self, action: #selector(self.rightButtonActionListener(sender:)), for: .touchUpInside)
        }else{
            self.buttonRight.isHidden = true
        }
        
        let contentSizeOfTitles = self.stackViewContent.bounds.size.height
        let finalHeight =  contentSizeOfTitles + 60.0 //30 top & 30 bottom
        self.heightConstraintOfMainView.constant = finalHeight
    }
    
    @objc func leftButtonActionListener(sender: UIButton) {
        self.leftButton?.action()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func rightButtonActionListener(sender: UIButton) {
        self.rightButton?.action()
        self.dismiss(animated: true, completion: nil)
    }

    @objc func removeShortcutCheckmarkActionListener(sender: UIButton) {
        self.checked = !checked
    }
    
    @objc func dismissViewTapGesture(tapGesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
}
