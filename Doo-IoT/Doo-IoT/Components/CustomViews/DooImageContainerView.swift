//
//  DooImageContainerView.swift
//  Doo-IoT
//
//  Created by Akash Nara on 08/01/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import Foundation
class DooImageContainerView: UIView {
    
   private var imageIcon: UIImageView? = nil
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func initSetup() {
        self.imageIcon = UIImageView.init(frame: .zero)
        guard let imageView  = imageIcon else {
            return
        }
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        self.cornerRadius = 6.7
        imageView.addSurroundingZeroToSuperView(isSuperView: self, constant: 5)
        imageView.addHeight(constant: Double(17))
        imageView.addWidth(constant: 17)
        imageView.contentMode = .scaleAspectFit
        selectedColor = UIColor.blueHeading
    }
    
    func setImageIcon(image:UIImage?){
        imageIcon?.image = image
    }
    
    var selectedColor: UIColor = UIColor.blueHeading {
        didSet {
            let templateImage = imageIcon?.image?.withRenderingMode(.alwaysTemplate)
            self.imageIcon?.image = templateImage
            imageIcon?.tintColor = selectedColor
        }
    }
}
