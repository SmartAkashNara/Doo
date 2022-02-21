//
//  TTTAttributedLabel+Extensions.swift
//  Doo-IoT
//
//  Created by Krunal's Macbook Pro on 01/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import TTTAttributedLabel

extension TTTAttributedLabel {
    func configureLink(textString: String, targets: String..., color: UIColor, font: UIFont, fontNormal: UIFont){
        numberOfLines = 2
        let fullAttributedString = NSAttributedString(string: textString, attributes: [
            NSAttributedString.Key.font: fontNormal,
            NSAttributedString.Key.foregroundColor: color,
        ])
        let ppLinkAttributes: [String: Any] = [
            NSAttributedString.Key.foregroundColor.rawValue: color,
            NSAttributedString.Key.font.rawValue : font,
        ]
        let ppActiveLinkAttributes: [String: Any] = [
            NSAttributedString.Key.underlineStyle.rawValue: false,
        ]
        attributedText = fullAttributedString
        linkAttributes = ppLinkAttributes
        activeLinkAttributes = ppActiveLinkAttributes
        targets.forEach { (target) in
            let rangeOfTarget = textString.toNSString.range(of: target)
            let data = ["data": target]
            addLink(toTransitInformation: data, with: rangeOfTarget)
        }
    }
    func configureLinkWithUnderline(textString: String, targets: String..., color: UIColor, font: UIFont, fontNormal: UIFont){
        numberOfLines = 2
        let fullAttributedString = NSAttributedString(string: textString, attributes: [
            NSAttributedString.Key.font: fontNormal,
            NSAttributedString.Key.foregroundColor: color,
        ])
        let ppLinkAttributes = [
            NSAttributedString.Key.foregroundColor.rawValue: color,
            NSAttributedString.Key.font.rawValue : font,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ] as [AnyHashable : Any]
        let ppActiveLinkAttributes: [String: Any] = [
            NSAttributedString.Key.underlineStyle.rawValue: true,
        ]
        attributedText = fullAttributedString
        linkAttributes = ppLinkAttributes
        activeLinkAttributes = ppActiveLinkAttributes
        targets.forEach { (target) in
            let rangeOfTarget = textString.toNSString.range(of: target)
            let data = ["data": target]
            addLink(toTransitInformation: data, with: rangeOfTarget)
        }
    }
}
