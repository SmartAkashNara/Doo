//
//  SearchCountryHeaderTVCell.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 27/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class DooTitleDownHeaderTVCell_1: UITableViewCell {
    
    static let identifier = "DooTitleDownHeaderTVCell_1"
    @IBOutlet weak var labelHeader: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

// Country Seleciton
extension DooTitleDownHeaderTVCell_1 {
    
       func countryHeaderConfig(data: String) {
           
           labelHeader.font = UIFont.Poppins.regular(14)
           labelHeader.textColor = UIColor.blueHeadingAlpha50
           
           labelHeader.text = data
       }
}
