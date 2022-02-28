//
//  DeviceApplianceCell.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 09/05/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class DeviceApplianceCell: UITableViewCell {
    
    static let identifier: String = "DeviceApplianceCell"
    
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var viewStatusDot: UIView!
    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var labelApplianceName: UILabel!
    @IBOutlet weak var buttonFav: UIButton!
    @IBOutlet weak var switchStatus: DooSwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none

        imageViewIcon.contentMode = .scaleAspectFill
        
        viewStatusDot.makeRoundByCorners()
        viewStatusDot.backgroundColor = UIColor.greenInvited
        
        labelApplianceName.textColor = UIColor.blueHeading
        labelApplianceName.font = UIFont.Poppins.medium(13.3)
        
        viewMain.backgroundColor = UIColor.blueSwitchAlpha04
        viewMain.cornerRadius = 12
    }
    
    func cellConfig(_ applianceData: ApplianceDataModel, deviceStatus:Bool=false) {
        labelApplianceName.text = applianceData.applianceName
        buttonFav.setImage(UIImage(named: applianceData.isFavourite ? "imgHeartFavouriteFill" : "imgHeartFavouriteUnfill"), for: .normal)
        debugPrint("state of switch enable:",applianceData.accessStatus)
        if applianceData.accessStatus {
            switchStatus.setOnSwitch()
        }else{
            switchStatus.setOffSwitch()
        }
//        viewStatusDot.isHidden = !deviceStatus//true//!applianceData.onOffStatus
        viewStatusDot.backgroundColor = deviceStatus ? UIColor.greenOnline : UIColor.redOffline
        imageViewIcon.setImage(url: applianceData.applianceTypeImage, placeholder: UIImage(named: "appliance_placeholder_icon"))
    }
}
