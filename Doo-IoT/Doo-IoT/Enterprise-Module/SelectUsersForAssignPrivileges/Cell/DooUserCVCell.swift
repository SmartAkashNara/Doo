//
//  DooUserCVCell.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 14/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

class DooUserCVCell: UICollectionViewCell {

    static let identifier = "DooUserCVCell"
    static let cellSize = CGSize(width: 44, height: 44)

    @IBOutlet weak var imageViewPic: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imageViewPic.contentMode = .scaleToFill
        imageViewPic.layer.cornerRadius = imageViewPic.frame.width/2
    }
    
    func cellConfig(image: String) {
        imageViewPic.contentMode = .scaleAspectFill
        if let url = URL.init(string: image){
            imageViewPic.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "asset9"), options: .highPriority)
        }else{
            imageViewPic.image = #imageLiteral(resourceName: "userPlaceholder")
        }
        // imageViewPic.image = UIImage(named: image)
    }
    
//    func cellConfig(imageURL: String) {
//        if let url = URL.init(string: imageURL){
//            imageViewPic.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "asset9"), options: .highPriority)
//        }else{
//            imageViewPic.image = #imageLiteral(resourceName: "userPlaceholder")
//        }
//    }

}
