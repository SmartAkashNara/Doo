//
//  OneStripeViewCell.swift
//  Doo-IoT
//
//  Created by smartsense-kiran on 19/08/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit
import SkeletonView
class OneStripeViewCell: UITableViewCell {

    static let identifier: String = "OneStripeViewCell"
    @IBOutlet weak var stripeOne: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.stripeOne.layer.cornerRadius = 12.0
        self.stripeOne.clipsToBounds = true
        stripeOne.isSkeletonable  = true
    }
    
    func startAnimating() {
        self.stripeOne.showAnimatedSkeleton()
    }
    
    func stopAnimating() {
        self.stripeOne.hideSkeleton()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
