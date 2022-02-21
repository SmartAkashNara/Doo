//
//  OTPCountdown.swift
//  CertifID
//
//  Created by Kiran Jasvanee on 07/12/18.
//  Copyright © 2018 SmartSense. All rights reserved.
//

import UIKit

enum OTPCountdownState {
    case sending, timer, resend
    
    func getTitleColor() -> UIColor {
        switch self {
        case .sending:
            return UIColor.blueHeading
        case .resend:
            return UIColor.blueHeading
        case .timer:
            return UIColor.blueHeading
        }
    }
}

@objc protocol OTPCountDownDelegate {
    @objc optional func resendOTPTapped()
}

class OTPCountdown: UIView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initSetUp()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initSetUp()
    }
    
    var otpTimeOut = 60
    var count = 0   // reason of not keeping this private, that is been handled from AppDelegate too for continuing count down in background too.
    private var timer: Timer? = nil
    
    weak var delegate: OTPCountDownDelegate? = nil
    
    private var countdownLabel: UILabel = UILabel.init(frame: .zero)
    public var setOTPCountDownState: OTPCountdownState = .sending {
        didSet {
            switch self.setOTPCountDownState {
            case .sending:
                self.setSending()
            case .timer:
                self.setStartTimer()
            case .resend:
                self.setResend()
            }
        }
    }
    
    private func initSetUp() {
        self.addCountdownLabel()
        
        // add gesture
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.OTPCountDownTapped(gestureRecognizer:)))
        self.addGestureRecognizer(tapGesture)
        
    }
    
    
    private func setSending() {
        countdownLabel.textColor = UIColor.blueHeading
        countdownLabel.text = cueAlert.Button.sendingDotted
    }
    
    private func setStartTimer() {
        self.count = self.otpTimeOut
        self.countdownLabel.textColor = UIColor.black
        //self.countdownLabel.text = "0"+String(format: "%.2f", Float(count)/100)
        printSecondsToHoursMinutesSeconds(seconds: count)
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    
    
    @objc private func update() {
        if(count > 0) {
            count -= 1
            // self.countdownLabel.text = "0"+String(format: "%.2f", Float(count)/100)
            printSecondsToHoursMinutesSeconds(seconds: count)
        }else{
            self.invalidateAndNilTimer()
            self.count = self.otpTimeOut
            self.setResend()
        }
    }
    
    func printSecondsToHoursMinutesSeconds (seconds:Int) -> () {
        let (m, s) = secondsToMinutesSeconds(Double(seconds))
        // debugPrint("\(m) Minutes, \(s) Seconds")
        
        DispatchQueue.main.async {
            self.countdownLabel.isHidden = false
            self.countdownLabel.text = String(format: "%02d:%02d", Int(m), Int(ceilf(Float(s))))
        }
    }
    func secondsToMinutesSeconds (_ seconds : Double) -> (Double, Double) {
        let (_,  minf) = modf (seconds / 3600)
        let (min, secf) = modf (60 * minf)
        return (min, 60 * secf)
    }
    func secondsToHoursMinutesSeconds (_ seconds : Double) -> (Double, Double, Double) {
        let (hr,  minf) = modf (seconds / 3600)
        let (min, secf) = modf (60 * minf)
        return (hr, min, 60 * secf)
    }
    
    
    
    private func invalidateAndNilTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    private func setResend() {
        countdownLabel.textColor = UIColor.blueHeading
        countdownLabel.text = cueAlert.Button.resend
    }
    @objc private func OTPCountDownTapped(gestureRecognizer: UITapGestureRecognizer) {
        if self.countdownLabel.text == cueAlert.Button.resend {
           self.delegate?.resendOTPTapped?()
        }
    }
    
    private func addCountdownLabel() {
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(countdownLabel)
        countdownLabel.addLeft(isSuperView: self, constant: 0)
        countdownLabel.addCenterY(inSuperView: self)
        countdownLabel.font = UIFont.Poppins.medium(14)
        self.setSending()
    }
    
    deinit {
        self.timer = nil
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
