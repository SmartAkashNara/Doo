//
//  DooBottomPopupAlerts_1ViewController.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 09/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class DooBottomPopupAlerts_1ViewController: UIViewController {
    
    struct ActionButton {
        var title: String
        var titleColor: UIColor
        var backgroundColor: UIColor
        var action: (()->())
    }
    
    @IBOutlet weak var bottomConstraintOfMainView: NSLayoutConstraint!
    @IBOutlet weak var heightConstraintOfMainView: NSLayoutConstraint!
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var stackViewContent: UIStackView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var buttonLeft: UIButton!
    @IBOutlet weak var buttonRight: UIButton!
    
    private var alertTitle: String = ""
    private var leftButton: ActionButton? = nil
    private var rightButton: ActionButton? = nil
    
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
    
    func setAlert(alertTitle: String,
                  leftButton: ActionButton? = nil, rightButton: ActionButton? = nil) {
        
        self.alertTitle = alertTitle
        self.leftButton = leftButton
        self.rightButton = rightButton
    }
    
    private func setDefault() {
        self.labelTitle.font = UIFont.Poppins.semiBold(13.3)
        self.labelTitle.textColor = UIColor.blueHeading
        
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

    @objc func dismissViewTapGesture(tapGesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}
