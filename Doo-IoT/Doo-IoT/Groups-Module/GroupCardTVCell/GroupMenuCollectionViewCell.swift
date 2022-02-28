//
//  GroupMenuCollectionViewCell.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 19/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class GroupMenuCollectionViewCell: UICollectionViewCell {

    static let identifier = "GroupMenuCollectionViewCell"
    
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var seprator: UIView!
    @IBOutlet weak var labelGroupName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        labelGroupName.numberOfLines = 1
        labelGroupName.font = UIFont.Poppins.medium(12)
        labelGroupName.textColor = UIColor.blueHeadingAlpha30
        seprator.cornerRadius = 2.3
    }
    
    func cellConfig(data: GroupDataModel) {
        labelGroupName.text = data.name
        setSelected(isSelected: false)
    }
    func setSelected(isSelected:Bool){
        labelGroupName.textColor = isSelected ? UIColor.greenInvited : UIColor.blueHeadingAlpha30
        seprator.backgroundColor = isSelected ? UIColor.greenInvited : UIColor.clear

    }

}
