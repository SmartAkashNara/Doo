//
//  DooTree_1TVCell.swift
//  InfinityTree
//
//  Created by Kiran Jasvanee on 10/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class DooTree_1TVCell: UITableViewCell {
    
    enum VisibilityType {
        case privileges, userDetail, enterpriseGroup
    }
    
    static let identifier: String = "DooTree_1TVCell"
    
    @IBOutlet weak var viewSeparator: UIView!
    @IBOutlet weak var leftConstraintToContent: NSLayoutConstraint!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var buttonCheckmark: ButtonOfInfinityTree!
    @IBOutlet weak var dropdownArrowView: UIImageView!
    
    var visibilityType: VisibilityType = .enterpriseGroup

    var checked: Bool = false {
        didSet {
            buttonCheckmark.setImage(UIImage(named: checked ? "marked_1" : "unmarked_1"), for: .normal)
        }
    }
    
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
    
    func setThemeBasedOn(visibilityType: VisibilityType) {
        switch visibilityType {
        case .enterpriseGroup:
            self.buttonCheckmark.isHidden = false
            self.dropdownArrowView.isHidden = true
        case .privileges:
            self.buttonCheckmark.isHidden = false
            self.dropdownArrowView.isHidden = false
        case .userDetail:
            self.buttonCheckmark.isHidden = true
            self.dropdownArrowView.isHidden = false
        }
    }
    
}

extension DooTree_1TVCell {
    func commonDecisions(_ isContainsChilds: Bool, _ isExpanded: Bool) {
        if isContainsChilds {
            self.dropdownArrowView.isHidden = false
            if isExpanded {
                self.dropdownArrowView.image = UIImage(named: "grayuparrow")
            }else{
                self.dropdownArrowView.image = UIImage(named: "graydownarrow")
            }
        }else{
            self.dropdownArrowView.isHidden = true
        }
    }
}

extension DooTree_1TVCell {
    func cellConfig(forEnterpriseUser privilege: UserPrivilegeDataModel, deepAtLevel: Int, isContainsChilds: Bool, isExpanded: Bool) {
        self.setThemeBasedOn(visibilityType: .userDetail)
        self.labelTitle.text = privilege.title
        
        let calculateLeading = deepAtLevel * 20
        self.leftConstraintToContent.constant = CGFloat(calculateLeading + 13)
        
        self.commonDecisions(isContainsChilds, isExpanded)
    }
}

extension DooTree_1TVCell {
    func cellConfig(value: UserPrivilegeDataModel, deepAtLevel: Int, marked: Bool, isContainsChilds: Bool, isExpanded: Bool) {
        self.setThemeBasedOn(visibilityType: .privileges)
        
        self.labelTitle.text = value.title
        if marked {
            self.buttonCheckmark.setImage(UIImage(named: "marked_1"), for: .normal)
        }else{
            self.buttonCheckmark.setImage(UIImage(named: "unmarked_1"), for: .normal)
        }
        
        self.commonDecisions(isContainsChilds, isExpanded)
        
        let calculateLeading = (deepAtLevel-1) * 20
        self.leftConstraintToContent.constant = CGFloat(calculateLeading)
    }
    
    func cellConfig(deviceDetail value: DeviceDataModel, deepAtLevel: Int, marked: Bool, isContainsChilds: Bool, isExpanded: Bool) {
        self.setThemeBasedOn(visibilityType: .privileges)
        
        self.labelTitle.text = value.deviceName
        if marked {
            self.buttonCheckmark.setImage(UIImage(named: "marked_1"), for: .normal)
        }else{
            self.buttonCheckmark.setImage(UIImage(named: "unmarked_1"), for: .normal)
        }
        
        self.commonDecisions(isContainsChilds, isExpanded)
        
        let calculateLeading = (deepAtLevel-1) * 20
        self.leftConstraintToContent.constant = CGFloat(calculateLeading)
    }
    
    func cellConfig(deviceApplinceDetail value: ApplianceDataModel, deepAtLevel: Int, marked: Bool, isContainsChilds: Bool, isExpanded: Bool) {
        self.setThemeBasedOn(visibilityType: .privileges)
        
        self.labelTitle.text = value.applianceName
        if marked {
            self.buttonCheckmark.setImage(UIImage(named: "marked_1"), for: .normal)
        }else{
            self.buttonCheckmark.setImage(UIImage(named: "unmarked_1"), for: .normal)
        }
        
        self.commonDecisions(isContainsChilds, isExpanded)
        
        let calculateLeading = (deepAtLevel-1) * 20
        self.leftConstraintToContent.constant = CGFloat(calculateLeading)
    }


}

extension DooTree_1TVCell {
    func cellConfig(data: EnterpriseGroup) {
        buttonCheckmark.isUserInteractionEnabled = false
        setThemeBasedOn(visibilityType: .enterpriseGroup)
        labelTitle.text = data.name
        checked = data.checked
        contentView.alpha = data.groupOfAddTime ? 0.5 : 1.0
    }
}
