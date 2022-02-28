//
//  DooHeaderDetail_1TVCell.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 07/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class DooHeaderDetail_1TVCell: UITableViewCell {

    static let identifier = "DooHeaderDetail_1TVCell"
    static let cellHeight: CGFloat = 40

    @IBOutlet weak var imageViewDash: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        contentView.backgroundColor = UIColor.white
        
        imageViewDash.contentMode = .scaleAspectFit
        imageViewDash.image = UIImage(named: "imgHeaderGreenDash")

        labelTitle.font = UIFont.Poppins.medium(14)
        labelTitle.textColor = UIColor.greenInvited

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func cellConfig(title: String) {
        imageViewDash.isHidden = false
        labelTitle.text = title
    }
    
    func cellConfigBlue(title: String) {
        imageViewDash.isHidden = true
        labelTitle.font = UIFont.Poppins.medium(11.3)
        labelTitle.textColor = UIColor.blueSwitch
        labelTitle.text = title
    }
    
    override func layoutSubviews(){
        super.layoutSubviews()
        
        for subview in subviews where (subview != contentView && abs(subview.frame.width - frame.width) <= 0.1 && subview.frame.height < 2) {
//            subview.removeFromSuperview()                           //option #1 -- remove the line completely
            subview.frame = subview.frame.insetBy(dx: 16, dy: 0)  //option #2 -- modify the length
        }
    }

    
}
