//
//  FavouriteSceneCVCell.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 20/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit
import SkeletonView

class FavouriteSceneCVCell: UICollectionViewCell {

    static let identifier = "FavouriteSceneCVCell"
    static let cellSize = CGSize(width: 130, height: 170)

    @IBOutlet weak var viewCard: UIView!
    @IBOutlet weak var imageViewLogo: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDevices: UILabel!
    @IBOutlet weak var buttonExecute: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        viewCard.layer.cornerRadius = 17
        viewCard.backgroundColor = UIColor.graySceneCard
        viewCard.clipsToBounds = true
        viewCard.isSkeletonable = true
        
        imageViewLogo.contentMode = .center
        imageViewLogo.contentMode = .scaleAspectFit
        imageViewLogo.cornerRadius = 2.0
        imageViewLogo.clipsToBounds = true
        
        labelTitle.font = UIFont.Poppins.semiBold(11)
        labelTitle.textColor = UIColor.blueHeading
        labelTitle.isHidden = true
//        labelTitle.numberOfLines = 2
        
        labelDevices.font = UIFont.Poppins.regular(9)
        labelDevices.textColor = UIColor.blueHeading
        labelDevices.isHidden = true
        
        buttonExecute.titleLabel?.font = UIFont.Poppins.semiBold(11)
        buttonExecute.setTitle(localizeFor("execute"), for: .normal)
        buttonExecute.setTitleColor(UIColor.purpleButtonText, for: .normal)
        buttonExecute.layer.cornerRadius = buttonExecute.bounds.height / 2
        buttonExecute.backgroundColor = UIColor.white
        buttonExecute.isHidden = true
    }

    func cellConfig(data: SRSceneDataModel) {
        // data fill...
        labelTitle.text = data.sceneName
        let applienceStr = data.arrayTargetApplience.count > 1 ? "appliances" : "appliance"
        labelDevices.text = "\(data.arrayTargetApplience.count) \(applienceStr)"
        // imageViewLogo.image = UIImage(named: data.image)
        imageViewLogo.backgroundColor = UIColor.blueSwitchAlpha10
        imageViewLogo.sd_setImage(with: URL(string: data.sceneIcon), placeholderImage: nil, options: .continueInBackground) { image, error, cacheType, url in
            if URL(string: data.sceneIcon) == url {
                self.imageViewLogo.backgroundColor = UIColor.clear
            }
        }
        
        if imageViewLogo.image == nil{
            imageViewLogo.backgroundColor = UIColor.blueSwitchAlpha10
        }
        
        // skeleton work...
        self.viewCard.hideSkeleton()
        self.imageViewLogo.isHidden = false
        self.labelTitle.isHidden = false
        self.labelDevices.isHidden = false
        if data.viewEditMode == .viewEdit {
            buttonExecute.isHidden = false
        } else {
            buttonExecute.isHidden = true
        }
    }
    
    func showSkeletonAnimation() {
        self.viewCard.showAnimatedSkeleton()
        self.imageViewLogo.isHidden = true
        self.labelTitle.isHidden = true
        self.labelDevices.isHidden = true
        self.buttonExecute.isHidden = true
    }
}
