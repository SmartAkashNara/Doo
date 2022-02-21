//
//  DooDeviceInfoCell.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 15/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class SettingCell: UITableViewCell {
    
    static let identifier = "SettingCell"
    
    @IBOutlet weak var imageViewDevice: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var viewSeparator: UIView!
    @IBOutlet weak var switchStatus: DooSwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        
        imageViewDevice.contentMode = .scaleAspectFit
        imageViewDevice.cornerRadius = 4
        
        labelName.font = UIFont.Poppins.semiBold(12)
        labelName.textColor = UIColor.blueHeading
        switchStatus.isHidden = true

        viewSeparator.backgroundColor = UIColor.blueHeadingAlpha06
    }
}

extension SettingCell {
    func cellConfig(data:MenuDataModel){
        labelName.text = data.title
        imageViewDevice.image = UIImage.init(named: data.image)
        if data.enable {
            switchStatus.setOnSwitch()
        } else {
            switchStatus.setOffSwitch()
        }
    }
}
