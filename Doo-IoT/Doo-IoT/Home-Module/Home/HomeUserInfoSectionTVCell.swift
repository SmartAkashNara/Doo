//
//  HomeUserInfoSectionTVCell.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 24/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class HomeUserInfoSectionTVCell: UITableViewCell {

    static let identifier = "HomeUserInfoSectionTVCell"
    static let cellHeight: CGFloat = 46 //77
    static let cellHeightGroup: CGFloat = 65
    
    @IBOutlet weak var labelDevicesActive: UILabel!
    @IBOutlet weak var labelGatewayStatusTitle: UILabel!
    @IBOutlet weak var labelGatewayStatusValue: UILabel!
    @IBOutlet weak var viewSeparator: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = UIColor.graySceneCard
        
        labelDevicesActive.font = UIFont.Poppins.regular(12)
        labelDevicesActive.textColor = UIColor.grayOffDevice
        labelGatewayStatusTitle.font = UIFont.Poppins.medium(13)
        labelGatewayStatusTitle.textColor = UIColor.blueHeading
        labelGatewayStatusValue.font = UIFont.Poppins.medium(13)
        labelGatewayStatusValue.textColor = UIColor.redOffline
        viewSeparator.backgroundColor = UIColor.blueHeading.withAlphaComponent(0.15)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func cellConfig(totalNoOfActiveDevices: Int, gatewayStatus: Bool) {
        UIView.performWithoutAnimation {
            if totalNoOfActiveDevices > 1 {
                setNoOfDevicesActiveInGateway("\(totalNoOfActiveDevices) \(localizeFor("devices_active"))")
            }else{
                setNoOfDevicesActiveInGateway("\(totalNoOfActiveDevices) \(localizeFor("device_active"))")
            }
            
            setGatewayStatus(gatewayStatus ? localizeFor("online") : localizeFor("offline"))
            labelGatewayStatusValue.textColor = gatewayStatus ? .greenInvited : .redOffline
            labelDevicesActive.isHidden = true
            self.layoutIfNeeded()
        }
    }
    
    func setNoOfDevicesActiveInGateway(_ value: String) {
        if labelDevicesActive.text != value {
            labelDevicesActive.text = value
        }
    }
    
    func setGatewayStatus(_ value: String) {
        if labelGatewayStatusValue.text != value {
            labelGatewayStatusTitle.text = "\(localizeFor("gateway_status")) :"
            labelGatewayStatusValue.text = value
        }
    }

    func cellConfigForGroup() {
        viewSeparator.isHidden = true
    }
    
}
