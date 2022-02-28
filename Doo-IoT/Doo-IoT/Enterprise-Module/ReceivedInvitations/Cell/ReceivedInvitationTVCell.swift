//
//  ReceivedInvitationTVCell.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 13/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class ReceivedInvitationTVCell: UITableViewCell {
    
    static let identifier: String = "ReceivedInvitationTVCell"
    
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubTitle: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var buttonAccept: TableButton!
    @IBOutlet weak var buttonReject: TableButton!
    
    @IBOutlet weak var viewVerticalSeparator: UIView!
    @IBOutlet weak var viewHorizontalSeparator: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.labelTitle.font = UIFont.Poppins.semiBold(14.7)
        self.labelTitle.textColor = UIColor.blueHeading
            
        self.labelSubTitle.font = UIFont.Poppins.regular(10)
        self.labelSubTitle.textColor = UIColor.blueHeading
        
        self.labelTime.font = UIFont.Poppins.regular(8)
        self.labelTime.textColor = UIColor.blueHeading
        
        self.buttonAccept.titleLabel?.font = UIFont.Poppins.medium(10)
        self.buttonAccept.setTitleColor(UIColor.blueSwitch, for: .normal)
        self.buttonAccept.setTitle(cueAlert.Button.accept, for: .normal)
        self.buttonAccept.borderColor = UIColor.blueSwitchAlpha10
        self.buttonAccept.borderWidth = 1.3
        
        self.buttonReject.titleLabel?.font = UIFont.Poppins.medium(10)
        self.buttonReject.setTitleColor(UIColor.redButtonColor, for: .normal)
        self.buttonReject.setTitle(cueAlert.Button.reject, for: .normal)
        self.buttonReject.borderColor = UIColor.blueSwitchAlpha10
        self.buttonReject.borderWidth = 1.3
        
        self.viewMain.borderColor = UIColor.blueSwitchAlpha10
        self.viewMain.borderWidth = 1.3
        self.viewMain.cornerRadius = 6.0
        
        self.viewVerticalSeparator.backgroundColor = UIColor.blueSwitchAlpha10
        self.viewHorizontalSeparator.backgroundColor = UIColor.blueSwitchAlpha10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func cellConfig(_ enterprise: ReceivedInvitationDataModel) {
        self.labelTitle.text = enterprise.name
        self.labelSubTitle.text = enterprise.location
        self.labelTime.text = enterprise.invitationTime
     }
}
