//
//  CountryTVCell.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 27/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class DooTitle_1TVCell: UITableViewCell {

    static let identifier = "DooTitle_1TVCell"
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var viewSeparator: UIView!
    @IBOutlet weak var constraintTopLabel: NSLayoutConstraint!
    @IBOutlet weak var constraintLeadingLabel: NSLayoutConstraint!
    @IBOutlet weak var constraintTrailingLabel: NSLayoutConstraint!
    @IBOutlet weak var constraintLeadingSeparator: NSLayoutConstraint!
    @IBOutlet weak var constraintTrailingSeparator: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none

        commonTheme()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func commonTheme() {
        backgroundColor = UIColor.clear
        
        viewSeparator.backgroundColor = UIColor.black.withAlphaComponent(0.14)
        viewSeparator.layer.cornerRadius = 0.3
        
        labelTitle.font = UIFont.Poppins.medium(13)
        labelTitle.textColor = UIColor.blueHeading
    }
}

// MARK - Country Cell Config
extension DooTitle_1TVCell {
    func cellConfig(withTitle title: String) {
        self.labelTitle.text = title
    }
}

// MARK - Country Cell Config
extension DooTitle_1TVCell {
    func countryTheme() {
        labelTitle.font = UIFont.Poppins.regular(14)
        labelTitle.textColor = UIColor.blueHeading
    }
    
    func constraintSetupBottomView() {
        constraintTopLabel.constant = 10
        constraintLeadingLabel.constant = 20
        constraintTrailingLabel.constant = 0
        constraintLeadingSeparator.constant = 20
        constraintTrailingSeparator.constant = 0
    }


    func constraintSetupCountry() {
        constraintTopLabel.constant = 16
        constraintLeadingLabel.constant = 20
        constraintTrailingLabel.constant = 0
        constraintLeadingSeparator.constant = 20
        constraintTrailingSeparator.constant = 0
    }
    
    func countryCellConfig(data: CountrySelectionViewModel.CountryDataModel) {
        countryTheme()
        constraintSetupCountry()
        
        let countryCode = "(\(data.dialCode))"
        labelTitle.text = data.countryName + " \(countryCode)"
        labelTitle.addAttribute(targets: countryCode, color: UIColor.blueHeadingAlpha50)
    }
}

// MARK - Enterprise detail group
extension DooTitle_1TVCell {
    func enterpriseDetailGroupTheme() {
        labelTitle.font = UIFont.Poppins.medium(14)
        labelTitle.textColor = UIColor.blueHeading
    }

    func constraintSetupEnterpriseDetailGroup() {
        constraintTopLabel.constant = 14
        constraintLeadingLabel.constant = 33
        constraintTrailingLabel.constant = 33
        constraintLeadingSeparator.constant = 33
        constraintTrailingSeparator.constant = 33
    }

    func cellConfigEnterpriseDetailGroup(data: String) {
        enterpriseDetailGroupTheme()
        constraintSetupEnterpriseDetailGroup()
        labelTitle.text = data
    }
}
