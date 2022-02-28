//
//  YECurrentlySelectedEnterpriseHeader.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 08/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class YECurrentlySelectedEnterpriseHeader: UITableViewCell {
    
    static let identifier = "YECurrentlySelectedEnterpriseHeader"
    static let cellHeightWithCurrentEnterprise: CGFloat = 134
    static let cellHeightWithoutCurrentEnterprise: CGFloat = 97
    
    @IBOutlet weak var imageViewLogo: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var buttonRightIcon: UIButton!
    @IBOutlet weak var controlMain: UIControl!
    @IBOutlet weak var stackViewRightButton: UIStackView!
    @IBOutlet weak var labelHeaderTitleTop: UILabel!
    @IBOutlet weak var labelHeaderTitleBottom: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        labelName.font = UIFont.Poppins.medium(12)
        labelName.textColor = UIColor.blueHeading
        imageViewLogo.contentMode = .scaleToFill
        controlMain.borderColor = UIColor.blueHeadingAlpha10
        controlMain.layer.cornerRadius = 12
        stackViewRightButton.isUserInteractionEnabled = false
        
        buttonRightIcon.isHidden = false
        buttonRightIcon.setImage(UIImage(named: "rightArrowLightGray"), for: .normal)
        buttonRightIcon.contentVerticalAlignment = .center
        buttonRightIcon.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 14)
        controlMain.backgroundColor = UIColor.blueSwitchAlpha10
        
        labelHeaderTitleTop.font = UIFont.Poppins.medium(12)
        labelHeaderTitleTop.textColor = UIColor.blueHeading
        
        labelHeaderTitleBottom.font = UIFont.Poppins.medium(12)
        labelHeaderTitleBottom.textColor = UIColor.blueHeading
        
        contentView.backgroundColor = UIColor.white
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension YECurrentlySelectedEnterpriseHeader {
    func cellConfigYourEnterprices(data: EnterpriseModel) {
        labelHeaderTitleTop.text = localizeFor("current_selected")
        labelHeaderTitleBottom.text = localizeFor("other_enterprises")
        imageViewLogo.image = UIImage(named: "imgEnterpriseDetail")
        labelName.text = data.name
    }
}
