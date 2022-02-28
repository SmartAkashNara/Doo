//
//  ThreeStripesWithGapInLastTVCell.swift
//  Doo-IoT
//
//  Created by smartsense-kiran on 19/08/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit
import SkeletonView

class ThreeStripesWithGapInLastTVCell: UITableViewCell {
    
    static let identifier: String = "ThreeStripesWithGapInLastTVCell"
    
    @IBOutlet weak var viewOfSeparator: UIView!
    @IBOutlet weak var stripeOne: UIView!
    @IBOutlet weak var stripeTwo: UIView!
    @IBOutlet weak var stripeThree: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.stripeOne.layer.cornerRadius = 4.0
        self.stripeOne.clipsToBounds = true
        self.stripeTwo.layer.cornerRadius = 4.0
        self.stripeTwo.clipsToBounds = true
        self.stripeThree.layer.cornerRadius = 4.0
        self.stripeThree.clipsToBounds = true
        
        self.stripeOne.isSkeletonable = true
        self.stripeTwo.isSkeletonable = true
        self.stripeThree.isSkeletonable = true
    }
    
    func startAnimating(index: Int) {
        self.viewOfSeparator.isHidden = false
        if index == 0 {
            self.viewOfSeparator.isHidden = true
        }
        self.stripeOne.showAnimatedSkeleton()
        self.stripeTwo.showAnimatedSkeleton()
        self.stripeThree.showAnimatedSkeleton()
    }
    
    func stopAnimating() {
        self.stripeOne.hideSkeleton()
        self.stripeTwo.hideSkeleton()
        self.stripeThree.hideSkeleton()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
