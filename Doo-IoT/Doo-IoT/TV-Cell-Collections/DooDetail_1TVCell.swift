//
//  DooDetail_1TVCell.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 07/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class DooDetail_1TVCell: UITableViewCell {
    
    static let identifier = "DooDetail_1TVCell"
    static let cellHeight: CGFloat = 63
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDetail: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        
        labelTitle.font = UIFont.Poppins.regular(12)
        labelTitle.textColor = UIColor.blueHeadingAlpha60
        
        labelDetail.font = UIFont.Poppins.semiBold(14)
        labelDetail.textColor = UIColor.blueSwitch
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

extension DooDetail_1TVCell {
    func cellConfig(data: EnterpriseUserDetailViewModel.EnterpriseUserDetailField) {
        labelTitle.text = data.title
        labelDetail.text = data.value.dashIfEmpty
    }
    
    func cellConfigForProfile(data: EnterpriseUserDetailViewModel.EnterpriseUserDetailField) {
        labelTitle.text = data.title
        let placeholderTitle = data.title == localizeFor("mobile") ? "Add mobile number" : "Add \(data.title)"
        labelDetail.text = data.value.isEmpty ? placeholderTitle.sentenceCase : data.value
        labelDetail.textColor = data.value.isEmpty ? UIColor.blueHeadingAlpha30 : UIColor.blueSwitch
    }
}

extension DooDetail_1TVCell {
    func cellConfigForEnterpriseDetails(data: EnterpriseDetailViewModel.EnterpriseDetailField) {
        labelTitle.text = data.title
        labelDetail.text = data.value
        labelDetail.numberOfLines = 0
    }
}

extension DooDetail_1TVCell {
    func cellConfig(data: DeviceDetailViewModel.FirstSectionData) {
        labelTitle.text = data.title
        labelDetail.text = data.value
        labelDetail.textColor = data.color
        labelDetail.numberOfLines = 0
    }
}

extension DooDetail_1TVCell {
    func cellConfig(data: SmartRuleDetailViewModel.FirstSectionData) {
        labelTitle.text = data.title
        labelDetail.text = data.value
        labelDetail.textColor = data.color
        labelDetail.numberOfLines = 0
        labelDetail.isHidden = false        
    }
}


extension StringProtocol {
    var sentenceCase: String { prefix(1).uppercased() + lowercased().dropFirst() }
}

