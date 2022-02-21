//
//  EnterpriseTitleTVCellCell.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 07/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class EnterpriseTitleTVCell: UITableViewCell {

    @IBOutlet weak var imageViewLogo: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var buttonRightIcon: UIButton!
    @IBOutlet weak var controlMain: UIControl!
    @IBOutlet weak var stackViewRightButton: UIStackView!
    
    static let identifier = "EnterpriseTitleTVCell"
    
    enum EnumCellType {
        case plain, selected, rightArrow, selectedTopRightTick
    }
    
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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
    func setLayoutByEnumOptionSelected(cellType: EnumCellType) {
        switch cellType {
        case .plain:
            buttonRightIcon.isHidden = true
            controlMain.backgroundColor = UIColor.white
            controlMain.borderWidth = 1.3
        case .selected:
            buttonRightIcon.isHidden = true
            controlMain.backgroundColor = UIColor.blueSwitchAlpha10
            controlMain.borderWidth = 0
        case .rightArrow:
            buttonRightIcon.isHidden = false
            buttonRightIcon.setImage(UIImage(named: "rightArrowLightGray"), for: .normal)
            buttonRightIcon.contentVerticalAlignment = .center
            buttonRightIcon.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 14)
            controlMain.backgroundColor = UIColor.white
            controlMain.borderWidth = 1.3
        case .selectedTopRightTick:
            buttonRightIcon.isHidden = false
            buttonRightIcon.setImage(UIImage(named: "imgTickTopRight"), for: .normal)
            buttonRightIcon.contentVerticalAlignment = .top
            buttonRightIcon.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            controlMain.backgroundColor = UIColor.blueSwitchAlpha10
            controlMain.borderWidth = 0
        }
    }
}

// Single enterprise menu options
extension EnterpriseTitleTVCell {
    func singleEnterpriseMenuCellConfig(cellType: EnumCellType, data: ManageEnterpriseViewController.Menu) {
        self.setLayoutByEnumOptionSelected(cellType: cellType)
        labelName.text = data.name
        imageViewLogo.image = UIImage(named: data.image)
    }
}

// List of enterprises
extension EnterpriseTitleTVCell {
    func entepriseCellConfig(cellType: EnumCellType, data: EnterpriseModel) {
        self.setLayoutByEnumOptionSelected(cellType: cellType)
        labelName.text = data.name
        imageViewLogo.image = UIImage(named: "imgEnterpriseDetail")
    }
}

// Single enterprise menu options
extension EnterpriseTitleTVCell {
    func singleApplianceMgnOption(cellType: EnumCellType, data: ApplianceMgntOptionsViewModel.Menu) {
        self.setLayoutByEnumOptionSelected(cellType: cellType)
        labelName.text = data.name
        imageViewLogo.image = UIImage(named: data.image)
    }
}
