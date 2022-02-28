//
//  GroupCardTVCell.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 27/05/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class GroupCardTVCell: UITableViewCell {

    static let identifier = "GroupCardTVCell"

    @IBOutlet weak var imageViewBanner: UIImageView!
    @IBOutlet weak var labelDevices: UILabel!
    @IBOutlet weak var labelGroupName: UILabel!
    @IBOutlet weak var switchGroupEnableDisableStatus: DooSwitch!
    @IBOutlet weak var buttonMore: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        
        imageViewBanner.contentMode = .scaleAspectFill
        imageViewBanner.cornerRadius = 3.3
        labelDevices.font = UIFont.Poppins.regular(9)
        labelDevices.textColor = UIColor.blueHeadingAlpha60

        labelGroupName.font = UIFont.Poppins.semiBold(11)
        labelGroupName.textColor = UIColor.blueHeading
        labelGroupName.numberOfLines = 2
        
        buttonMore.setImage(UIImage(named: "imgMoreDots"), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension GroupCardTVCell {
    
    func cellConfig(deviceCount: Int, strGroupName: String, isOn: Bool, bannerImage: String) {
        imageViewBanner.image = UIImage.init(named: bannerImage)!
        /*
        if let url = URL.init(string: bannerImage), UIApplication.shared.canOpenURL(url){
            imageViewBanner.setImage(url: bannerImage, placeholder: Utility.getRandomBannerImage())
        }else{
            imageViewBanner.image = UIImage.init(named: bannerImage)
        }
 */
        labelGroupName.text = strGroupName
        let strDevcie = deviceCount > 1 ? localizeFor("devices")  : localizeFor("device")
        labelDevices.text = "\(deviceCount) \(strDevcie)"
        
        // Switch Work
        if isOn {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.switchGroupEnableDisableStatus.setOnSwitch(isWithAnimation: true)
            }
        }else{
            self.switchGroupEnableDisableStatus.setOffSwitch()
        }
    }
    
    func configureControlsAsPerGroupId(groupId:Int){
        var isHide = false
        if APP_USER?.selectedEnterprise?.userRole == .user{
            isHide = true
        }else if groupId == 0{
            isHide = true
        }
        buttonMore.isHidden = isHide//groupId == 0
        
        // Switch Work
        switchGroupEnableDisableStatus.isHidden = isHide//groupId == 0
    }
    /*
    func cellConfig(data: GroupLayouts, groupBackPlaceholderImage:UIImage?){ //GroupDataModel, groupImage:String, groupOnOff:Bool) {
//        buttonMore.isHidden = data.id == 0
//        switchGroupEnableDisableStatus.isHidden = data.id == 0
        let image = data.groupData.count == 0 ? "" :  data.backGroundImage
        imageViewBanner.setImage(url: image, placeholder: groupBackPlaceholderImage)
        let strDevcie = data.groupData.count > 1 ? localizeFor("devices")  : localizeFor("device")
        labelDevices.text = "\(data.groupData.count) \(strDevcie)"
        
        labelGroupName.text = data.title
        switchGroupEnableDisableStatus.setOn(data.enable, animated: true)
    }*/
    
}
