//
//  AvatarCVCell.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 01/05/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class AvatarCVCell: UICollectionViewCell {

    static let identifier = "AvatarCVCell"
    static let cellSize = CGSize(width: 57, height: 57)

    @IBOutlet weak var imageViewAvatar: UIImageView!
    @IBOutlet weak var imageViewTick: UIImageView!

    var select: Bool = false {
        didSet {
            if select {
                imageViewTick.isHidden = false
                imageViewAvatar.borderWidth = 2
            } else {
                imageViewTick.isHidden = true
                imageViewAvatar.borderWidth = 0
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        clipsToBounds = false
        imageViewTick.image = UIImage(named: "imgTickGreenRound")
        imageViewAvatar.makeRoundByCorners()
        imageViewAvatar.borderColor = UIColor.greenInvited
    }

    func cellConfig(data: ProfileViewModel.DefaultAvatar) {
        imageViewAvatar.setImage(url: data.image, placeholder: cueImage.userPlaceholder)
        select = data.selected
    }
    
}
