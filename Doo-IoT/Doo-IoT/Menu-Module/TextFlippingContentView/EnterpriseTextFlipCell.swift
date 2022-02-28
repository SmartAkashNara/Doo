//
//  EnterpriseTextFlipCell.swift
//  Doo-IoT
//
//  Created by Akash Nara on 26/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class EnterpriseTextFlipCell: UITableViewCell {
    
    static let identifier: String = "EnterpriseTextFlipCell"
    @IBOutlet weak var labelEnterPrise: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        labelEnterPrise.textColor = UIColor(named: "menuLabelTextColor")
        labelEnterPrise.font = UIFont.Poppins.medium(13)
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        self.separator(hide: true)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

