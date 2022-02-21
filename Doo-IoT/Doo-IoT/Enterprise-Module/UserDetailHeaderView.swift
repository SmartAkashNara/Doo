//
//  UserDetailHeaderView.swift
//  Doo-IoT
//
//  Created by Akash on 24/08/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation

class UserDetailHeaderView: UIView {
    @IBOutlet weak var imageViewOfUser: UIImageView!
    @IBOutlet weak var labelOfUsername: UILabel!
    @IBOutlet weak var labelOfWrittenUser: UILabel!
    
    var tapToSetNameClouser: (()->())? = nil
    
    // Enterprise User Info Holder instance
    var enterpriseUser: DooUser!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageViewOfUser.cornerRadius = 76.7/2
        self.imageViewOfUser.clipsToBounds = true
        self.imageViewOfUser.contentMode = .scaleAspectFill
        
        self.labelOfUsername.font = UIFont.Poppins.semiBold(18)
        self.labelOfUsername.textColor = UIColor.blueHeading
        self.labelOfWrittenUser.font = UIFont.Poppins.medium(11)
        self.labelOfWrittenUser.textColor = UIColor.blueHeading
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(userNameActionListener(_:)))
        labelOfUsername.addGestureRecognizer(tapGesture)
        labelOfUsername.isUserInteractionEnabled = true
        
        self.selectedCorners(radius: 25.0, [.bottomLeft, .bottomRight])
    }
    
    func setDetail(_ user: DooUser) {
        self.imageViewOfUser.contentMode = .scaleAspectFill
        if let userUrl = URL.init(string: user.image) {
            self.imageViewOfUser.sd_setImage(with: userUrl, placeholderImage: cueImage.userPlaceholder, options: .continueInBackground, context: nil)
        }else{
            self.imageViewOfUser.image = UIImage.init(named: "tempUserPlaceholder")
        }
        labelOfUsername.text = user.fullname.notAvailableIfEmpty
        labelOfWrittenUser.text = user.roleName
    }
    
    func setDetail(_ dooUser: AppUser) {
        labelOfWrittenUser.textColor = UIColor.blueHeadingAlpha60
        labelOfWrittenUser.text = dooUser.selectedEnterprise?.userRole.getTitle()
        setUserName(dooUser.fullName.notAvailableIfEmpty)
        imageViewOfUser.sd_setImage(with: URL(string: dooUser.thumbnailImage), placeholderImage: cueImage.userPlaceholder, options: .continueInBackground) { (image, error, cacheType, url) in
        }
    }
    
    func setUserName(_ userName: String) {
        if userName.isEmpty {
            labelOfUsername.textColor = UIColor.blueHeadingAlpha30
            labelOfUsername.text = localizeFor("tap_to_set_name")
        } else {
            labelOfUsername.textColor = UIColor.blueHeading
            labelOfUsername.text = userName
        }
    }
    
    @objc func userNameActionListener(_ gesture: UITapGestureRecognizer) {
        guard labelOfUsername.text == localizeFor("tap_to_set_name") else { return }
        tapToSetNameClouser?()
    }
}
