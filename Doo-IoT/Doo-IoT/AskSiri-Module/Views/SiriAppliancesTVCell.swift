//
//  DooTree_1TVCell.swift
//  InfinityTree
//
//  Created by Kiran Jasvanee on 10/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class SiriAppliancesTVCell: UITableViewCell {
    
    static let identifier: String = "SiriAppliancesTVCell"
    
    @IBOutlet weak var viewSeparator: UIView!
    @IBOutlet weak var leftConstraintToContent: NSLayoutConstraint!
    @IBOutlet weak var labelTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        selectionStyle = .none
        viewSeparator.backgroundColor = UIColor.black.withAlphaComponent(0.14)
        viewSeparator.layer.cornerRadius = 0.3
        labelTitle.font = UIFont.Poppins.medium(13.3)
        labelTitle.textColor = UIColor.blueHeading
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension SiriAppliancesTVCell {
    func cellConfig(data: TargetApplianceDataModel) {
        labelTitle.text = data.applianceName
    }
}
