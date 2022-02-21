//
//  ViewController.swift
//  CertifIDSwitch
//
//  Created by Kiran Jasvanee on 19/07/21.
//

import UIKit

class DooSwitch: UIView {
    
    enum CertifSwitchCases {
        case on, off
    }
    var switchStatusChanged: ((Int)->())? = nil
    var certifSwitchCase: CertifSwitchCases = .off {
        didSet {
            if certifSwitchCase == .on {
                self.setOnSwitch(isWithAnimation: true)
                self.switchStatusChanged?(1)
            }else{
                self.setOffSwitch(isWithAnimation: true)
                self.switchStatusChanged?(0)
            }
        }
    }
    var isON: Bool {
        return self.certifSwitchCase == .on ? true : false
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initSetUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initSetUp()
    }
    
    func initSetUp() {
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.switchTapped(sender:))))
    }
    
    @objc func switchTapped(sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.2) {
            if self.certifSwitchCase == .off {
                self.certifSwitchCase = .on
            }else{
                self.certifSwitchCase = .off
            }
            self.layoutIfNeeded()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if viewOfCircle == nil {
            self.layoutSeUp()
            self.setOffSwitch()
        }
    }
    
    var viewOfCircle: UIView? = nil
    var viewToHoldCircle: UIView? = nil
    var leadingOfCircle: NSLayoutConstraint? = nil
    func layoutSeUp() {
        
        let calculatedCircleHeightAndWidth = Double(self.bounds.size.width-4.0)*16.7/30.0
        
        self.viewOfCircle = UIView.init(frame: .zero)
        self.viewOfCircle?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.viewOfCircle!)
        self.viewOfCircle?.addHeight(constant: calculatedCircleHeightAndWidth)
        self.viewOfCircle?.addWidth(constant: calculatedCircleHeightAndWidth)
        self.leadingOfCircle = self.viewOfCircle?.addLeft(isSuperView: self, constant: 2)
        self.viewOfCircle?.addTop(isSuperView: self, constant: 2)
        self.viewOfCircle?.applyShadowJob(cornerRadius: CGFloat(calculatedCircleHeightAndWidth/2.0))
        self.viewOfCircle?.backgroundColor = .white
        
        self.viewToHoldCircle = UIView.init(frame: .zero)
        self.viewToHoldCircle?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.viewToHoldCircle!)
        let heightOfBackgroundView = Double(self.bounds.size.height)-6.0
        self.viewToHoldCircle?.addHeight(constant: heightOfBackgroundView)
        self.viewToHoldCircle?.addWidth(constant: Double(self.bounds.size.width-4.0))
        self.viewToHoldCircle?.addLeft(isSuperView: self, constant: 2.0)
        self.viewToHoldCircle?.addCenterY(inSuperView: self, relateToView: self.viewOfCircle!)
        self.viewToHoldCircle?.backgroundColor = UIColor.init(red: 222.0/255.0, green: 223.0/255.0, blue: 224.0/255.0, alpha: 1.0)
        self.viewToHoldCircle?.layer.cornerRadius = CGFloat(heightOfBackgroundView/2)
        self.viewToHoldCircle?.clipsToBounds = true
        self.bringSubviewToFront(self.viewOfCircle!)
    }
}

// MARK: ON OFF functionality functions
extension DooSwitch {
    func setOnSwitch(isWithAnimation: Bool = false) {
        func onWithAnimation() {
            self.layoutIfNeeded()
            let calculatedCircleHeightAndWidth = Double(self.bounds.size.width-4.0)*16.7/30.0
            self.leadingOfCircle?.constant = self.bounds.size.width-CGFloat(calculatedCircleHeightAndWidth)-2.0
            self.viewOfCircle?.backgroundColor = UIColor.init(red: 0/255, green: 78/255, blue: 129/255, alpha: 1.0)
            self.viewToHoldCircle?.backgroundColor = UIColor.init(red: 0/255, green: 78/255, blue: 129/255, alpha: 0.1)
        }
        if isWithAnimation {
            UIView.animate(withDuration: 0.2) {
                onWithAnimation()
                self.layoutIfNeeded()
            }
        }else{
            onWithAnimation()
        }
    }
    func setOffSwitch(isWithAnimation: Bool = false) {
        func offWithAnimation() {
            self.leadingOfCircle?.constant = 0
            self.viewOfCircle?.backgroundColor = UIColor.init(red: 43/255, green: 55/255, blue: 79/255, alpha: 0.2)
            self.viewToHoldCircle?.backgroundColor = UIColor.init(red: 222.0/255.0, green: 225.0/255.0, blue: 229.0/255.0, alpha: 1.0)
        }
        if isWithAnimation {
            UIView.animate(withDuration: 0.2) {
                offWithAnimation()
                self.layoutIfNeeded()
            }
        }else{
            offWithAnimation()
        }
    }
    
}

/*
// Implementation...
class ViewController: UIViewController {
    
    @IBOutlet weak var switchView: CertifSwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        switchView.switchStatusChanged = { currentStatus in
            debugPrint("current status: \(currentStatus)")
        }
    }
}
*/
