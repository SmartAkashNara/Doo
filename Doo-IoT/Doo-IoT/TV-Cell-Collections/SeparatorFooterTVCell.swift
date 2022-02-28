//
//  SeparatorFooterTVCell.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 10/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class SeparatorFooterTVCell: UITableViewCell {

    static let identifier = "SeparatorFooterTVCell"
    static let cellHeight: CGFloat = 11
    @IBOutlet weak var viewBottomSeparator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        viewBottomSeparator.backgroundColor = UIColor.blueHeadingAlpha10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
