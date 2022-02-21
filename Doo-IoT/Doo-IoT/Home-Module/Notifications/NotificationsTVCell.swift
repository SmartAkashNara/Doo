//
//  NotificationsListTVCell.swift
//  Doo-IoT
//
//  Created by Shraddha on 24/08/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit

class NotificationsTVCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var viewMainContent: UIView!
    @IBOutlet weak var viewNotificationBullet: UIView!
    @IBOutlet weak var labelNotificationTitle: UILabel!
    @IBOutlet weak var viewSeperatorDotGrey: UIView!
    @IBOutlet weak var labelNotificiationReceivedAgoDetails: UILabel!
    @IBOutlet weak var labelNotificationDetails: UILabel!
    @IBOutlet weak var viewNotificationQuickAction: UIView!
    @IBOutlet weak var buttonSingleNotificationOption: UIButton!
    @IBOutlet weak var viewSeperator: UIView!
    
    // MARK: - Variable Declaration
    static let identifier: String = "NotificationsTVCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        
        // Blue bullet icon on each notification
        self.viewNotificationBullet.backgroundColor = UIColor.blueSwitch
        self.viewNotificationBullet.cornerRadius = 2
        
        // label title
        self.labelNotificationTitle.text = ""
        self.labelNotificationTitle.font = UIFont.Poppins.medium(10)
        self.labelNotificationTitle.textColor = UIColor.blueHeadingAlpha60
        self.labelNotificationTitle.numberOfLines = 1
        self.labelNotificationTitle.textAlignment = .left
        
        // Seperator dot between notifications title and notifications received ago details labels
        self.viewSeperatorDotGrey.backgroundColor = UIColor.blueHeadingAlpha60
        self.viewSeperatorDotGrey.cornerRadius = self.viewSeperatorDotGrey.frame.height / 2
        
        // label notification received ago details
        self.labelNotificiationReceivedAgoDetails.text = ""
        self.labelNotificiationReceivedAgoDetails.font = UIFont.Poppins.medium(10)
        self.labelNotificiationReceivedAgoDetails.textColor = UIColor.blueHeadingAlpha60
        self.labelNotificiationReceivedAgoDetails.numberOfLines = 1
        self.labelNotificiationReceivedAgoDetails.textAlignment = .left
        
        // label notification details
        self.labelNotificationDetails.numberOfLines = 0
        self.labelNotificationDetails.lineBreakMode = .byWordWrapping
        
        // bottom line seperator
        self.viewSeperator.backgroundColor = UIColor.blueHeadingAlpha06
        
        // kept hidden for sept launch
        self.viewNotificationQuickAction.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func cellConfig(notifDataModel: NotificationsDataModel) {
        self.labelNotificationTitle.text = notifDataModel.title
        self.labelNotificiationReceivedAgoDetails.text = notifDataModel.receivedDate
        self.labelNotificationDetails.attributedText = notifDataModel.descriptionHtml
    }
}
