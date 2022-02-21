//
//  SmartHomeSectionTVCell.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 27/05/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class SmartHomeSectionTVCell: UITableViewCell {

    static let identifier = "SmartHomeSectionTVCell"

    @IBOutlet weak var labelSectionName: UILabel!
    @IBOutlet weak var buttonPlus: UIButton!
    @IBOutlet weak var buttonDots: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none

        labelSectionName.font = UIFont.Poppins.semiBold(12)
        labelSectionName.textColor = UIColor.blueHeading
        labelSectionName.numberOfLines = 2
    }
}

extension SmartHomeSectionTVCell {
    func cellConfig(title: String) {
        labelSectionName.text = title
    }
    
    func cellConfigForSiri(title: String) {
        labelSectionName.text = title
        labelSectionName.font = UIFont.Poppins.medium(13.3)
        labelSectionName.textColor = UIColor.blueSwitch
        labelSectionName.numberOfLines = 2
    }
}
