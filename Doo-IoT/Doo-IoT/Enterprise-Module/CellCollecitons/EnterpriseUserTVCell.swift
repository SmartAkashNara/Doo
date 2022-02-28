//
//  EnterpriseUserInfoCell.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 06/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class EnterpriseUserTVCell: UITableViewCell {

    static let identifier = "EnterpriseUserTVCell"

    @IBOutlet weak var imageViewUser: UIImageView!
    @IBOutlet weak var imageViewTick: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelEmailorMobile: UILabel!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var buttonRemove: UIButton!
    @IBOutlet weak var buttonResend: UIButton!
    @IBOutlet weak var switchToEnableDisable: DooSwitch!
    
    enum EnumRightSideControl { case toggle, label, button, titleButton(String), none }
    enum EnumInvitationStatus: Int { case invited = 1, accepted, rejected }
    
    var selectedCell: Bool = false {
        didSet {
            imageViewTick.isHidden = !selectedCell
            contentView.backgroundColor = selectedCell ? UIColor.blueSwitchAlpha04 : UIColor.white
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        
        imageViewUser.cornerRadius = imageViewUser.frame.height / 2
        
        imageViewTick.contentMode = .scaleAspectFit
        imageViewTick.image = UIImage(named: "imgTickBlueRound")
        
        labelName.font = UIFont.Poppins.medium(14)
        labelName.textColor = UIColor.blueHeading
        
        labelEmailorMobile.font = UIFont.Poppins.regular(12)
        labelEmailorMobile.textColor = UIColor.blueHeadingAlpha60

        labelStatus.font = UIFont.Poppins.regular(12)
        labelStatus.textColor = UIColor.greenInvited
        labelStatus.text = "\(localizeFor("invited"))!"
        
        buttonRemove.setImage(UIImage(named: "imgCrossGray"), for: .normal)
        
        buttonResend.titleLabel?.font = UIFont.Poppins.medium(12)
        buttonResend.setTitleColor(UIColor.init(red: 6/255, green: 69/255, blue: 173/255, alpha: 1.0), for: .normal)
        
        rightSideControl(active: .none)
        selectedCell = false
        
        // switch default
        switchToEnableDisable.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    private func setUserStatus(data: DooUser) {
        guard let enumStatus = data.getEnumInvitationStatus else { return }
        contentView.alpha = 1
        switch enumStatus {
        case .invited:
            rightSideControl(active: .label)
        case .accepted:
            if data.enable {
                rightSideControl(active: .toggle)
                switchToEnableDisable.setOnSwitch()
            } else {
                rightSideControl(active: .toggle)
                switchToEnableDisable.setOffSwitch()
                contentView.alpha = 0.5
            }
        case .rejected:
            rightSideControl(active: .titleButton("Resend"))
        }
    }
    
    private func rightSideControl(active: EnumRightSideControl) {
        func allRightSideControllHide() {
            switchToEnableDisable.isHidden = true
            labelStatus.isHidden = true
            buttonRemove.isHidden = true
            buttonResend.isHidden = true
        }
        allRightSideControllHide()
        switch active {
        case .toggle:
            switchToEnableDisable.isHidden = false
        case .label:
            labelStatus.isHidden = false
        case .button:
            buttonRemove.isHidden = false
        case .titleButton(let title):
            buttonResend.isHidden = false
            buttonResend.setTitle(title, for: .normal)
        case .none:
            break
        }
    }
}

extension EnterpriseUserTVCell {
    func cellConfig(data: DooUser) {
        labelName.text = data.fullname.notAvailableIfEmpty
        labelEmailorMobile.text = data.getMobileOrEmail
        imageViewUser.contentMode = .scaleAspectFill
        imageViewUser.setImage(url: data.image, placeholder: cueImage.userPlaceholder)
        setUserStatus(data: data)
    }
}


extension EnterpriseUserTVCell {
    func cellConfigInviteUser(data: DooUser, active: EnumRightSideControl) {
        labelName.text = data.fullname.notAvailableIfEmpty
        labelEmailorMobile.text = data.getEmailOrMobile
        // imageViewUser.image = UIImage(named: data.image)
        imageViewUser.contentMode = .scaleAspectFill
        imageViewUser.setImage(url: data.image, placeholder: cueImage.userPlaceholder)
        rightSideControl(active: active)
    }
}

extension EnterpriseUserTVCell {
    func cellConfigUserPrivileges(data: DooUser) {
        labelName.text = data.fullname.notAvailableIfEmpty
        labelEmailorMobile.text = data.getEmailOrMobile
        // imageViewUser.image = UIImage(named: data.image)
        imageViewUser.contentMode = .scaleAspectFill
        if let url = URL.init(string: data.image){
            imageViewUser.sd_setImage(with:url, placeholderImage: #imageLiteral(resourceName: "asset4"), options: .highPriority)
        }else{
            imageViewUser.image = #imageLiteral(resourceName: "asset4")
        }

        self.selectedCell = data.selected
    }
}
