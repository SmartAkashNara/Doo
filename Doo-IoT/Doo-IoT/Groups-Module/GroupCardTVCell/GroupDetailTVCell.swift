//
//  GroupDetailTVCell.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 27/05/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class GroupDetailTVCell: UITableViewCell {

    static let identifier = "GroupDetailTVCell"

    @IBOutlet weak var labelIntencity: UILabel!
    @IBOutlet weak var labelPowerTitle: UILabel!
    @IBOutlet weak var switchPowerOnOFF: UISwitch!
    @IBOutlet weak var sepratorView: UIView!
    @IBOutlet weak var slider: SectionedSlider!
    @IBOutlet weak var stackViewSwitch: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        sepratorView.backgroundColor = UIColor.blueHeadingAlpha10

        labelIntencity.font = UIFont.Poppins.medium(11.3)
        labelIntencity.textColor = UIColor.black
        labelIntencity.numberOfLines = 2
        labelIntencity.text = localizeFor("set_Intensity")
        
        labelPowerTitle.font = UIFont.Poppins.medium(11.3)
        labelPowerTitle.textColor = UIColor.black
        labelPowerTitle.numberOfLines = 2
        labelPowerTitle.text = localizeFor("power")
        
        slider.sections = 5

        slider.sliderBackgroundColor = UIColor.sliderUnSelected
        slider.sliderColor = UIColor.blueSwitch
        slider.viewBackgroundColor = UIColor.white
        
        slider.isHidden = true
        labelIntencity.isHidden = true
        stackViewSwitch.isHidden = true
        
        
        switchPowerOnOFF.isOn = false
        switchPowerOnOFF.dooDefaultSetup()
        switchPowerOnOFF.changeSwitchThumbColorBasedOnState()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func hideSwitchButton(isHidden:Bool=false){
        stackViewSwitch.isHidden = isHidden
    }
    
    func hideFanSliderAndTitle(isHidden:Bool=false){
        labelIntencity.isHidden = isHidden
        slider.isHidden = isHidden
    }
}

extension GroupDetailTVCell {
    func cellConfig(statusOnOff: Bool, speedValue:Int) {
        slider.selectedSection = speedValue
        switchPowerOnOFF.setOn(statusOnOff, animated: true)
        switchPowerOnOFF.changeSwitchThumbColorBasedOnState()
    }
}
