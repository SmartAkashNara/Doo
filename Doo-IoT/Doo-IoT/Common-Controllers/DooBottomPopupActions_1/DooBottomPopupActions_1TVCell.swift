//
//  DooBottomPopupActions_1TVCell.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 09/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class DooBottomPopupActions_1TVCell: UITableViewCell {
    
    static let identifier: String = "DooBottomPopupActions_1TVCell"
    
    @IBOutlet weak var labelActionTitle: UILabel!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        labelActionTitle.numberOfLines = 2
        labelActionTitle.lineBreakMode = .byWordWrapping
        labelActionTitle.font = UIFont.Poppins.medium(13.3)
    }
    
    func setSpaceConstraint(gap: Double) {
        self.topConstraint.constant = CGFloat(gap/2)
        self.bottomConstraint.constant = CGFloat(gap/2)
    }
    
    func cellConfig(popupOption: DooBottomPopupActions_1ViewController.PopupOption) {
        self.labelActionTitle.text = popupOption.title
        self.labelActionTitle.textColor = popupOption.color
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
