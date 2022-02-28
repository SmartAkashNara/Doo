//
//  ApplianceDetailIntensityView.swift
//  Doo-IoT
//
//  Created by Shraddha on 10/08/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit

class ApplianceDetailIntensityView: UIView {
    
    // MARK: - IBOutlets
    @IBOutlet weak var viewApplianceDetailIntensityMain: UIView!
    @IBOutlet weak var viewSwitchOnOff: PowerSwitchView!
    @IBOutlet weak var viewApplianceDetailFeature: UIView!
    @IBOutlet weak var scrollViewApplianceDetailIntensity: UIScrollView!{
        didSet{
            scrollViewApplianceDetailIntensity.bounces = false
            scrollViewApplianceDetailIntensity.isPagingEnabled = false
        }
    }
    @IBOutlet weak var viewApplianceDetailIntensityInsideScroll: UIView!
    @IBOutlet weak var constraintHeightApplianceDetailFeatureView: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightEqualToSuperview: NSLayoutConstraint!
    
    @IBOutlet weak var labelIntencity: UILabel!
    @IBOutlet weak var slider: SectionedSlider!
    var updateSpeedvalue:((Int)->())?
    var powerSwitchOnOFF:((Bool, Int)->())?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.configWithApplianceObj()
        self.layoutSubviews()
        print("viewApplianceDetailIntensityMain:\(self.viewApplianceDetailIntensityMain.frame)")
        
        labelIntencity.font = UIFont.Poppins.medium(11.3)
        labelIntencity.textColor = UIColor.black
        labelIntencity.numberOfLines = 2
        labelIntencity.text = localizeFor("set_Intensity")

//        slider.sections = 5
        slider.sections = 4
        slider.delegate = self
        slider.sliderBackgroundColor = UIColor.sliderUnSelected
        slider.sliderColor = UIColor.blueSwitch
        slider.viewBackgroundColor = UIColor.white
        slider.cornerRadius = 10
        
        
//        slider.isHidden = true
//        labelIntencity.isHidden = true
    }
    
    func reSizeXib(frame:CGRect) {
        self.frame = frame
        self.layoutSubviews()
    }
    
    func setSizeOfViewBasedOnContent(isAccordingSizeOfScreen: Bool) {
        if isAccordingSizeOfScreen {
            self.constraintHeightEqualToSuperview.isActive = true
            self.constraintHeightApplianceDetailFeatureView.isActive = false
        } else {
            self.constraintHeightEqualToSuperview.isActive = false
            self.constraintHeightApplianceDetailFeatureView.isActive = true
        }
    }
    
    // MARK: - Other Methods
    func configWithApplianceObj(applianceModel: ApplianceDataModel? = nil) {
        if let appliance = applianceModel {
            self.viewSwitchOnOff.configWithApplianceObj(appliance: appliance)
            slider.selectedSection = appliance.speed
            self.viewSwitchOnOff.switchPower.switchStatusChanged = { value in
                self.powerSwitchOnOFF?(self.viewSwitchOnOff.switchPower.isON, self.viewSwitchOnOff.switchPower.tag)
            }
        }
    }
}

extension ApplianceDetailIntensityView: SectionedSliderDelegate{
    func sectionChanged(slider: SectionedSlider, selected: Int) {
        updateSpeedvalue?(selected)
    }
}
