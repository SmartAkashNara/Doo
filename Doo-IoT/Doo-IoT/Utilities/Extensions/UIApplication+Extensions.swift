//
//  UIApplication+Extensions.swift
//  Doo-IoT
//
//  Created by Akash on 31/01/22.
//  Copyright © 2022 SmartSense. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return self.keyWindow?.rootViewController?.topMostViewController()
    }
}
