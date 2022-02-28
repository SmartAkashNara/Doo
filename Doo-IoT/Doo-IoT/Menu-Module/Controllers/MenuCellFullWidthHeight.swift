//
//  MenuCell.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 19/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit
import SkeletonView

class MenuCellFullWidthHeight: UICollectionViewCell {
    
    static let identifier = "MenuCellFullWidthHeight"
    static let cellHeight: CGFloat = 120
    
    @IBOutlet weak var viewCard: UIView!
    @IBOutlet weak var imageMenuIcon: UIImageView!
    @IBOutlet weak var labelMenuName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewCard.backgroundColor = UIColor(named: "menuCellBackground")
        viewCard.layer.cornerRadius = 12
        viewCard.clipsToBounds = true
        viewCard.isSkeletonable = true
        
        imageMenuIcon.isHidden = true
        labelMenuName.textColor = UIColor(named: "menuLabelTextColor")
        labelMenuName.textColor =  UIColor.init(named: "menuLabelTextColor")
        labelMenuName.font = UIFont.Poppins.medium(12)
        labelMenuName.isHidden = true
    }
    
    func cellConfig(data: MenuDataModel) {
        imageMenuIcon.isHidden = false
        imageMenuIcon.image = UIImage(named: data.image)
        labelMenuName.isHidden = false
        labelMenuName.text = data.title
        viewCard.hideSkeleton() // dismiss skeleton.
    }
    
    func showSkeletonAnimation() {
        viewCard.showAnimatedSkeleton()
    }
}
