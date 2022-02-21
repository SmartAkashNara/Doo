//
//  TabCVCell.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 27/05/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class TabCVCell: UICollectionViewCell {

    static let identifier = "TabCVCell"
    static let cellHeight: CGFloat = 50

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var viewIndicator: UIView!
    
    var tabSelected: Bool = false { didSet { viewIndicator.isHidden = tabSelected } }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        labelTitle.font = UIFont.Poppins.medium(14)
        labelTitle.textColor = UIColor.blueHeading
        
        viewIndicator.cornerRadius = 2.3
        viewIndicator.backgroundColor = UIColor.greenInvited
    }
}

extension TabCVCell {
    func cellConfig(data: GroupDataModel) {
        labelTitle.text = data.name
        tabSelected = data.tabSelected ?? false
    }
}
