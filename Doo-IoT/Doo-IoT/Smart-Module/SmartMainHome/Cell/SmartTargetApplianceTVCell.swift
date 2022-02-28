//
//  SmartTargetApplianceTVCell.swift
//  Doo-IoT
//
//  Created by Akash Nara on 13/01/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit

class SmartTargetApplianceTVCell: UITableViewCell {
    
    enum EnumCellType:Int {
        case bindingRule, schedule, scene
    }
    
    static let identifier = "SmartTargetApplianceTVCell"
    
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var viewbackground: UIView!
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubTitle: UILabel!
    @IBOutlet weak var labelTargetedActionTitle: UILabel!
    @IBOutlet weak var labelTargetedActionValue: UILabel!
    @IBOutlet weak var labelTargetedAccessTitle: UILabel!
    @IBOutlet weak var labelTargetedAccessValue: UILabel!
    @IBOutlet weak var buttonEdit: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        
        labelTitle.font = UIFont.Poppins.semiBold(12)
        labelTitle.textColor = UIColor.blueHeading
        labelTitle.numberOfLines = 2
        
        labelSubTitle.font = UIFont.Poppins.regular(10)
        labelSubTitle.textColor = UIColor.blueHeadingAlpha60
        labelSubTitle.numberOfLines = 2
        
        labelTargetedAccessTitle.font = UIFont.Poppins.regular(10)
        labelTargetedAccessTitle.textColor = UIColor.blueHeading
        labelTargetedAccessTitle.numberOfLines = 1
        
        labelTargetedActionTitle.font = UIFont.Poppins.regular(10)
        labelTargetedActionTitle.textColor = UIColor.blueHeading
        labelTargetedActionTitle.numberOfLines = 1
        
        if image1.image == nil{
            image1.backgroundColor = UIColor.blueSwitchAlpha10
        }
        image1.cornerRadius = 6.7
        image1.backgroundColor = .white
        
        viewbackground.backgroundColor = UIColor.blueSwitchAlpha10
        viewbackground.cornerRadius = 6.7
        viewbackground.clipsToBounds = true
        
        labelTargetedActionTitle.text = localizeFor("target_action_title")
        labelTargetedAccessTitle.text = localizeFor("target_access_title")
        
        labelSubTitle.text = "Dining Area"
        labelTitle.text = "Bedroom AC"
        
        labelTargetedActionValue.text = "ON"
        labelTargetedAccessValue.text = "OFF"
        
    }
    
    func getRandomBackColor() -> UIColor {
        let arrayColor = [UIColor.greenInvitedAlpha08, UIColor.orangeScanIndicatorAlpha08, UIColor.blueSwitchAlpha08]
        return arrayColor.randomElement() ?? UIColor.blueSwitchAlpha08
    }
}

extension SmartTargetApplianceTVCell {
    func cellConfig(title: String, enumCellType: EnumCellType = .bindingRule) {
        
        viewbackground.backgroundColor = getRandomBackColor()
        labelTitle.text = title
        image1.image = #imageLiteral(resourceName: "imgLightOff")
    }
    
    func cellConfig(dataModel: TargetApplianceDataModel) {
        
        viewbackground.backgroundColor = .blueSwitchAlpha08
        labelTitle.text = dataModel.applianceName
        labelSubTitle.text = dataModel.deviceName
        
        self.image1.sd_setImage(with: URL(string: dataModel.applianceImage), placeholderImage: nil, options: .continueInBackground, context: nil)
        if image1.image == nil{
            image1.backgroundColor = UIColor.blueSwitchAlpha10
        }
        labelTargetedAccessValue.text = dataModel.accessDisplay.isEmpty ? localizeFor("na") : dataModel.accessDisplay.uppercased()
        
        labelTargetedActionValue.alpha = 1
        labelTargetedActionValue.backgroundColor = .clear
        
        let enumAppliene = EnumApplianceAction.init(rawValue: dataModel.targetAction)
        switch enumAppliene {
        case .onOff:
            labelTargetedActionTitle.text = localizeFor("target_action_title")
            labelTargetedActionValue.text = dataModel.actionValueDisplay == "" ? "N/A" : dataModel.actionValueDisplay
            labelTargetedActionValue.textColor =  EnumTargetActionValue.init(rawValue: dataModel.targetValue)?.textColor ?? .blueHeading
        case .fan:
            labelTargetedActionTitle.text = "Target Speed"
            labelTargetedActionValue.text = dataModel.fanSppedDisplay == "" ? "N/A" : dataModel.fanSppedDisplay
            labelTargetedActionValue.textColor = .blueHeading
        case .rgb:
            labelTargetedActionTitle.text = "Target Color"
            labelTargetedActionValue.backgroundColor = dataModel.applianceColor
            labelTargetedActionValue.text = "N/A"
            labelTargetedActionValue.textColor = .clear
            labelTargetedActionValue.alpha = 1
        default:
            labelTargetedActionTitle.text = localizeFor("target_action_title")
            break
        }
        
        /*
        if let _ = dataModel.operationsArray.filter({$0 == .fan}).first{
            labelTargetedActionValue.text = dataModel.fanSppedDisplay
            labelTargetedActionValue.textColor = .blueHeading
        }else if let _ = dataModel.operationsArray.filter({$0 == .rgb}).first{
            labelTargetedActionValue.backgroundColor = dataModel.targetValue.getUIColorFromDecimalCode()
        }else{
            labelTargetedActionValue.text = dataModel.actionValueDisplay
            labelTargetedActionValue.textColor =  EnumTargetActionValue.init(rawValue: dataModel.targetValue)?.textColor ?? .blueHeading
        }*/
        labelTargetedAccessValue.textColor = EnumTargetAccess.init(rawValue: dataModel.targetAccess)?.textColor ?? .blueHeading
    }
    
    func setBackgroundCardColor(){
        viewbackground.backgroundColor = UIColor.blueHeadingAlpha06
        
    }
}
