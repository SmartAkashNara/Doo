//
//  String+Extensions.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 20/03/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width + CGFloat(40.0)
    }
    
    func trimSpace() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    func lineSpaceString(lineSpace:CGFloat=0.0) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        
        // *** Create instance of `NSMutableParagraphStyle`
        let paragraphStyle = NSMutableParagraphStyle()
        
        // *** set LineSpacing property in points ***
        paragraphStyle.lineSpacing = lineSpace // Whatever line spacing you want in points
        
        // *** Apply attribute to string ***
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        
        return attributedString
    }
    
    func attributedStringWithColor(color: UIColor, font:UIFont, arrayRange: [NSRange]) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        for range in arrayRange {
            attributedString.addAttributes([NSAttributedString.Key.foregroundColor : color, NSAttributedString.Key.font : font], range: range)
        }
        
        attributedString.addAttribute(NSAttributedString.Key.kern, value: 5, range: NSRange(location: 0, length: attributedString.length - 1))
        return attributedString
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(boundingBox.width)
    }
}

extension String {
    var trimSpaceAndNewline: String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}

extension String {
    var toNSString: NSString {
        return NSString(string: self)
    }
}

extension String {
    var isEmptyOrDash: Bool {
        self.isEmpty || self == "-"
    }
    var notAvailableIfEmpty: String {
        return self.trimSpaceAndNewline.isEmpty ? "Not Available" : self
    }
    var dashIfEmpty: String {
        self.isEmpty ? "-" : self
    }
}

extension String {
    func sized(_ font: UIFont) -> CGSize {
        #if swift(>=4)
        return NSAttributedString(string: self, attributes: [NSAttributedString.Key.font: font]).size()
        #else
        return NSAttributedString(string: self, attributes: [NSFontAttributeName: font]).size()
        #endif
    }
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    // Masking characters
    func hideCharas(_ maskingUpTo: Int) -> String {
        return String(self.enumerated().map { index, char in
            
            var maskingIndexArray: [Int] = []
            for i in 0...maskingUpTo {
                maskingIndexArray.append(i)
            }
            return maskingIndexArray.contains(index) ? char : "*"
        })
    }
    
    // Masking characters
    func removeDialCode() -> String? {
        if self.contains("+") && self.contains("-") {
            var mobileWithDialCode = self
            mobileWithDialCode.removeFirst()
            let digits = mobileWithDialCode.components(separatedBy: "-")
            
            if digits.indices.contains(1){
                if InputValidator.isNumber(digits[1]) {
                    return digits[1]
                }
            }
        }
        return self
    }
    
    func preinsertIfNotEmpty(_ imagePath: String) -> String {
        guard !self.isEmpty else { return self }
        return imagePath + self
    }
    
    func setPhoneSecurePhoneNumber() -> String? {
         let phoneNoCombo = self.components(separatedBy: " ")
        guard phoneNoCombo.count != 0 else{
            return nil
        }
        let phoneNo = phoneNoCombo[1]
        guard !phoneNo.isEmpty else{
            return nil
        }
        guard !phoneNoCombo[0].isEmpty else{
            return nil
        }
        if !phoneNo.isEmpty && phoneNo.count > 6 {
            let firstTwoDigitOfPhone = phoneNo.prefix(4)
            let mapRemainingToAstrik = phoneNo.dropFirst(4)
            let astrikResult = mapRemainingToAstrik.map { (char) -> String in
                return "*"
            }
            let finalResult = phoneNoCombo[0] + " " + (firstTwoDigitOfPhone + astrikResult.joined())
            return finalResult
        }
        return nil
    }

}

// Range Extensions.
extension RangeExpression where Bound == String.Index  {
    func nsRange<S: StringProtocol>(in string: S) -> NSRange { .init(self, in: string) }
}
extension StringProtocol {
    subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
    subscript(range: Range<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: ClosedRange<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: PartialRangeFrom<Int>) -> SubSequence { self[index(startIndex, offsetBy: range.lowerBound)...] }
    subscript(range: PartialRangeThrough<Int>) -> SubSequence { self[...index(startIndex, offsetBy: range.upperBound)] }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence { self[..<index(startIndex, offsetBy: range.upperBound)] }
}

extension String{
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

}
