//
//  GroupTopOptionsCVCell.swift
//  Doo-IoT
//
//  Created by Shraddha on 04/08/21.
//

import UIKit
import SkeletonView

class GroupTopOptionsCVCell: UICollectionViewCell {
    
    // MARK:- IBOutlets
    @IBOutlet weak var viewOfSkeleton: UIView!
    @IBOutlet weak var labelOptionTitle: UILabel!
    
    // MARK: - Variable Declaration
    static let identifier = "GroupTopOptionsCVCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.defaultConfig()
    }
    
    // MARK:- Other Methods
    // Default Config
    func defaultConfig() {
        self.labelOptionTitle.textColor = UIColor.black
        self.labelOptionTitle.numberOfLines = 1
        self.labelOptionTitle.font = UIFont.Poppins.medium(13.3)
        self.labelOptionTitle.text = ""
        
        self.viewOfSkeleton.isSkeletonable = true
        self.viewOfSkeleton.layer.cornerRadius = 8.0
        self.viewOfSkeleton.clipsToBounds = true
    }
    
    // Cell Config
    func cellConfig(slideValues: HorizontalTitleCollectionDataModel) {
        self.viewOfSkeleton.hideSkeleton() // hide skeleton to show data now.
        self.labelOptionTitle.text = slideValues.title
        self.labelOptionTitle.textColor = slideValues.isSelected ? UIColor.greenInvited : UIColor.black
    }
    
    func showSkeletonAnimation() {
        self.viewOfSkeleton.showAnimatedSkeleton()
    }
    
    override func layoutSubviews() {
        superview?.layoutSubviews()

    }
}
