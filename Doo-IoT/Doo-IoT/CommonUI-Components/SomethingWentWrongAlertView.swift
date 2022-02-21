//
//  SomethingWentWrongAlertView.swift
//  TeleSense
//
//  Created by Kiran Jasvanee on 01/05/20.
//  Copyright © 2020 Akash Nara. All rights reserved.
//

import UIKit

@objc protocol SomethingWentWrongAlertViewDelegate {
    func retryTapped()
}

class SomethingWentWrongAlertView: UIView {
    
    enum forPurpose {
        case somethingWentWrong, internetOff, noGroupsListFound
        
        var getImage: UIImage? {
            switch self {
            case .somethingWentWrong:
                return UIImage.init(named: "somthingErrorIcon")
            case .internetOff:
                return UIImage.init(named: "noInternetFound")
            case .noGroupsListFound:
                return UIImage.init(named: "noGroupFound")!
            }
        }
        
        var getTitle: String {
            switch self {
            case .somethingWentWrong:
                return "Something went wrong!"
            case .internetOff:
                return "No Internet!"//"No internet connection"
            case .noGroupsListFound:
                return "Groups"
            }
        }
        
        var getSubTitle: String {
            switch self {
            case .somethingWentWrong:
                return "Please tap retry button and try again."
            case .internetOff:
                return "No internet connection\nPlease check your internet setting."//"Oops!\nWe’re unable to connect to your network,\nplease check your internet connection and try again."
            case .noGroupsListFound:
                return "No groups have been created yet"
            }
        }
    }
    var forPurpose: forPurpose = .somethingWentWrong
    var isInternetOffAlertShow: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    weak var delegateOfSWWalert: SomethingWentWrongAlertViewDelegate? = nil
    
    private var alertMainView: UIView? = nil
    private var stackView: UIStackView? = nil
    private var retryButton: UIButton? = nil
    
    func showNoGroupsFound() {
        self.forPurpose = .noGroupsListFound
        self.retryButton?.isHidden = false
        showAlert()
    }
    
    func dismissNoGroupsFound() {
        dismissAlert()
    }
    func showSomethingWentWrong() {
        self.forPurpose = .somethingWentWrong
        self.retryButton?.isHidden = false
        showAlert()
    }
    
    func dismissSomethingWentWrong() {
        dismissAlert()
    }
    
    func showInternetOff() {
        self.forPurpose = .internetOff
        self.isInternetOffAlertShow = true
        showAlert()
        self.retryButton?.isHidden = false
    }
    fileprivate func extractedFunc() {
        dismissAlert()
    }
    
    func dismissInternetOff() {
        self.isInternetOffAlertShow = false
        extractedFunc()
    }
    
    //Krunal
    func showError() {
        self.isInternetOffAlertShow = true
        showAlert()
        self.retryButton?.isHidden = true
    }
    
    private func showAlert() {
//        if alertMainView == nil {
//            self.initSetup()
//        }else{
//            guard let strongAlertMainView = alertMainView else {return}
//            strongAlertMainView.isHidden = false
//            self.bringSubviewToFront(strongAlertMainView)
//        }
        
        alertMainView?.removeFromSuperview()
        alertMainView = nil // clear views...
        self.initSetup()
        guard let strongAlertMainView = alertMainView else {return}
        strongAlertMainView.isHidden = false
        self.bringSubviewToFront(strongAlertMainView)
    }
    func resetText() {
        
    }
    func dismissAlert() {
        guard let strongAlertMainView = alertMainView else {return}
        strongAlertMainView.isHidden = true
        self.sendSubviewToBack(strongAlertMainView)
    }
    func dismissAnyAlerts() {
        self.dismissSomethingWentWrong()
        self.dismissInternetOff()
        self.dismissNoGroupsFound()
    }
    
    var topConstraintOfPlaceHolderView: NSLayoutConstraint? = nil
    func setTopGapOfPlaceholder(topGapSpace:CGFloat){
        topConstraintOfPlaceHolderView?.constant = topGapSpace
    }

    private func initSetup() {
        let buttonRetryTitle = "Retry"//localizeFor("retry")
        alertMainView = UIView.init(frame: .zero)
        alertMainView?.backgroundColor = .white
        guard let strongAlertMainView = alertMainView else {return}
        strongAlertMainView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(strongAlertMainView)
//        strongAlertMainView.addSurroundingZero(isSuperView: self)
        strongAlertMainView.addLeft(isSuperView: self, constant: 0)
        strongAlertMainView.addRight(isSuperView: self, constant: 0)
        strongAlertMainView.addBottom(isSuperView: self, constant: 0)
        topConstraintOfPlaceHolderView = strongAlertMainView.addTop(isSuperView: self, constant: 0)

        strongAlertMainView.isHidden = false        
        
        stackView = UIStackView.init(frame: .zero)
        stackView!.translatesAutoresizingMaskIntoConstraints = false
        strongAlertMainView.addSubview(stackView!)
        
        stackView!.addLeft(isSuperView: self, constant: 30.0)
        stackView!.addRight(isSuperView: self, constant: -30.0)
        stackView!.addCenterY(inSuperView: self, multiplier: 0.9)
//        stackView!.addTop(isSuperView: self, constant: Float(40))
        stackView!.axis = .vertical
        
        let imageview: UIImageView = UIImageView.init(frame: .zero)
        imageview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageview)
        imageview.image = self.forPurpose.getImage
        imageview.contentMode = .center
        stackView!.addArrangedSubview(imageview)
        
        let innerStackView = UIStackView.init(frame: .zero)
        innerStackView.translatesAutoresizingMaskIntoConstraints = false
        innerStackView.axis = .vertical
        innerStackView.alignment = .fill
        stackView!.addArrangedSubview(innerStackView)
        
        let noResultsFoundLabel: UILabel = UILabel.init(frame: .zero)
        noResultsFoundLabel.translatesAutoresizingMaskIntoConstraints = false
        innerStackView.addArrangedSubview(noResultsFoundLabel)
        noResultsFoundLabel.text = self.forPurpose.getTitle
        noResultsFoundLabel.textAlignment = .center
        noResultsFoundLabel.font = UIFont.Poppins.semiBold(16)
        noResultsFoundLabel.textColor = UIColor.blueHeading
        
        let noResultsDetailFoundLabel: UILabel = UILabel.init(frame: .zero)
        noResultsDetailFoundLabel.translatesAutoresizingMaskIntoConstraints = false
        innerStackView.addArrangedSubview(noResultsDetailFoundLabel)
        noResultsDetailFoundLabel.text = self.forPurpose.getSubTitle
        noResultsDetailFoundLabel.font = UIFont.Poppins.medium(13.3)
        noResultsDetailFoundLabel.textColor = UIColor.blueHeadingAlpha30
        noResultsDetailFoundLabel.lineBreakMode = .byWordWrapping
        noResultsDetailFoundLabel.textAlignment = .center
        
        retryButton = UIButton.init(frame: .zero)
        guard let strongRetryButton = retryButton else {return}
        strongRetryButton.translatesAutoresizingMaskIntoConstraints = false
        strongRetryButton.backgroundColor = UIColor.blueSwitch
        strongRetryButton.setTitle(buttonRetryTitle, for: .normal)
        strongRetryButton.setTitleColor(UIColor.white, for: .normal)
        strongRetryButton.titleLabel?.font = UIFont.Poppins.medium(11.3)
//        strongRetryButton.setBackgroundImage(#imageLiteral(resourceName: "imgTickGreenRound"), for: .normal)
        strongRetryButton.clipsToBounds = true
        switch self.forPurpose {
        case .internetOff, .somethingWentWrong:
            let retryButtonStackView = UIStackView.init(frame: .zero)
            retryButtonStackView.translatesAutoresizingMaskIntoConstraints = false
            retryButtonStackView.axis = .vertical
            retryButtonStackView.alignment = .center
            retryButtonStackView.addArrangedSubview(strongRetryButton)
            strongRetryButton.addWidth(constant: 170)
            innerStackView.addArrangedSubview(retryButtonStackView)
            strongRetryButton.addHeight(constant: 35)
            strongRetryButton.cornerRadius = 6.7//17
            noResultsDetailFoundLabel.numberOfLines = 0

            innerStackView.spacing = 16
            stackView!.spacing = 12
        case .noGroupsListFound:
            break
        default:
            strongAlertMainView.addSubview(strongRetryButton)
            stackView!.spacing = 20
            innerStackView.spacing = 8
            noResultsDetailFoundLabel.numberOfLines = 3

            strongRetryButton.addLeft(isSuperView: strongAlertMainView, constant: 20)
            strongRetryButton.addRight(isSuperView: strongAlertMainView, constant: -20)
            strongRetryButton.addBottom(isSuperView: strongAlertMainView, constant: -20)
            strongRetryButton.addHeight(constant: 46)
            strongRetryButton.cornerRadius = 6.7
        }
        
        strongRetryButton.addTarget(self, action: #selector(self.retryActionListener(sender:)), for: .touchUpInside)
        
        self.bringSubviewToFront(strongAlertMainView)
    }
    
    @objc func retryActionListener(sender: UIButton) {
        self.delegateOfSWWalert?.retryTapped()
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
