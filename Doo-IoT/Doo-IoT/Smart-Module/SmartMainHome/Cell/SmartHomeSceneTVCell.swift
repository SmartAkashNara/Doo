//
//  SmartHomeSceneTVCell.swift
//  Doo-IoT
//
//  Created by Akash Nara on 08/01/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation
class SmartHomeSceneTVCell: UITableViewCell {
    
    static let identifier = "SmartHomeSceneTVCell"
    
    @IBOutlet weak var viewCard: UIView!
    @IBOutlet weak var imageViewLogo: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDevices: UILabel!
    @IBOutlet weak var buttonExecute: UIButton!
    @IBOutlet weak var buttonAddToSiri: UIButton!
    
    var isFromSiri: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        selectionStyle = .none
        
        viewCard.layer.cornerRadius = 12
        viewCard.borderColor = UIColor.blueHeadingAlpha10
        viewCard.borderWidth = 1
        imageViewLogo.contentMode = .scaleAspectFit
        imageViewLogo.cornerRadius = 2.0
        imageViewLogo.clipsToBounds = true
        
        labelTitle.font = UIFont.Poppins.semiBold(12)
        labelTitle.textColor = UIColor.blueHeading
        labelTitle.numberOfLines = 2
        
        labelDevices.font = UIFont.Poppins.regular(10)
        labelDevices.textColor = UIColor.graySubTile
        
        buttonExecute.titleLabel?.font = UIFont.Poppins.semiBold(10)
        buttonExecute.setTitle(localizeFor("execute"), for: .normal)
        
        buttonExecute.setTitleColor(UIColor.purpleButtonText, for: .normal)
        buttonExecute.layer.cornerRadius = buttonExecute.bounds.height / 2
        buttonExecute.backgroundColor = UIColor.grayMore
        
        buttonAddToSiri.titleLabel?.font = UIFont.Poppins.semiBold(10)
        buttonAddToSiri.setTitle("Add to Siri", for: .normal)
        
        buttonAddToSiri.setTitleColor(UIColor.purpleButtonText, for: .normal)
        buttonAddToSiri.layer.cornerRadius = buttonAddToSiri.bounds.height / 2
        buttonAddToSiri.backgroundColor = UIColor.graySceneCard
        
        labelTitle.text = "Good Morning MorningMorningMorningMorning MorningMorningMorningMorning"
        labelDevices.text = "4 Target Appliances"
        imageViewLogo.backgroundColor = UIColor.blueSwitchAlpha10
        //        imageViewLogo.contentMode = .scaleAspectFit
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

extension SmartHomeSceneTVCell{
    func cellConfigForSceneSelectionList(dataModel sceneObject: SRScenePredefinedDataModel) {
        
        let isSelected = sceneObject.isSelected 
        viewCard.backgroundColor = isSelected ? UIColor.blueSwitchAlpha10 : UIColor.white
        labelTitle.textColor = isSelected ? UIColor.blueSwitch : UIColor.blueHeading
        
        imageViewLogo.backgroundColor = isSelected ? UIColor.white : UIColor.blueSwitchAlpha10
        imageViewLogo.sd_setImage(with: URL(string: sceneObject.sceneIcon), placeholderImage: nil, options: .continueInBackground) { image, error, cacheType, url in
            if URL(string: sceneObject.sceneIcon) == url {
                self.imageViewLogo.backgroundColor = UIColor.clear
            }
        }
        if imageViewLogo.image == nil{
            imageViewLogo.backgroundColor = UIColor.blueSwitchAlpha10
        }
        labelTitle.text = sceneObject.sceneName
        labelDevices.isHidden = true
        buttonExecute.isHidden = true
    }
    
    func cellConfigForSceneList(dataModel sceneObject: SRSceneDataModel) {
        labelTitle.text = sceneObject.sceneName
        viewCard.backgroundColor = UIColor.white
        labelTitle.textColor = UIColor.blueHeading
        
        imageViewLogo.backgroundColor = UIColor.blueSwitchAlpha10
        imageViewLogo.sd_setImage(with: URL(string: sceneObject.sceneIcon), placeholderImage: nil, options: .continueInBackground) { image, error, cacheType, url in
            if URL(string: sceneObject.sceneIcon) == url {
                self.imageViewLogo.backgroundColor = UIColor.clear
            }
        }
        
        if imageViewLogo.image == nil{
            imageViewLogo.backgroundColor = UIColor.blueSwitchAlpha10
        }
        
        if sceneObject.viewEditMode == .viewEdit {
            buttonExecute.isHidden = isFromSiri ? true : false
        } else {
            buttonExecute.isHidden = true
        }
        
        self.buttonAddToSiri.setTitle(sceneObject.isAddedToSiri == true ? "Added to Siri" : "Add to Siri", for: .normal)
        buttonAddToSiri.setTitleColor(sceneObject.isAddedToSiri == true ? UIColor.greenOnline : UIColor.purpleButtonText, for: .normal)
        buttonAddToSiri.backgroundColor = sceneObject.isAddedToSiri == true ? UIColor.white : UIColor.graySceneCard
        
        buttonAddToSiri.isHidden = isFromSiri ? false : true
        labelDevices.text = "\(sceneObject.targetApplienceCount)"
    }
}
