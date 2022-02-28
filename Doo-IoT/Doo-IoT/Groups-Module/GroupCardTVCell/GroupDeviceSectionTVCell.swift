//
//  GroupDeviceSectionTVCell.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 27/05/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class GroupDeviceSectionTVCell: UITableViewCell {

    static let identifier = "GroupDeviceSectionTVCell"

    @IBOutlet weak var labelGroupName: UILabel!
    @IBOutlet weak var buttonPlus: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        labelGroupName.font = UIFont.Poppins.semiBold(11)
        labelGroupName.textColor = UIColor.blueHeading
        labelGroupName.numberOfLines = 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension GroupDeviceSectionTVCell {
    func cellConfig(title: String) {
        labelGroupName.font = UIFont.Poppins.semiBold(12.7)
        labelGroupName.text = title
    }
}
