//
//  FavouriteDeviceCVCell.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 19/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit
import SkeletonView

class FavouriteDeviceCVCell: UICollectionViewCell {

    static let identifier = "FavouriteDeviceCVCell"
    static let cellHeight: CGFloat = 90
    
    @IBOutlet weak var viewCard: UIView!
    @IBOutlet weak var imageViewDevice: UIImageView!
    @IBOutlet weak var viewStatusOnline: UIView!
    @IBOutlet weak var labelDeviceName: UILabel!
    @IBOutlet weak var skeletonViewForDeviceName: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        viewStatusOnline.backgroundColor = UIColor.redOffline
        viewStatusOnline.layer.cornerRadius = viewStatusOnline.bounds.width / 2
        viewStatusOnline.layer.borderWidth = 0.7
        viewStatusOnline.layer.borderColor = UIColor.white.cgColor
        
        imageViewDevice.contentMode = .scaleAspectFit
        imageViewDevice.isHidden = true

        viewCard.layer.cornerRadius = 15
        viewCard.backgroundColor = .white
        viewCard.layer.borderWidth = 1
        viewCard.tintColor = UIColor.blueSwitch
        viewCard.isSkeletonable = true
        viewCard.clipsToBounds = true
        
        labelDeviceName.font = UIFont.Poppins.regular(11)
        labelDeviceName.textColor = UIColor.blueHeadingAlpha60
        labelDeviceName.text = ""
        
        skeletonViewForDeviceName.cornerRadius = 8
        skeletonViewForDeviceName.clipsToBounds = true
        skeletonViewForDeviceName.isSkeletonable = true
        skeletonViewForDeviceName.backgroundColor = .clear
    }
    
    func showSkeletonAnimation() {
        imageViewDevice.isHidden = true
        labelDeviceName.isHidden = true
        viewCard.showAnimatedSkeleton()
        skeletonViewForDeviceName.showAnimatedSkeleton()
        viewCard.layer.borderColor = UIColor.clear.cgColor
    }
    
    func cellConfig(data: ApplianceDataModel, isSelected:Bool = false) {
        // Layout .......
        viewCard.hideSkeleton() // dismiss skeleton
        skeletonViewForDeviceName.hideSkeleton() // dismiss skeleton
        viewCard.layer.borderColor = UIColor.borderColorOffline.cgColor
        
        // Data fill ......
        labelDeviceName.text = data.applianceName
        // imageViewDevice.setImage(url: data.applianceTypeImage, placeholder: nil)
        imageViewDevice.setImage(url: data.applianceTypeImage, placeholder: #imageLiteral(resourceName: "imgFanOn"))  // <-- temp set this line above line correct
        imageViewDevice.isHidden = false

//         viewStatusOnline.isHidden = data.isMore ? true : !data.deviceStatus
        viewStatusOnline.backgroundColor = data.deviceStatus ? UIColor.greenOnline : UIColor.redOffline
        viewStatusOnline.isHidden = (data.isMore || data.isLess) ? true : false
        
        /*
        var hideStatus = data.isMore ? true : (data.deviceStatus ? false : true)
        if data.onOffStatus == false && hideStatus == false {
            hideStatus = true
        }
        viewStatusOnline.isHidden = hideStatus*/
        labelDeviceName.textColor = UIColor.blueHeadingAlpha60
        labelDeviceName.isHidden = false
        if (data.isMore || data.isLess) && !data.image.isEmpty{
            viewCard.backgroundColor = UIColor.grayMore
            viewCard.layer.borderWidth = 0
            imageViewDevice.image  = UIImage.init(named: data.image)!
        } else {
            if data.onOffStatus {
                viewCard.tintColor = UIColor.blueSwitchAlpha12
                viewCard.backgroundColor = UIColor.applianceOnColor
                viewCard.layer.borderWidth = 0
            } else {
                viewCard.tintColor = UIColor.blueSwitch
                viewCard.backgroundColor = UIColor.white
                viewCard.layer.borderWidth = 1
            }
        }
        /*
        if isSelected{
            viewCard.backgroundColor = UIColor.blueSwitch
            viewCard.layer.borderWidth = 1
            labelDeviceName.textColor = UIColor.grayOffDevice
        }
 */
    }

    func cellConfigFromApplianceDetailsinGroupDetail(data: ApplianceDataModel, isSelected:Bool = false) {
        
        labelDeviceName.text = data.applianceName
        imageViewDevice.setImage(url: data.applianceTypeImage, placeholder: #imageLiteral(resourceName: "imgFanOn"))  // <-- temp set this line above line correct
        imageViewDevice.isHidden = false
        
        viewStatusOnline.backgroundColor = data.deviceStatus ? UIColor.greenOnline : UIColor.redOffline
        viewStatusOnline.isHidden = (data.isMore || data.isLess) ? true : false
        viewCard.layer.borderColor = UIColor.borderColorOffline.cgColor

        /*
        var hideStatus = data.isMore ? true : (data.online ? false : true)
        if data.onOffStatus == false && hideStatus == false {
            hideStatus = true
        }
        viewStatusOnline.isHidden = hideStatus*/
        viewCard.tintColor = UIColor.blueSwitch
        labelDeviceName.textColor = UIColor.blueHeadingAlpha60
        if data.isMore {
            viewCard.backgroundColor = UIColor.grayMore
            viewCard.layer.borderWidth = 0
            imageViewDevice.image  = #imageLiteral(resourceName: "imgDropDownArrow")
        } else {
            if data.onOffStatus {
                viewCard.tintColor = UIColor.blueSwitchAlpha12
                viewCard.backgroundColor = UIColor.applianceOnColor
                viewCard.layer.borderWidth = 0
            } else {
                viewCard.backgroundColor = UIColor.white
                viewCard.layer.borderWidth = 1
            }
        }
        
        if isSelected {
//            viewCard.backgroundColor = UIColor.blueSwitch
            viewCard.layer.borderWidth = 1.3
            labelDeviceName.textColor = UIColor.blueHeading
            viewCard.tintColor = .white
            viewCard.layer.borderColor = UIColor.blueSwitch.cgColor
        }
    }
    
}
