//
//  DooCollectionTag_1CVCell.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 11/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class DooCollectionTag_1CVCell: UICollectionViewCell {

    static let identifier = "DooCollectionTag_1CVCell"
    @IBOutlet weak var buttonTag: UIButton!
    
    static private let topBottomSpace: CGFloat = 6.5
    static private let leftRightSpace: CGFloat = 10

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // button text height 17 for UIFont.Poppins.medium(12)
        // 17 + 6.5 + 6.5 = 30
        buttonTag.contentEdgeInsets = UIEdgeInsets(top: DooCollectionTag_1CVCell.topBottomSpace,
                                                   left: DooCollectionTag_1CVCell.leftRightSpace,
                                                   bottom: DooCollectionTag_1CVCell.topBottomSpace,
                                                   right: DooCollectionTag_1CVCell.leftRightSpace)
        buttonTag.titleLabel?.font = UIFont.Poppins.medium(12)
        buttonTag.setTitleColor(UIColor.blueSwitch, for: .normal)
        buttonTag.backgroundColor = UIColor.blueSwitchAlpha10
        buttonTag.cornerRadius = 6.7
        buttonTag.isUserInteractionEnabled = false
    }

    func cellConfig(title: String, disable: Bool = false) {
        buttonTag.setTitle(title, for: .normal)
        contentView.alpha = disable ? 0.5 : 1.0
    }
    
    static func getCellSize(tag: String) -> CGSize {
//        let labelWidth = tag.sized(UIFont.Poppins.medium(12)).width
        let labelWidth = tag.toNSString.size(withAttributes: [NSAttributedString.Key.font : UIFont.Poppins.medium(12)]).width
        let space: CGFloat = leftRightSpace * 2
        return CGSize(width: labelWidth + space, height: 44)
    }
}
