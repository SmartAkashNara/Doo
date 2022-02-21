//
//  UIScrollView+Extensions.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 07/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation

extension UIScrollView {
    func addBounceViewAtTop(withColor color: UIColor = UIColor.graySceneCard) {
        // top space, when pull happens
        var frame = self.bounds
        frame.origin.y = -frame.size.height
        let grayView = UIView(frame: frame)
        grayView.backgroundColor = color
        self.addSubview(grayView)
    }
}
