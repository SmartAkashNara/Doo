//
//  SmartSceneIconCVCell.swift
//  Doo-IoT
//
//  Created by Akash Nara on 28/01/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit

class SmartSceneIconCVCell: UICollectionViewCell {

    static let identifier = "SmartSceneIconCVCell"
    @IBOutlet weak var imageViewLogo: UIImageView!
    @IBOutlet weak var viewCard: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        viewCard.backgroundColor = UIColor.blueHeadingAlpha06
        viewCard.cornerRadius = 6.7
        viewCard.borderColor = UIColor.blueSwitch
    }
    
    func cellConfig(imageIconName:String, isSelected:Bool) {
        imageViewLogo.sd_setImage(with: URL(string: imageIconName), placeholderImage: nil, options: .continueInBackground, context: nil)
        viewCard.borderWidth = isSelected ? 1.3 : 0.0
    }
}
