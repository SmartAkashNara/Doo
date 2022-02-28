//
//  AllNumber+Extensions.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 28/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

extension Int {
    init(_ range: Range<Int> ) {
        let delta = range.startIndex < 0 ? abs(range.startIndex) : 0
        let min = UInt32(range.startIndex + delta)
        let max = UInt32(range.endIndex   + delta)
        self.init(Int(min + arc4random_uniform(max - min)) - delta)
    }
    
    func isBetween(min:Int, max:Int) -> Bool {
        return self > min && self < max
    }
    
    func isBetweenAndIncluded(min:Int, max:Int) -> Bool {
        return self >= min && self <= max
    }
    
    func isZero() -> Bool {
        return self == 0
    }
    
    func commaFormatted() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(integerLiteral: self)) ?? ""
    }
    
    func setSufix(single: String, multiple: String, isZeroAccept: Bool = false) -> String {
        switch self {
        case 1:
            return "\(self)\(single)"
        case let x where x > 1:
            return "\(self)\(multiple)"
        case 0 where isZeroAccept:
            return "\(self)\(single)"
        default:
            // < 1
            return ""
        }
    }
    
    func getSpeedFromPercentage() ->Int{
        switch self {
        case 0:
            return 0
        case 30:
            return 1
        case 40:
            return 2
        case 50:
            return 3
        case 100:
            return 4
        default:
            return 0
        }
    }
    
    func getPercentageSpeed() ->Int{
        switch self {
        case 0:
            return 0
        case 1:
            return 30
        case 2:
            return 40
        case 3:
            return 50
        case 4:
            return 100
        default:
            return 0
        }
    }

    
    /*
    func getSpeedFromPercentage() ->Int{
        switch self {
        case 0:
            return 0
        case 30:
            return 1
        case 40:
            return 2
        case 45:
            return 3
        case 50:
            return 4
        case 100:
            return 5
        default:
            return 0
        }
    }
    
    func getPercentageSpeed() ->Int{
        switch self {
        case 0:
            return 0
        case 1:
            return 30
        case 2:
            return 40
        case 3:
            return 45
        case 4:
            return 50
        case 5:
            return 100
        default:
            return 0
        }
    }*/
    
    func getUIColorFromDecimalCode() -> UIColor {
        let decimalColorValue = self
        let hexValue = String(decimalColorValue, radix: 16)
        return UIColor.init(hex: hexValue)
    }
}

extension Double {
    func isBetween(min: Double, max: Double) -> Bool {
        return self > min && self < max
    }
    
    func isBetweenAndIncluded(min: Double, max: Double) -> Bool {
        return self >= min && self <= max
    }
}

extension CGFloat {
    func isBetween(min: CGFloat, max: CGFloat) -> Bool {
        return self > min && self < max
    }
    
    func isBetweenAndIncluded(min: CGFloat, max: CGFloat) -> Bool {
        return self >= min && self <= max
    }
}

extension Bool {
    var isHiddenToAlpha: CGFloat {
        return self ? 0 : 1
    }
}

extension Array {
    func isLastIndex(_ index: Int) -> Bool {
        return index == self.count - 1
    }
    
    func isCount(_ number: Int) -> Bool {
        return self.count == number
    }
}

extension Array where Element == String {
    func removeEmptiesAndJoinWith(_ separator: String) -> String {
        var elements = self
        elements.removeAll(where: { $0.isEmpty })
        return elements.joined(separator: separator)
    }
}

extension Array where Element: DayCategorizable {
    var daySorted: [Date: [Element]] {
        var result: [Date: [Element]] = [:]
        self.forEach { item in
            let i = item.identifierDate.endOfDay
            if result.keys.contains(i) {
                result[i]?.append(item)
            } else {
                result[i] = [item]
            }
        }
        return result
    }
}

