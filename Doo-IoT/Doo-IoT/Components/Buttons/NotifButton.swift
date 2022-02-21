//
//  NotifButton.swift
//  CertifID
//
//  Created by Kiran Jasvanee on 14/09/19.
//  Copyright © 2019 SmartSense. All rights reserved.
//

import UIKit

class NotifButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initSetup()
    }
    
    let buttonNotifCount: UIButton = UIButton()
    var widthConstraintOfNotifCount: NSLayoutConstraint? = nil
    var dotImageView: UIImageView = UIImageView()
    func initSetup() {
        self.addSubview(buttonNotifCount)
        buttonNotifCount.translatesAutoresizingMaskIntoConstraints = false
        buttonNotifCount.isUserInteractionEnabled = false
        buttonNotifCount.addTop(isSuperView: self, constant: 0)
        buttonNotifCount.addRight(isSuperView: self, constant: -4)
        buttonNotifCount.addHeight(constant: 20)
        widthConstraintOfNotifCount = buttonNotifCount.addWidth(constant: 20)
        buttonNotifCount.layer.cornerRadius = 20/2
        buttonNotifCount.layer.masksToBounds = true
        buttonNotifCount.backgroundColor = .red
        buttonNotifCount.setTitleColor(.white, for: .normal)
        buttonNotifCount.titleLabel?.font = UIFont.Poppins.semiBold(10)
        buttonNotifCount.contentEdgeInsets = UIEdgeInsets.init(top: 8, left: 5, bottom: 8, right: 5)
        buttonNotifCount.isHidden = true
        
        // Dot imageview.
        dotImageView.contentMode = .scaleAspectFill
        dotImageView.isHidden = true
        // first add and set its translatesAutoresizingMaskIntoConstraints property to false, for allowing constraints setup.
        addSubview(dotImageView)
        dotImageView.translatesAutoresizingMaskIntoConstraints = false

        // Label theming
        dotImageView.image = UIImage.init(named: "doubtreddot")

        // Constraints
        let constraintCenterX = NSLayoutConstraint(item: dotImageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 10)
        // kiran - take image bit up setting
        let constraintCenterY = NSLayoutConstraint(item: dotImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: -10)

        addConstraints([constraintCenterX, constraintCenterY])
    }
    
    var setCount: Int = 0{
        didSet {
            guard self.setCount != 0 else{
                self.buttonNotifCount.isHidden = true
                return
            }
            self.buttonNotifCount.isHidden = false
            self.dotImageView.isHidden = true // if count set.
            if setCount < 10 {
                widthConstraintOfNotifCount?.isActive = true
            }else{
                widthConstraintOfNotifCount?.isActive = false
            }
            
            // self.buttonNotifCount.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                let visibleString = (self.setCount > 99) ? "99+" : "\(self.setCount)"
                // self.buttonNotifCount.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
                self.buttonNotifCount.setTitle(visibleString, for: .normal)
            }, completion: nil)
        }
    }
    func showDotImage() {
        self.dotImageView.isHidden = false
        self.buttonNotifCount.isHidden = true
    }
    
    var setCountString: String = ""{
        didSet {
            if setCountString.count <= 1 {
                widthConstraintOfNotifCount?.isActive = true
            }else{
                widthConstraintOfNotifCount?.isActive = false
            }
            self.buttonNotifCount.setTitle(self.setCountString, for: .normal)
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


















