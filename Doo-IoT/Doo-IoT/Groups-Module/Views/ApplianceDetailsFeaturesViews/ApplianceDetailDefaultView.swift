//
//  ApplianceDetailDefaultView.swift
//  Doo-IoT
//
//  Created by Shraddha on 10/08/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit

class ApplianceDetailDefaultView: UIView {

    // MARK: - IBOutlets
    @IBOutlet weak var viewApplianceDetailDefaultMain: UIView!
    @IBOutlet weak var viewSwitchOnOff: PowerSwitchView!
    @IBOutlet weak var viewApplianceDetailFeature: UIView!
    @IBOutlet weak var scrollViewApplianceDetailDefaultView: UIScrollView!{
        didSet{
            scrollViewApplianceDetailDefaultView.bounces = false
            scrollViewApplianceDetailDefaultView.isPagingEnabled = false
        }
    }
    @IBOutlet weak var viewApplianceDetailDefaultInsideScroll: UIView!
    
    // Constraints
    @IBOutlet weak var constraintHeightEqualToSuperview: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightOfViewApplianceDEtailFeature: NSLayoutConstraint!
    @IBOutlet weak var constrainBottomView: NSLayoutConstraint!
    var powerSwitchOnOFF:((Bool, Int)->())?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.configWithApplianceObj()
        self.layoutSubviews()
        debugPrint("viewApplianceDetailDefaultMain:\(self.viewApplianceDetailDefaultMain.frame)")
    }
    
    func reSizeXib(frame:CGRect) {
        self.frame = frame
        self.layoutSubviews()
    }
    
    
    func setSizeOfViewBasedOnContent(isAccordingSizeOfScreen: Bool) {
        
        /*
         If flag is send as true, then whole content will be fit inside screensize, accordingly color picker height will be set and content will not be scrollable.
        
         If flag is end as false, then whole content will not feet the screen size, color picker height will be set proportional to screen height and content will be scrollable.
        
         To make content fit with the screen size pass true to this method
        */
        
        
        if isAccordingSizeOfScreen {
            self.constraintHeightEqualToSuperview.isActive = true
            self.constraintHeightOfViewApplianceDEtailFeature.isActive = true
        } else {
            self.constraintHeightEqualToSuperview.isActive = false
            self.constraintHeightOfViewApplianceDEtailFeature.isActive = false
        }
    }
    
    // MARK: - Other Methods
    func configWithApplianceObj(applianceModel: ApplianceDataModel? = nil) {
        if let appliance = applianceModel {
            self.viewSwitchOnOff.configWithApplianceObj(appliance: appliance)
            self.viewSwitchOnOff.switchPower.switchStatusChanged = { value in
                self.powerSwitchOnOFF?(self.viewSwitchOnOff.switchPower.isON, self.viewSwitchOnOff.switchPower.tag)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
