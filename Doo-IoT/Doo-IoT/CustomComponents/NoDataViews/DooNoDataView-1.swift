//
//  DooNoDataView-1.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 24/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

protocol DooNoDataView_1Delegate {
    func buttonAction1Tapped()
    func buttonContentAction1Tapped()
    func buttonLogoutTapped()
}
extension DooNoDataView_1Delegate {
    func buttonAction1Tapped(){}
    func buttonContentAction1Tapped(){}
    func buttonLogoutTapped(){}
}

class DooNoDataView_1: UIView {
    
    enum ShowIn {
        case noEnterprises
        
        func getTitle() -> String?{
            switch self {
            case .noEnterprises:
                return "No Enterprises assigned to you"
            }
        }
        
        func getImage() -> UIImage?{
            switch self {
            case .noEnterprises:
                return UIImage.init(named: "noenterpriseimage")
            }
        }
        
        func getContent1() -> String?{
            switch self {
            case .noEnterprises:
                return "Ask your owner to invite you for the enterprise"
            }
        }
        
        func getContent2() -> String?{
            switch self {
            case .noEnterprises:
                return "or"
            }
        }
        
        func getAction1Title() -> String?{
            switch self {
            case .noEnterprises:
                return "Add Enterprise"
            }
        }
        
        func getContentActionTitle() -> String?{
            switch self {
            case .noEnterprises:
                return "Tap here to check the received invitations"
            }
        }
    }
    
    var showIn: ShowIn? = nil
    var stackView: UIStackView? = nil
    
    var delegate: DooNoDataView_1Delegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func showNoDataView() {
        if  self.stackView == nil {
            self.initSetup()
        }
    }
    
    func initSetup(_ inView: ShowIn? = nil) {
        self.showIn = inView
        switch self.showIn {
        case .noEnterprises:
            allocateView()
        case .none:
            break
        }
    }

    var noEnterpriseView: AddEnterpriseOutletView? = nil
    func allocateView() {
        noEnterpriseView = AddEnterpriseOutletView.init(frame: .zero)
        noEnterpriseView?.translatesAutoresizingMaskIntoConstraints = false
        noEnterpriseView?.tag = 420
        self.addSubview(noEnterpriseView!)
        noEnterpriseView?.addTop(isSuperView: self, constant: 0)
        noEnterpriseView?.addLeft(isSuperView: self, constant: 0)
        noEnterpriseView?.addRight(isSuperView: self, constant: 0)
        noEnterpriseView?.addBottom(isSuperView: self, constant: 0)
        
        noEnterpriseView?.labelTitle1.font = UIFont.Poppins.semiBold(14.7)
        noEnterpriseView?.labelTitle1.text = self.showIn?.getTitle()
        noEnterpriseView?.labelTitle1.textColor = UIColor.blueHeading
        
        noEnterpriseView?.centralImageView.image = self.showIn?.getImage()
        
        noEnterpriseView?.labelContent1.text = self.showIn?.getContent1()
        noEnterpriseView?.labelContent1.font = UIFont.Poppins.regular(13.3)
        noEnterpriseView?.labelContent1.textColor = UIColor.blueHeading
        
        noEnterpriseView?.labelContent2.text = self.showIn?.getContent2()
        noEnterpriseView?.labelContent2.font = UIFont.Poppins.regular(13.3)
        noEnterpriseView?.labelContent2.textColor = UIColor.blueHeading
        
        noEnterpriseView?.buttonAction1.setTitle(self.showIn?.getAction1Title(), for: .normal)
        noEnterpriseView?.buttonAction1.cornerRadius = noEnterpriseView!.buttonAction1.bounds.size.height/2
        noEnterpriseView?.buttonAction1.setTitleColor(UIColor.white, for: .normal)
        noEnterpriseView?.buttonAction1.backgroundColor = UIColor.blueSwitch
        noEnterpriseView?.buttonAction1.addTarget(self, action: #selector(self.navigateToAddEnterprise(sender:)), for: .touchUpInside)
        
        noEnterpriseView?.buttonContentAction1.setTitle(self.showIn?.getContentActionTitle(), for: .normal)
        noEnterpriseView?.buttonContentAction1.setTitleColor(UIColor.blueSwitch, for: .normal)
        noEnterpriseView?.buttonContentAction1.titleLabel?.font = UIFont.Poppins.regular(13.3)
        noEnterpriseView?.buttonContentAction1.addAction(for: .touchUpInside, { [weak self] in
            self?.delegate?.buttonContentAction1Tapped()
        })
        
        if cueDevice.isDevice6SOrLower {
            noEnterpriseView?.topConstraintToBottomContentAction.constant = 16
            noEnterpriseView?.contentStackView.spacing = 24.0
        }else{
            noEnterpriseView?.topConstraintToBottomContentAction.constant = 16
            noEnterpriseView?.contentStackView.spacing = 24.0
        }
        
        noEnterpriseView?.buttonOfLogout.setTitle("Logout", for: .normal)
        noEnterpriseView?.buttonOfLogout.cornerRadius = noEnterpriseView!.buttonAction1.bounds.size.height/2
        noEnterpriseView?.buttonOfLogout.setTitleColor(UIColor.darkGray, for: .normal)
        noEnterpriseView?.buttonOfLogout.backgroundColor = .clear
        noEnterpriseView?.buttonOfLogout.titleLabel?.font = UIFont.Poppins.medium(14)
        // noEnterpriseView?.buttonOfLogout.backgroundColor = UIColor.gray
        noEnterpriseView?.buttonOfLogout.addAction(for: .touchUpInside, { [weak self] in
            self?.delegate?.buttonLogoutTapped()
        })
    }
    
    @objc func navigateToAddEnterprise(sender: UIButton) {
        self.delegate?.buttonAction1Tapped()
    }
    
    func dismissView() {
        dismissCompletely()
        DispatchQueue.getMain(delay: 0.1) { [weak self] in
            self?.dismissCompletely()
            self?.layoutIfNeeded()
        }
    }
    
    func dismissCompletely() {
        noEnterpriseView?.removeFromSuperview()
        let eView = self.viewWithTag(420)
        eView?.removeFromSuperview()
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
