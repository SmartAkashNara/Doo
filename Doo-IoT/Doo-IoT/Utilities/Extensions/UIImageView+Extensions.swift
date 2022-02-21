//
//  UIImageView+Extensions.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 24/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit
import SDWebImage

extension UIImageView {
    func setImage(url: String, placeholder: UIImage?) {
        self.sd_setImage(with: URL(string: url), placeholderImage: placeholder, options: .highPriority, completed: {(image, error, type, url) in
        })
    }
}
