//
//  GroupCardSkeletonTVCell.swift
//  Doo-IoT
//
//  Created by smartsense-kiran on 30/08/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit
import SkeletonView

class GroupCardSkeletonTVCell: UITableViewCell {
    
    static let identifier: String = "GroupCardSkeletonTVCell"
    
    @IBOutlet weak var viewCard: UIView!
    @IBOutlet weak var viewOfDevicesTitle: UIView!
    @IBOutlet weak var viewOfDevicesValue: UIView!
    
    @IBOutlet weak var stackViewOfDevices: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        viewCard.backgroundColor = .white
        viewCard.layer.cornerRadius = 8
        viewCard.clipsToBounds = true
        viewCard.isSkeletonable = true
        
        viewOfDevicesTitle.backgroundColor = .white
        viewOfDevicesTitle.layer.cornerRadius = 8
        viewOfDevicesTitle.clipsToBounds = true
        viewOfDevicesTitle.isSkeletonable = true
        
        viewOfDevicesValue.backgroundColor = .white
        viewOfDevicesValue.layer.cornerRadius = 8
        viewOfDevicesValue.clipsToBounds = true
        viewOfDevicesValue.isSkeletonable = true
    }
    
    func showSekeletonAnimation() {
        viewCard.showAnimatedSkeleton()
        viewOfDevicesTitle.showAnimatedSkeleton()
        viewOfDevicesValue.showAnimatedSkeleton()
        
        for arrangedView in self.stackViewOfDevices.arrangedSubviews {
            arrangedView.removeFromSuperview() // removed arranged subviews.
        }
        for _ in 0..<4 {
            let arrangedView = UIView.init(frame: .zero)
            arrangedView.translatesAutoresizingMaskIntoConstraints = false
            arrangedView.addHeight(constant: 50)
            arrangedView.addWidth(constant: 50)
            arrangedView.backgroundColor = .white
            arrangedView.layer.cornerRadius = 8
            arrangedView.clipsToBounds = true
            arrangedView.isSkeletonable = true
            arrangedView.showAnimatedSkeleton()
            self.stackViewOfDevices.addArrangedSubview(arrangedView)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
