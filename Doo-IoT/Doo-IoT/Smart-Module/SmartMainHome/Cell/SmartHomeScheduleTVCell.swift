//
//  SmartHomeScheduleTVCell.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 27/05/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class SmartHomeScheduleTVCell: UITableViewCell {
    
    enum EnumCellType:Int {
        case bindingRule, schedule
    }
    static let identifier = "SmartHomeScheduleTVCell"
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubTitle: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelCount: UILabel!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var switchOnOFF: DooSwitch!
    @IBOutlet weak var viewbackground: UIView!
    @IBOutlet weak var labelRepeat: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        
        labelTitle.font = UIFont.Poppins.semiBold(12)
        labelTitle.textColor = UIColor.blueSwitch
        labelTitle.numberOfLines = 2
        
        labelSubTitle.font = UIFont.Poppins.regular(11)
        labelSubTitle.textColor = UIColor.graySubTile
        labelSubTitle.numberOfLines = 2
        
        labelTime.font = UIFont.Poppins.medium(13.3)
        labelTime.textColor = UIColor.blueHeading
        // labelTime.numberOfLines = 2
        
        labelCount.font = UIFont.Poppins.regular(11)
        labelCount.textColor = UIColor.blueHeading
        labelCount.numberOfLines = 2
        
        labelRepeat.font = UIFont.Poppins.regular(11)
        labelRepeat.textColor = UIColor.blueHeadingAlpha50
        labelRepeat.textAlignment = .right
        // labelRepeat.numberOfLines = 2
        
        image1.isHidden = true
        image2.isHidden = true
        image3.isHidden = true
        labelCount.isHidden = true
        
        image1.cornerRadius = 6.7
        image2.cornerRadius = 6.7
        image3.cornerRadius = 6.7
        
        image1.backgroundColor = .white
        image2.backgroundColor = .white
        image3.backgroundColor = .white
        
        if image1.image == nil{
            image1.backgroundColor = UIColor.blueSwitchAlpha10
        }
        if image2.image == nil{
            image2.backgroundColor = UIColor.blueSwitchAlpha10
        }
        if image3.image == nil{
            image3.backgroundColor = UIColor.blueSwitchAlpha10
        }
        
//        image1.setImageIcon(image: #imageLiteral(resourceName: "imgLightOff"))
//        image2.setImageIcon(image: #imageLiteral(resourceName: "imgLightOff"))
//        image3.setImageIcon(image: #imageLiteral(resourceName: "imgLightOff"))
        
        labelCount.text = "3+"
        labelTitle.text = "Light binding binding binding binding binding binding binding"
        labelSubTitle.text = "100000 Target Appliances"
        labelRepeat.text = "12 Jan 2020"
        
        viewbackground.backgroundColor = UIColor.blueSwitchAlpha10
        viewbackground.cornerRadius = 6.7
        viewbackground.clipsToBounds = true
        labelTime.text = ""
    }
    
    func getRandomBackColor(position: Int) -> UIColor {
        let arrayColor = [UIColor.blueSwitchAlpha08, UIColor.greenInvitedAlpha08, UIColor.orangeScanIndicatorAlpha08]
        return arrayColor[position % 3]
    }
}

extension SmartHomeScheduleTVCell {
    func cellConfigWithBindingRuleDataModel(object:SRBindingRuleDataModel){
        
        viewbackground.backgroundColor = getRandomBackColor(position: 0)
        if object.enable {
            switchOnOFF.setOnSwitch()
        }else{
            switchOnOFF.setOffSwitch()
        }
        
       
        let deviceCount = object.arrayTargetApplience.count //object.totalDeviceCount
        var totalCountWithPlusSign = "\(deviceCount)"//"\(object.totalDeviceCount)"
        labelTitle.text = object.bindingRuleName
        labelSubTitle.text = object.targetApplienceCount
        
        if deviceCount >= 3{
            image1.isHidden = false
            image2.isHidden = false
            image3.isHidden = false
            totalCountWithPlusSign = "+\(deviceCount)"
            
        }else if deviceCount == 2 {
            image1.isHidden = false
            image2.isHidden = false
            image3.isHidden = true
            totalCountWithPlusSign = ""
        }else if deviceCount == 1 {
            image1.isHidden = false
            image2.isHidden = true
            image3.isHidden = true
            totalCountWithPlusSign = ""
        }else{
            image1.isHidden = true
            image2.isHidden = true
            image3.isHidden = true
            totalCountWithPlusSign = ""
        }
        
        if image1.image == nil{
            image1.backgroundColor = UIColor.blueSwitchAlpha10
        }
        if image2.image == nil{
            image2.backgroundColor = UIColor.blueSwitchAlpha10
        }
        if image3.image == nil{
            image3.backgroundColor = UIColor.blueSwitchAlpha10
        }
        
        labelCount.text = totalCountWithPlusSign
        labelRepeat.text = ""
        labelRepeat.isHidden = true
        labelTime.text = object.fullTime
        
        if object.startTime.isEmpty && object.endTime.isEmpty{
            labelTime.isHidden = true
        }else{
            labelTime.isHidden = false
        }
    }
    
    
    func cellConfigWithSchedulerDataModel(object: SRSchedulerDataModel, position: Int, arrayCount: Int){
        if arrayCount > 3 {
            viewbackground.backgroundColor = getRandomBackColor(position: position)
        } else {
            viewbackground.backgroundColor = UIColor.blueSwitchAlpha08
        }
    
        if object.enable {
            switchOnOFF.setOnSwitch()
        } else {
            switchOnOFF.setOffSwitch()
        }
        let deviceCount = object.arrayTargetApplience.count //object.totalDeviceCount
        var totalCountWithPlusSign = "\(deviceCount)"//"\(object.totalDeviceCount)"
        labelTitle.text = object.schedulerName
        labelSubTitle.text = object.targetApplienceCount
        
        if deviceCount >= 3{
            image1.isHidden = false
            image2.isHidden = false
            image3.isHidden = false
            labelCount.isHidden = false
            totalCountWithPlusSign = deviceCount > 3 ? "+\(deviceCount-3)" : ""
            self.image1.sd_setImage(with: URL(string: object.arrayTargetApplience[0].applianceImage), placeholderImage: nil, options: .continueInBackground, context: nil)
            self.image2.sd_setImage(with: URL(string: object.arrayTargetApplience[1].applianceImage), placeholderImage: nil, options: .continueInBackground, context: nil)
            self.image3.sd_setImage(with: URL(string: object.arrayTargetApplience[2].applianceImage), placeholderImage: nil, options: .continueInBackground, context: nil)
        }else if deviceCount == 2{
            image1.isHidden = false
            image2.isHidden = false
            image3.isHidden = true
            totalCountWithPlusSign = ""
            self.image1.sd_setImage(with: URL(string: object.arrayTargetApplience[0].applianceImage), placeholderImage: nil, options: .continueInBackground, context: nil)
            self.image2.sd_setImage(with: URL(string: object.arrayTargetApplience[1].applianceImage), placeholderImage: nil, options: .continueInBackground, context: nil)
        }else if deviceCount == 1{
            image1.isHidden = false
            image2.isHidden = true
            image3.isHidden = true
            totalCountWithPlusSign = ""
            self.image1.sd_setImage(with: URL(string: object.arrayTargetApplience[0].applianceImage), placeholderImage: nil, options: .continueInBackground, context: nil)
        }else{
            image1.isHidden = true
            image2.isHidden = true
            image3.isHidden = true
            totalCountWithPlusSign = ""
        }
        if image1.image == nil{
            image1.backgroundColor = UIColor.blueSwitchAlpha10
        }
        if image2.image == nil{
            image2.backgroundColor = UIColor.blueSwitchAlpha10
        }
        if image3.image == nil{
            image3.backgroundColor = UIColor.blueSwitchAlpha10
        }
        labelCount.text = totalCountWithPlusSign
        labelRepeat.isHidden = false
        labelTime.text = object.scheduleTime
        
        if object.scheduleTime.isEmpty{
            labelTime.isHidden = true
        }else{
            labelTime.isHidden = false
        }
        
        self.switchOnOFF.isHidden = object.viewEditMode.rawValue == 1 ? false : true
        
        switch object.enumEnumScheduleType {
        case .daily:
            labelRepeat.text = object.enumEnumScheduleType.title
            labelTime.text = object.scheduleTime
            labelTime.isHidden = false
        case .once:
            labelRepeat.text = object.scheduleDate.getDate(format: .eee_dd_mmm_yyyy_hh_mm_ss_z)?.getDateInString(withFormat: .ddSpaceMMspaceYYYY)
        case .custom:
            labelTime.text = object.scheduleTime
            labelTime.isHidden = false

            if object.rangeOfScheduledDays.count > 0 {
                let attributedString = Weekdays.getAllWeekdaysInitials().attributedStringWithColor(
                    color: UIColor.blueSwitch,
                    font: UIFont.Poppins.medium(11),
                    arrayRange: object.rangeOfScheduledDays)
                labelRepeat.attributedText = attributedString
            } else {
                labelRepeat.text = ""
            }
        }
    }
}
