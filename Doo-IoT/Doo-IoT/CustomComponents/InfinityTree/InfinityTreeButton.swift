//
//  InfinityTreeButton.swift
//  InfinityTree
//
//  Created by Kiran Jasvanee on 11/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation
import UIKit

class ButtonOfInfinityTree: UIButton {
    var identity: String = ""
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
