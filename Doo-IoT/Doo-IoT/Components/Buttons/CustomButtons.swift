//
//  CustomButtons.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 28/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation
import UIKit

class TableButton: UIButton {
    var section: Int = 0
    var row: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
