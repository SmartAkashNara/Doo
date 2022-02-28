//
//  BottomPopupForSiriActionsTVCell.swift
//  Doo-IoT
//
//  Created by Shraddha on 27/12/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit

class BottomPopupForSiriActionsTVCell: UITableViewCell {
    
    static let identifier: String = "BottomPopupForSiriActionsTVCell"
    
    @IBOutlet weak var labelActionTitle: UILabel!
    @IBOutlet weak var buttonAddToSiri: UIButton!
    
//    @IBOutlet weak var topConstraint: NSLayoutConstraint!
//    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        labelActionTitle.numberOfLines = 2
        labelActionTitle.lineBreakMode = .byWordWrapping
        labelActionTitle.font = UIFont.Poppins.medium(13.3)
        
        buttonAddToSiri.titleLabel?.font = UIFont.Poppins.semiBold(10)
        buttonAddToSiri.setTitle("Add to Siri", for: .normal)
        
        buttonAddToSiri.setTitleColor(UIColor.purpleButtonText, for: .normal)
        buttonAddToSiri.layer.cornerRadius = buttonAddToSiri.bounds.height / 2
        buttonAddToSiri.backgroundColor = UIColor.graySceneCard
        buttonAddToSiri.isHidden = false
    }
    
//    func setSpaceConstraint(gap: Double) {
//        self.topConstraint.constant = CGFloat(gap/2)
//        self.bottomConstraint.constant = CGFloat(gap/2)
//    }
    
    func cellConfig(popupOption: BottomPopupForSiriViewController.PopupOptionForSiri) {
        self.labelActionTitle.text = popupOption.title
        self.labelActionTitle.textColor = popupOption.color
        
        self.buttonAddToSiri.setTitle(popupOption.buttonTitle, for: .normal)
        self.buttonAddToSiri.setTitleColor(popupOption.buttonColor, for: .normal)
        
        self.buttonAddToSiri.backgroundColor  = popupOption.buttonBackgroundColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
//            self.buttonAddToSiri.setTitle(sceneObject.isAddedToSiri == true ? "Added to Siri" : "Add to Siri", for: .normal)
//            buttonAddToSiri.setTitleColor(sceneObject.isAddedToSiri == true ? UIColor.greenOnline : UIColor.purpleButtonText, for: .normal)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
