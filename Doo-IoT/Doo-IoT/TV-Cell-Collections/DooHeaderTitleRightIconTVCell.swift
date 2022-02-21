//
//  DooHeaderTitleRightIconTVCell.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 27/05/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class DooHeaderTitleRightIconTVCell: UITableViewCell {

    static let identifier = "DooHeaderTitleRightIconTVCell"
    static let cellHeight: CGFloat = 44

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var buttonRight: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        selectionStyle = .none
        labelTitle.font = UIFont.Poppins.semiBold(13)
        labelTitle.textColor = UIColor.blueHeading
        buttonRight.setImage(UIImage(named: "imgAddBlue"), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension DooHeaderTitleRightIconTVCell {
    func cellConfig(title: String) {
        labelTitle.text = title
    }
}

