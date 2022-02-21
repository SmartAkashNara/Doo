//
//  UILabel+Extensions.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 30/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

extension UILabel {
    func addAttribute(targets: String..., font: UIFont) {
        /* Put the search text into the message */
        let message = text ?? ""
        let attributedString = NSMutableAttributedString(string: message)
        
        targets.forEach { (target) in
            /* Find the position of the search string. Cast to NSString as we want
             range to be of type NSRange, not Swift's Range<Index> */
            let range = message.toNSString.range(of: target)
            
            /* Make the text at the given range bold. Rather than hard-coding a text size,
             Use the text size configured in Interface Builder. */
            attributedString.addAttribute(NSAttributedString.Key.font, value: font, range: range)
        }
 
        /* Put the text in a label */
        attributedText = attributedString
    }
    
    func addAttribute(targets: String..., color: UIColor) {
        /* Put the search text into the message */
        let message = text ?? ""
        let attributedString = NSMutableAttributedString(string: message)
        
        targets.forEach { (target) in
            /* Find the position of the search string. Cast to NSString as we want
             range to be of type NSRange, not Swift's Range<Index> */
            let range = message.toNSString.range(of: target)
            
            /* Make the text at the given range bold. Rather than hard-coding a text size,
             Use the text size configured in Interface Builder. */
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        }
        
        /* Put the text in a label */
        attributedText = attributedString
    }
}

