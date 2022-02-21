//
//  DispatchQueue+Extensions.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 08/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation

// MARK: DispatchQueue
extension DispatchQueue {
    static func getMainWithoutDelay(completion: @escaping ()->()) {
        DispatchQueue.main.async {
            completion()
        }
    }
    static func getMain(delay: Double = 0.1, completion: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            completion()
        }
    }
}
