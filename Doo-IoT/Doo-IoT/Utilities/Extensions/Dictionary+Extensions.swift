//
//  Dictionary+Extensions.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 22/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation

extension Dictionary{
    mutating func removeEmptyValues() {
        let keysToRemove = self.keys.filter { self[$0] is String && self[$0] as? String ?? "" == "" }
        for key in keysToRemove {
            self.removeValue(forKey: key)
        }
    }
    
    mutating func removeZeroValues() {
        let keysToRemove = self.keys.filter { self[$0] is Int && self[$0] as? Int ?? 0 == 0 }
        for key in keysToRemove {
            self.removeValue(forKey: key)
        }
    }
    
    mutating func removeEmptyOrZeroValues() {
        let keysToRemove = self.keys.filter {
            (self[$0] is Int && self[$0] as? Int ?? 0 == 0) ||
                (self[$0] is String && self[$0] as? String ?? "" == "")
        }
        for key in keysToRemove {
            self.removeValue(forKey: key)
        }
    }
}
